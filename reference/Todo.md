# Todo S7 Class

An S7 class representing a todo item with metadata including creation
time, completion status, deadline, priority, title, description, tags,
and category.

## Usage

``` r
Todo(
  id = "01KETGSZVZQYSQ2ZVET4E1ZV71",
  created = (function (.data = double(), tz = "") 
 {
     .POSIXct(.data, tz = tz)
 })(),
  completed = (function (.data = double(), tz = "") 
 {
     .POSIXct(.data, tz = tz)

    })(),
  deadline = (function (.data = double(), tz = "") 
 {
     .POSIXct(.data, tz = tz)

    })(),
  priority = integer(0),
  title = character(0),
  description = character(0),
  tags = character(0),
  category = "01KETGSZVZQYSQ2ZVET4E1ZV71"
)
```

## Arguments

- id:

  ULID unique identifier for the todo.

- created:

  POSIXct timestamp when the todo was created.

- completed:

  POSIXct timestamp when the todo was completed (NA if incomplete).

- deadline:

  POSIXct deadline for the todo (NA if no deadline).

- priority:

  Integer priority level from 1 (lowest) to 5 (highest).

- title:

  Character title of the todo.

- description:

  Character description of the todo.

- tags:

  Character vector of tags for categorization.

- category:

  ULID of the category this todo belongs to.
