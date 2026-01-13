devtools::load_all()

folio <- Portfolio$new(":memory:")

# Add categories
work_cat <- new_category("Work", "Work-related tasks and projects")
folio$add_category(work_cat)

personal_cat <- new_category("Personal", "Personal tasks and errands")
folio$add_category(personal_cat)

finance_cat <- new_category("Finance", "Budget, bills, and financial planning")
folio$add_category(finance_cat)

# Add todos
todo1 <- new_todo(
  title = "Review Q4 budget",
  description = "Analyze spending and prepare financial report",
  priority = 5L,
  deadline = Sys.time() + 86400 * 7,
  tags = c("urgent", "finance"),
  category = finance_cat@id
)
folio$add_todo(todo1)

todo2 <- new_todo(
  title = "Dentist appointment",
  description = "Annual checkup and cleaning",
  priority = 3L,
  deadline = Sys.time() + 86400 * 3,
  tags = c("health", "appointment"),
  category = personal_cat@id
)
folio$add_todo(todo2)

todo3 <- new_todo(
  title = "Prepare presentation",
  description = "Create slides for Monday team meeting",
  priority = 4L,
  deadline = Sys.time() + 86400 * 2,
  tags = c("meeting", "presentation"),
  category = work_cat@id
)
folio$add_todo(todo3)

todo4 <- new_todo(
  title = "Buy groceries",
  priority = 2L,
  tags = c("shopping", "food"),
  category = personal_cat@id
)
folio$add_todo(todo4)

todo5 <- new_todo(
  title = "Code review for PR #123",
  description = "Review authentication refactor",
  priority = 4L,
  deadline = Sys.time() + 86400,
  tags = c("code-review", "urgent"),
  category = work_cat@id
)
folio$add_todo(todo5)

# Test functions
folio$list_all()
folio$list_incomplete()
folio$list_categories()

single_todo <- folio$get_todo(todo1@id)
single_cat <- folio$get_category(work_cat@id)

folio$mark_complete(todo4@id)
folio$list_incomplete()
folio$list_completed()

folio$update_todo(
  todo2@id,
  priority = 5L,
  tags = c("health", "appointment", "urgent")
)


folio$get_todo(todo2@id)

folio$update_category(
  finance_cat@id,
  description = "Financial planning and budget tracking"
)
folio$get_category(finance_cat@id)

folio$delete_todo(todo5@id)
folio$list_all()
