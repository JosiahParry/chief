# chief

`chief` is an R package to be your personal chief of staff. Combining
traditional TODO tracking with AI agent behavior.

We use a sqlite3 database. Tables

- `todos`:
  - id (required—ulid)
  - created (required i64 ms since unix epoch, default is now)
  - completed (optional i64 ms since unix epoch) — null = undone, value
    = done
  - deadline (optional i64 ms since unix epoch)
  - priority (range 1 - 5, required default 3)
  - title (text, required)
  - description (text, optional)
  - tags (jsonb array of text free-formed, optional)
  - category (is a ulid id, required, default is personal)
- `category`:
  - `id` (required-ulid)
  - `title`: (required, text cannot exceed 256 characters)
  - `description`: (optional, text, used for providing AI context about
    the category)

## Code Style

**Bare minimum approach:** \* Do the bare minimum; no over-engineering
\* Use existing methods instead of rewriting logic \* Trust libraries to
handle their domain (DBI for dates, yyjsonr for JSON) \* No premature
optimization \* Remove completed TODOs from planning docs immediately

**Development approach:** \* Read and understand existing code before
suggesting changes \* Separate concerns: helpers in todo-helpers.R,
compose into R6 Portfolio \* Focus on the specific task; don’t drift
into unrelated design concerns \* When told “restart your thinking”,
step back and reconsider priorities

**Communication:** \* Be concise; no lengthy explanations unless asked
\* Don’t mention system reminders or housekeeping to user \* Ask
clarifying questions when genuinely uncertain \* Accept corrections
without defending the original approach
