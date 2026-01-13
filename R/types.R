#' ULID Property
#'
#' An S7 property for Universally Unique Lexicographically Sortable Identifiers (ULIDs).
#' ULIDs are 26-character strings that are sortable by timestamp.
#'
#' @export
Ulid <- new_property(
  class_character,
  validator = function(value) {
    if (!is.na(value)) {
      stopifnot(
        "must be a scalar character" = length(value) == 1,
        "ulids are 26 characters" = nchar(value) == 26
      )
    }
  },
  default = ulid::ulid()
)

#' Todo S7 Class
#'
#' An S7 class representing a todo item with metadata including creation time,
#' completion status, deadline, priority, title, description, tags, and category.
#'
#' @param id ULID unique identifier for the todo.
#' @param created POSIXct timestamp when the todo was created.
#' @param completed POSIXct timestamp when the todo was completed (NA if incomplete).
#' @param deadline POSIXct deadline for the todo (NA if no deadline).
#' @param priority Integer priority level from 1 (lowest) to 5 (highest).
#' @param title Character title of the todo.
#' @param description Character description of the todo.
#' @param tags Character vector of tags for categorization.
#' @param category ULID of the category this todo belongs to.
#' @export
Todo <- S7::new_class(
  "Todo",
  properties = list(
    id = Ulid,
    created = class_POSIXct,
    completed = class_POSIXct,
    deadline = class_POSIXct,
    priority = class_integer,
    title = class_character,
    description = class_character,
    tags = class_character,
    category = Ulid
  ),
  package = "chief",
  validator = function(self) {
    stopifnot(
      "priority must be in the range of [1, 5]" = !(self@priority > 5 ||
        self@priority < 1)
    )
    NULL
  },
)

#' Create a new Todo object
#'
#' @param title The title of the todo (required).
#' @param description Optional description of the todo.
#' @param completed POSIXct timestamp when completed (default: NA).
#' @param deadline POSIXct deadline for the todo (default: NA).
#' @param priority Priority level from 1 (lowest) to 5 (highest) (default: 3).
#' @param tags Character vector of tags (default: empty).
#' @param category ULID of the category (default: NA, will use default category).
#' @return A new Todo object.
#' @export
new_todo <- function(
  title,
  description = NA_character_,
  completed = as.POSIXct(NA),
  deadline = as.POSIXct(NA),
  priority = 3L,
  tags = character(0),
  category = NA_character_
) {
  Todo(
    id = ulid::ulid(),
    created = Sys.time(),
    completed = completed,
    deadline = deadline,
    priority = as.integer(priority),
    title = title,
    description = description,
    tags = tags,
    category = category
  )
}

#' Category S7 Class
#'
#' An S7 class representing a category for organizing todos.
#'
#' @param id ULID unique identifier for the category.
#' @param title Character title of the category.
#' @param description Character description of the category.
#' @export
Category <- S7::new_class(
  "Category",
  package = "chief",
  properties = list(
    id = Ulid,
    title = class_character,
    description = class_character
  ),
  validator = function(self) {
    check_string(self@title)
    check_string(self@description, allow_null = TRUE, allow_na = TRUE)
    NULL
  }
)

#' Create a new Category object
#'
#' @param title The title of the category (required).
#' @param description Optional description of the category.
#' @return A new Category object.
#' @export
new_category <- function(title, description = NA_character_) {
  Category(
    id = ulid::ulid(),
    title = title,
    description = description
  )
}
# data.frame methods -----------------------------------------------------

#' @export
method(as.data.frame, Todo) <- function(x, ...) {
  as.data.frame(compact(list(
    id = x@id,
    created = x@created,
    completed = x@completed,
    deadline = x@deadline,
    priority = x@priority,
    title = x@title,
    description = x@description,
    tags = as_jsonb(list(x@tags)),
    category = x@category
  )))
}

#' @export
method(as.data.frame, Category) <- function(x, ...) {
  as.data.frame(compact(list(
    id = x@id,
    title = x@title,
    description = x@description
  )))
}


todo_from_row <- function(row) {
  Todo(
    id = row$id,
    created = as.POSIXct(row$created),
    completed = as.POSIXct(row$completed),
    deadline = as.POSIXct(row$deadline),
    priority = as.integer(row$priority),
    title = row$title,
    description = row$description,
    tags = from_jsonb_value(row$tags),
    category = row$category
  )
}

category_from_row <- function(row) {
  Category(
    id = row$id,
    title = row$title,
    description = row$description
  )
}
