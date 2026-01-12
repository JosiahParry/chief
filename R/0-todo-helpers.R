# Status Updates --------------------------------------------------------

mark_complete <- function(id) {
  DBI::dbExecute(
    private$con,
    "UPDATE todos SET completed = ? WHERE id = ?",
    params = list(Sys.time(), id)
  )
}

delete_todo <- function(id) {
  DBI::dbExecute(
    private$con,
    "DELETE FROM todos WHERE id = ?",
    params = list(id)
  )
}

update_todo <- function(
  id,
  priority = NULL,
  deadline = NULL,
  title = NULL,
  description = NULL,
  tags = NULL,
  category = NULL
) {
  updates <- list()
  params <- list()

  if (!is.null(priority)) {
    updates <- c(updates, "priority = ?")
    params <- c(params, list(as.integer(priority)))
  }

  if (!is.null(deadline)) {
    updates <- c(updates, "deadline = ?")
    params <- c(params, list(deadline))
  }

  if (!is.null(title)) {
    updates <- c(updates, "title = ?")
    params <- c(params, list(title))
  }

  if (!is.null(description)) {
    updates <- c(updates, "description = ?")
    params <- c(params, list(description))
  }

  if (!is.null(tags)) {
    updates <- c(updates, "tags = ?")
    params <- c(params, list(as_jsonb(list(tags))))
  }

  if (!is.null(category)) {
    updates <- c(updates, "category = ?")
    params <- c(params, list(category))
  }

  if (length(updates) == 0) {
    return(0L)
  }

  params <- c(params, list(id))
  sql <- paste0(
    "UPDATE todos SET ",
    paste(updates, collapse = ", "),
    " WHERE id = ?"
  )

  DBI::dbExecute(private$con, sql, params = params)
}

# Category Management ---------------------------------------------------

list_categories <- function() {
  DBI::dbGetQuery(private$con, "SELECT * FROM categories")
}

get_category <- function(id) {
  cat <- DBI::dbGetQuery(
    private$con,
    "SELECT * FROM categories WHERE id = ?",
    params = list(id)
  )
  category_from_row(cat)
}

update_category <- function(id, title = NULL, description = NULL) {
  updates <- list()
  params <- list()

  if (!is.null(title)) {
    updates <- c(updates, "title = ?")
    params <- c(params, list(title))
  }

  if (!is.null(description)) {
    updates <- c(updates, "description = ?")
    params <- c(params, list(description))
  }

  if (length(updates) == 0) {
    return(0L)
  }

  params <- c(params, list(id))
  sql <- paste0(
    "UPDATE categories SET ",
    paste(updates, collapse = ", "),
    " WHERE id = ?"
  )

  DBI::dbExecute(private$con, sql, params = params)
}

# Query / Retrieval
# -----------------
# list all todos (with optional filters)
# list incomplete todos ordered by deadline
# list incomplete todos ordered by priority
# list todos by category
# list todos by tag(s)
# list overdue todos (deadline passed, not completed)
# list todos due today
# list todos due this week
# list completed todos (with optional date range)
# search todos by title/description (fuzzy search)

# Status Updates
# --------------
# mark a todo incomplete (reopen/undo completion)
# mark multiple todos complete (bulk operation)

# Modification
# ------------
# reschedule todo (move deadline by X days/weeks)

# Management
# ----------
# delete multiple todos (bulk operation)
# archive completed todos (move to archive table or mark archived)

# Reporting / Analytics
# ---------------------
# todo summary statistics (total, completed, pending, by priority)
# completion rate (overall or by time period)
# category breakdown (count by category)
# upcoming deadlines (next N todos by deadline)
# priority distribution
# productivity report (completed todos by day/week/month)

# Smart Queries
# -------------
# get_focus() - top priority incomplete todos (e.g., top 3-5)
# get_today_agenda() - todos due today + overdue + high priority
# get_week_ahead() - todos due in next 7 days
