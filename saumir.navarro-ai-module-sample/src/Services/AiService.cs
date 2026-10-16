using System.Net.Http.Headers;
using System.Net.Http.Json;
using Conexta.Contracts.Ai;
using Conexta.DataAccess;

namespace Conexta.API.Services;

public class AiService
{
    private readonly HttpClient _httpClient; // BaseAddress = https://ai.saumirnavarro.us/ (see Program.cs)
    private readonly AiDataAccess _aiData;
    private readonly ILogger<AiService> _logger;

    public AiService(HttpClient httpClient, AiDataAccess aiData, ILogger<AiService> logger)
    {
        _httpClient = httpClient;
        _aiData = aiData;
        _logger = logger;
    }

    public async Task<ImprovePostResponse> ImprovePostAsync(Guid susId, string jwt, ImprovePostRequest request)
    {
        var plan = await _aiData.GetActivePlan(susId);
        if (plan is null)
            return new ImprovePostResponse { Success = false, Message = "No active plan was found for this account", ErrorCode = "NO_PLAN" };

        var providerConfig = await _aiData.GetProviderForPlan(plan.ppp_Id);
        if (providerConfig is null)
            return new ImprovePostResponse { Success = false, Message = "The plan has no AI provider configured", ErrorCode = "NO_PROVIDER" };

        var quota = await _aiData.GetRemainingQuota(susId);
        if (quota is not null && quota.IsExhausted)
            return new ImprovePostResponse { Success = false, Message = "You have reached your AI quota for this month", ErrorCode = "QUOTA_EXCEEDED" };

        // RECRUITMENT (patient-recruitment post) uses a different endpoint and a different "current"
        // shape (title/description) than the rest of the post types (matter/description/price).
        var isRecruitment = request.PtyCode == "RECRUITMENT";
        var endpoint = isRecruitment ? "api/posts/recruitment/improve" : "api/posts/improve";

        object currentBody = isRecruitment
            ? new { title = request.Matter, description = request.Description }
            : new { matter = request.Matter, description = request.Description, price = request.Price };

        var body = new
        {
            provider = providerConfig.PrimaryProvider, // already uppercase (comes from ai.aip_AIProvider.aip_Code)
            ptyCode = request.PtyCode,
            locale = request.Locale,
            current = currentBody,
            instruction = request.Instruction,
            inputKind = request.InputKind
        };

        using var httpRequest = new HttpRequestMessage(HttpMethod.Post, endpoint) { Content = JsonContent.Create(body) };
        httpRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jwt);

        var startedAt = DateTime.UtcNow;
        HttpResponseMessage httpResponse;
        try
        {
            httpResponse = await _httpClient.SendAsync(httpRequest);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calling ai.conexta.us for {SusId}", susId);
            return new ImprovePostResponse { Success = false, Message = "Could not connect to the AI service", ErrorCode = "UNREACHABLE" };
        }

        var elapsedMs = (int)(DateTime.UtcNow - startedAt).TotalMilliseconds;

        if (!httpResponse.IsSuccessStatusCode)
        {
            var errorBody = await httpResponse.Content.ReadAsStringAsync();
            _logger.LogWarning("ai.conexta.us responded {Status} for {SusId}: {Body}", httpResponse.StatusCode, susId, errorBody);

            await _aiData.LogUsage(susId, request.PtyCode, request.PostId, endpoint,
                0, 0, 0, null, elapsedMs, (int)httpResponse.StatusCode, success: false,
                errorCode: httpResponse.StatusCode.ToString(), createdBy: susId.ToString());

            return new ImprovePostResponse { Success = false, Message = "The AI service could not process the request", ErrorCode = "AI_FAILED" };
        }

