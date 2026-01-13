# Create your Portfolio of TODOs

Create your Portfolio of TODOs

Create your Portfolio of TODOs

## Details

By default chief creates a database at
`file.path(tools::R_user_dir(package = "chief", "data"), "todo.sqlite3")`.

You can override the database path by setting the `CHIEF_PATH`
environment variable or setting the option `chief.path` or providing the
`path` argument directly.

## Methods

### Public methods

- [`Portfolio$new()`](#method-Portfolio-new)

- [`Portfolio$create()`](#method-Portfolio-create)

- [`Portfolio$connection()`](#method-Portfolio-connection)

- [`Portfolio$close()`](#method-Portfolio-close)

- [`Portfolio$add_todo()`](#method-Portfolio-add_todo)

- [`Portfolio$add_category()`](#method-Portfolio-add_category)

- [`Portfolio$default_category()`](#method-Portfolio-default_category)

- [`Portfolio$list_completed()`](#method-Portfolio-list_completed)

- [`Portfolio$list_incomplete()`](#method-Portfolio-list_incomplete)

- [`Portfolio$list_all()`](#method-Portfolio-list_all)

- [`Portfolio$get_todo()`](#method-Portfolio-get_todo)

- [`Portfolio$search_engine()`](#method-Portfolio-search_engine)

- [`Portfolio$mark_complete()`](#method-Portfolio-mark_complete)

- [`Portfolio$delete_todo()`](#method-Portfolio-delete_todo)

- [`Portfolio$update_todo()`](#method-Portfolio-update_todo)

- [`Portfolio$list_categories()`](#method-Portfolio-list_categories)

- [`Portfolio$get_category()`](#method-Portfolio-get_category)

- [`Portfolio$update_category()`](#method-Portfolio-update_category)

- [`Portfolio$clone()`](#method-Portfolio-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new Portfolio object.

#### Usage

    Portfolio$new(path = NULL)

#### Arguments

- `path`:

  Optional path to the SQLite database. If NULL, uses the default
  location.

#### Returns

A new `Portfolio` object.

------------------------------------------------------------------------

### Method `create()`

Create the database schema (categories and todos tables).

#### Usage

    Portfolio$create()

#### Details

This method is called automatically during initialization. It creates
the categories and todos tables if they don't exist, adds the default
"other" category, and initializes the BM25 search engine.

#### Returns

Invisible self for method chaining.

------------------------------------------------------------------------

### Method `connection()`

Get the database connection object.

#### Usage

    Portfolio$connection()

#### Returns

A DBI database connection.

------------------------------------------------------------------------

### Method [`close()`](https://rdrr.io/r/base/connections.html)

Close the database connection.

#### Usage

    Portfolio$close()

#### Returns

Invisible self for method chaining.

------------------------------------------------------------------------

### Method `add_todo()`

Add a Todo object to the portfolio.

#### Usage

    Portfolio$add_todo(todo)

#### Arguments

- `todo`:

  A Todo object created with
  [`new_todo()`](https://josiahparry.github.io/chief/reference/new_todo.md).

#### Details

If the todo has no category, the default "other" category is assigned
automatically. The todo is also added to the BM25 search index.

#### Returns

The Todo object if successful, otherwise the number of rows affected.

------------------------------------------------------------------------

### Method `add_category()`

Add a Category object to the portfolio.

#### Usage

    Portfolio$add_category(category)

#### Arguments

- `category`:

  A Category object created with
  [`new_category()`](https://josiahparry.github.io/chief/reference/new_category.md).

#### Returns

The number of rows affected.

------------------------------------------------------------------------

### Method `default_category()`

Get the default "other" category.

#### Usage

    Portfolio$default_category()

#### Returns

A Category object.

------------------------------------------------------------------------

### Method `list_completed()`

List all completed todos.

#### Usage

    Portfolio$list_completed()

#### Returns

A data frame of completed todos with tags parsed from JSON.

------------------------------------------------------------------------

### Method `list_incomplete()`

List all incomplete todos.

#### Usage

    Portfolio$list_incomplete()

#### Returns

A data frame of incomplete todos with tags parsed from JSON.

------------------------------------------------------------------------

### Method `list_all()`

List all todos (completed and incomplete).

#### Usage

    Portfolio$list_all()

#### Returns

A data frame of all todos with tags parsed from JSON.

------------------------------------------------------------------------

### Method `get_todo()`

Retrieve a specific todo by its ULID.

#### Usage

    Portfolio$get_todo(id)

#### Arguments

- `id`:

  The ULID of the todo to retrieve.

#### Returns

A Todo object.

------------------------------------------------------------------------

### Method `search_engine()`

NOT YET IMPLEMENTED Get the BM25 search engine object.

#### Usage

    Portfolio$search_engine()

#### Returns

The BM25 search engine object.

------------------------------------------------------------------------

### Method `mark_complete()`

Mark a todo as completed.

#### Usage

    Portfolio$mark_complete(id)

#### Arguments

- `id`:

  The ULID of the todo to mark as complete.

#### Returns

The number of rows affected.

------------------------------------------------------------------------

### Method `delete_todo()`

Delete a todo by its ULID.

#### Usage

    Portfolio$delete_todo(id)

#### Arguments

- `id`:

  The ULID of the todo to delete.

#### Returns

The number of rows affected.

------------------------------------------------------------------------

### Method `update_todo()`

Update one or more fields of an existing todo.

#### Usage

    Portfolio$update_todo(
      id,
      priority = NULL,
      deadline = NULL,
      title = NULL,
      description = NULL,
      tags = NULL,
      category = NULL
    )

#### Arguments

- `id`:

  The ULID of the todo to update.

- `priority`:

  New priority level (1-5).

- `deadline`:

  New deadline as POSIXct.

- `title`:

  New title.

- `description`:

  New description.

- `tags`:

  New tags as a character vector.

- `category`:

  New category ULID.

#### Returns

The number of rows affected.

------------------------------------------------------------------------

### Method `list_categories()`

List all categories.

#### Usage

    Portfolio$list_categories()

#### Returns

A data frame of all categories.

------------------------------------------------------------------------

### Method `get_category()`

Retrieve a specific category by its ULID.

#### Usage

    Portfolio$get_category(id)

#### Arguments

- `id`:

  The ULID of the category to retrieve.

#### Returns

A Category object.

------------------------------------------------------------------------

### Method `update_category()`

Update one or more fields of an existing category.

#### Usage

    Portfolio$update_category(id, title = NULL, description = NULL)

#### Arguments

- `id`:

  The ULID of the category to update.

- `title`:

  New title.

- `description`:

  New description.

#### Returns

The number of rows affected.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Portfolio$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
