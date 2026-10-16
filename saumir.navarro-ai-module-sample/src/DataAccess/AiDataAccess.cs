using Dapper;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System.Data;

namespace Conexta.DataAccess;

/// <summary>Flat row returned by subscription.ps_Sus_GetActivePlan.</summary>
public class ActivePlanRow
{
    public Guid dsu_Id { get; set; }
    public Guid ppp_Id { get; set; }
    public string ppp_Code { get; set; } = string.Empty;
    public long psu_Id { get; set; }
    public string bps_Id { get; set; } = string.Empty;
}

/// <summary>Flat row returned by ai.ps_Aic_GetProviderForPlan.</summary>
public class ProviderForPlanRow
{
    public Guid ppp_Id { get; set; }
    public long MonthlyTokenLimit { get; set; }
    public string PrimaryProvider { get; set; } = string.Empty;
    public string? PrimaryProviderName { get; set; }
    public string? FallbackProvider { get; set; }
    public string? FallbackProviderName { get; set; }
}

/// <summary>Flat row returned by ai.ps_Aih_RemainingQuota.</summary>
public class RemainingQuotaRow
{
    public Guid aih_Id { get; set; }
    public int aih_PeriodYear { get; set; }
    public int aih_PeriodMonth { get; set; }
    public long TokenLimit { get; set; }
    public long TokensConsumed { get; set; }
    public long? Remaining { get; set; }
    public bool IsExhausted { get; set; }
}

/// <summary>
/// Data access to the stored procedures in the [subscription]/[ai] schemas needed by the "Improve with AI" flow:
/// resolve the active plan, resolve the provider for that plan, check the quota, and record consumption.
/// </summary>
public class AiDataAccess
{
    private readonly Func<IDbConnection> _connectionFactory;
    private readonly ILogger<AiDataAccess> _logger;

    public AiDataAccess([FromKeyedServices("Conexta")] Func<IDbConnection> connectionFactory, ILogger<AiDataAccess> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<ActivePlanRow?> GetActivePlan(Guid susId)
    {
        try
        {
            using var conn = _connectionFactory();
            var row = await conn.QuerySingleOrDefaultAsync<ActivePlanRow>(
                "[subscription].[ps_Sus_GetActivePlan]", new { sus_Id = susId }, commandType: CommandType.StoredProcedure);
            return row is null || row.ppp_Id == Guid.Empty ? null : row;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetActivePlan for {SusId}", susId);
            return null;
        }
    }

    public async Task<ProviderForPlanRow?> GetProviderForPlan(Guid pppId)
    {
        try
        {
            using var conn = _connectionFactory();
            return await conn.QuerySingleOrDefaultAsync<ProviderForPlanRow>(
                "[ai].[ps_Aic_GetProviderForPlan]", new { ppp_Id = pppId }, commandType: CommandType.StoredProcedure);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetProviderForPlan for {PppId}", pppId);
            return null;
        }
    }

    public async Task<RemainingQuotaRow?> GetRemainingQuota(Guid susId)
    {
        try
        {
            using var conn = _connectionFactory();
            return await conn.QuerySingleOrDefaultAsync<RemainingQuotaRow>(
                "[ai].[ps_Aih_RemainingQuota]", new { sus_Id = susId }, commandType: CommandType.StoredProcedure);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetRemainingQuota for {SusId}", susId);
            return null;
        }
    }

    public async Task LogUsage(Guid susId, string sourceCode, Guid? postId, string endpoint,
        int promptTokens, int completionTokens, int totalTokens, string? model, int? latencyMs,
        int httpStatus, bool success, string? errorCode, string? createdBy)
    {
        try
        {
            using var conn = _connectionFactory();
            await conn.ExecuteAsync("[ai].[pi_Aiu_LogUsage]", new
            {
                sus_Id = susId,
                SourceCode = sourceCode,
                PostId = postId,
                Endpoint = endpoint,
                PromptTokens = promptTokens,
                CompletionTokens = completionTokens,
                TotalTokens = totalTokens,
                Model = model,
                LatencyMs = latencyMs,
                HttpStatus = httpStatus,
                Success = success,
                ErrorCode = errorCode,
                CreatedBy = createdBy
            }, commandType: CommandType.StoredProcedure);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in LogUsage for {SusId}", susId);
        }
    }
}