        // The two endpoints do NOT share a response shape (confirmed by the ai.conexta.us team,
        // see the note below) — each one is deserialized with its own class.
        var jsonOptions = new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true };

        string? improvedMatter;
        string? improvedDescription;
        AiUsage usage;

        if (isRecruitment)
        {
            var result = await httpResponse.Content.ReadFromJsonAsync<AiRecruitmentRawResponse>(jsonOptions);
            if (result is null)
                return new ImprovePostResponse { Success = false, Message = "Empty response from the AI service", ErrorCode = "EMPTY_RESPONSE" };

            // In RECRUITMENT, title and description ALWAYS contain text on a 200 (if either is
            // missing, ai.conexta.us answers 502, not 200) — no null check is needed here,
            // but the same pattern is kept for consistency with the other branch.
            improvedMatter = result.Title;
            improvedDescription = result.Description;
            usage = result.Usage;

            // TODO: professionName/specialtyName/ageFrom/ageTo/gender/cityName/countryName/
            // costFrom/costTo also come back in the RECRUITMENT response but are not mapped
            // anywhere today — the patient-recruitment post page has no "Improve with AI"
            // for those fields yet. If added, they go in ImprovePostResponse.
        }
        else
        {
            var result = await httpResponse.Content.ReadFromJsonAsync<AiImproveRawResponse>(jsonOptions);
            if (result is null)
                return new ImprovePostResponse { Success = false, Message = "Empty response from the AI service", ErrorCode = "EMPTY_RESPONSE" };

            // matter/description can be null on a 200 (a ptyCode that does not support the
            // field, or the AI did not generate it) — ai.conexta.us guarantees that at least
            // one of the two has text. The client only overwrites a field when it is not
            // null/empty, so nothing special is needed here.
            improvedMatter = result.Matter;
            improvedDescription = result.Description;
            usage = result.Usage;

            // result.Warning: a non-blocking note from the AI itself (not moderation). Today it is
            // not exposed in ImprovePostResponse; to show it as a notice in the app, add a
            // Warning field to the contract and map it here.
        }

        await _aiData.LogUsage(susId, request.PtyCode, request.PostId, endpoint,
            usage.InputTokens, usage.OutputTokens, usage.TotalTokens,
            usage.Model, elapsedMs, (int)httpResponse.StatusCode, success: true,
            errorCode: null, createdBy: susId.ToString());

        return new ImprovePostResponse
        {
            Success = true,
            Message = "OK",
            ImprovedMatter = improvedMatter,
            ImprovedDescription = improvedDescription
        };
    }
}

// REAL response shapes confirmed by the ai.conexta.us team (2026-10-04). Every key is
// ALWAYS present in the JSON (if there is no value it arrives as null — a key is never
// omitted), and the two endpoints do NOT share a shape.

// POST /api/posts/improve — GEN, PINFO, SELL, DONATE, SERVICE.
internal class AiImproveRawResponse
{
    public string? Matter { get; set; }
    public string? Description { get; set; }
    public double? Price { get; set; }
    public string? Warning { get; set; }
    public string? Provider { get; set; }
    public AiUsage Usage { get; set; } = new();
}

// POST /api/posts/recruitment/improve — RECRUITMENT (patient-recruitment post). No matter, no
// price, no warning; instead it returns the profile fields of the patient being sought.
internal class AiRecruitmentRawResponse
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? ProfessionName { get; set; }
    public string? SpecialtyName { get; set; }
    public int? AgeFrom { get; set; }
    public int? AgeTo { get; set; }
    public string? Gender { get; set; }
    public string? CityName { get; set; }
    public string? CountryName { get; set; }
    public decimal? CostFrom { get; set; }
    public decimal? CostTo { get; set; }
    public string? Provider { get; set; }
    public AiUsage Usage { get; set; } = new();
}

// Common to both endpoints. There is no promptTokens/completionTokens — the fields are
// inputTokens/outputTokens. It is not present in error responses (400/401/429/5xx).
internal class AiUsage
{
    public string UserId { get; set; } = string.Empty;
    public string Provider { get; set; } = string.Empty;
    public string? Model { get; set; }
    public int InputTokens { get; set; }
    public int OutputTokens { get; set; }
    public int TotalTokens { get; set; }
    public decimal EstimatedCostUsd { get; set; }
    public int ElapsedMs { get; set; }
    public DateTime CreatedAtUtc { get; set; }
}
