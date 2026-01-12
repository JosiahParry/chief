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

new_category <- function(title, description = NA_character_) {
  Category(
    id = ulid::ulid(),
    title = title,
    description = description
  )
}
# data.frame methods -----------------------------------------------------

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
