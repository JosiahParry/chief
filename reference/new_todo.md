# Create a new Todo object

Create a new Todo object

## Usage

``` r
new_todo(
  title,
  description = NA_character_,
  completed = as.POSIXct(NA),
  deadline = as.POSIXct(NA),
  priority = 3L,
  tags = character(0),
  category = NA_character_
)
```

## Arguments

- title:

  The title of the todo (required).

- description:

  Optional description of the todo.

- completed:

  POSIXct timestamp when completed (default: NA).

- deadline:

  POSIXct deadline for the todo (default: NA).

- priority:

  Priority level from 1 (lowest) to 5 (highest) (default: 3).

- tags:

  Character vector of tags (default: empty).

- category:

  ULID of the category (default: NA, will use default category).

## Value

A new Todo object.
