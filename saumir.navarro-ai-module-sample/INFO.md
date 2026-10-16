# AI text-improvement module (plan-based provider routing + token quota)

Extract from the backend of **Conexta** (ASP.NET Core Web API, Dapper + stored procedures, SQL Server).
The module powers the **"Improve with AI"** feature of the mobile apps: a user writes a post, and the API
asks an LLM to improve it — choosing the provider by subscription plan and enforcing a monthly token quota.

> Sample extract, not a standalone solution. The AI gateway that talks to the LLM providers is a separate
> service and is not included. No keys, secrets, connection strings or real data are in this repo.

## What it does
```
Mobile app ──► Conexta API ──► AiService
                                │ 1. active plan of the account            (stored procedure)
                                │ 2. primary provider configured for plan  (stored procedure)
                                │ 3. remaining monthly token quota         (stored procedure)
                                │ 4. call the AI gateway with the provider already decided
                                └ 5. log real token consumption            (stored procedure)
```
- **Provider per plan.** Each plan maps to a primary (and optional fallback) provider in a database table, so
  routing is a data change, not a deploy. The default idea: free tier → Gemini, paid tiers → other providers.
- **Quota before spending.** The API checks the remaining monthly tokens *before* calling the gateway, and
  records the *actual* usage returned by the gateway afterwards.
- **Stable error codes.** `NO_PLAN | NO_PROVIDER | QUOTA_EXCEEDED | UNREACHABLE | AI_FAILED | EMPTY_RESPONSE`.
  Apps pick the localized message from the code instead of parsing text.
- **Two response shapes.** Regular posts and patient-recruitment posts use different gateway endpoints and
  payloads; each is deserialized with its own type.
- **Failures are contained.** Data-access methods log and return a safe default; a failed usage log never
  breaks the user's request.

## Layout
```
src/Services     AiService — orchestration (plan → provider → quota → gateway → usage log)
src/Contracts    ImprovePostRequest / ImprovePostResponse (DTOs shared with the apps)
src/DataAccess   AiDataAccess — Dapper, one method per stored procedure
sql/             tables (token plan config, usage header/log, provider catalog) and stored procedures
```

## Wiring (example)
`AiService` is a typed HTTP client; the base address of the gateway comes from configuration:
```csharp
builder.Services.AddScoped<AiDataAccess>();
builder.Services.AddHttpClient<AiService>(c => c.BaseAddress = new Uri(builder.Configuration["Ai:BaseUrl"]!));
```
The user's own JWT is forwarded to the gateway, which validates it.

## SQL
Run in order: `01` → `02` → `03` → `04`. Seed data (plans, limits, provider assignment) is intentionally
not included.

## Status
The code compiles inside the full API project.
