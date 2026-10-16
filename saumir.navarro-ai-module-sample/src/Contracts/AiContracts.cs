namespace Conexta.Contracts.Ai;

public class ImprovePostRequest
{
    public string PtyCode { get; set; } = string.Empty;
    public string Locale { get; set; } = "es";
    public string? Matter { get; set; }
    public string? Description { get; set; }
    public double? Price { get; set; }
    public string? Instruction { get; set; }
    public string InputKind { get; set; } = "text";
    public Guid? PostId { get; set; }
}

public class ImprovePostResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public string? ImprovedMatter { get; set; }
    public string? ImprovedDescription { get; set; }

    /// <summary>
    /// Stable error code (null if Success). Client apps use it to pick the text in the user's language
    /// instead of parsing Message: NO_PLAN | NO_PROVIDER | QUOTA_EXCEEDED | UNREACHABLE | AI_FAILED | EMPTY_RESPONSE.
    /// </summary>
    public string? ErrorCode { get; set; }
}
