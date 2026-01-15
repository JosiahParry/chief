#' Create your Portfolio of TODOs
#'
#' @details
#' By default chief creates a database at `file.path(tools::R_user_dir(package = "chief", "data"), "todo.sqlite3")`.
#'
#' You can override the database path by setting the `CHIEF_PATH` environment variable
#' or setting the option `chief.path` or providing the `path` argument directly.
#'
#' @export
Portfolio <- R6::R6Class(
  "Portfolio",
  private = list(
    path = NULL,
    con = NULL,
    search = NULL
  ),

  public = list(
    #' @description
    #' Create a new Portfolio object.
    #' @param path Optional path to the SQLite database. If NULL, uses the default location.
    #' @return A new `Portfolio` object.
    initialize = function(path = NULL) {
      private$path <- resolve_chief_path(path)
      private$con <- DBI::dbConnect(
        RSQLite::SQLite(),
        dbname = private$path
      )
      self$create()
    },

    #' @description
    #' Create the database schema (categories and todos tables).
    #' @details
    #' This method is called automatically during initialization. It creates the
    #' categories and todos tables if they don't exist, adds the default "other"
    #' category, and initializes the BM25 search engine.
    #' @return Invisible self for method chaining.
    create = function() {
      DBI::dbExecute(
        private$con,
        "
        CREATE TABLE IF NOT EXISTS categories (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT
        );
      "
      )

      DBI::dbExecute(
        private$con,
        "
        CREATE TABLE IF NOT EXISTS todos (
          id TEXT PRIMARY KEY,
          created INTEGER NOT NULL,
          completed INTEGER,
          deadline INTEGER,
          priority INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          tags BLOB,
          category TEXT NOT NULL,
          FOREIGN KEY(category) REFERENCES categories(id)
        );
      "
      )

      # create the default Other category if it is missing
      res <- DBI::dbGetQuery(
        private$con,
        "select id, title, description from categories where title = 'other'"
      )

      if (nrow(res) == 0L) {
        self$add_category(
          new_category(
            "other",
            "Default todo category as a catch all for all tasks."
          )
        )
      }

      # instantiate the search engine
      private$search <- rbm25::BM25$new()

      invisible(self)
    },

    #' @description
    #' Get the database connection object.
    #' @return A DBI database connection.
    connection = function() {
      private$con
    },

    #' @description
    #' Close the database connection.
    #' @return Invisible self for method chaining.
    close = function() {
      if (!is.null(private$con)) {
        DBI::dbDisconnect(private$con)
        private$con <- NULL
      }
      invisible(self)
    },

    #' @description
    #' Add a Todo object to the portfolio.
    #' @param todo A Todo object created with `new_todo()`.
    #' @details
    #' If the todo has no category, the default "other" category is assigned automatically.
    #' The todo is also added to the BM25 search index.
    #' @return The Todo object if successful, otherwise the number of rows affected.
    add_todo = function(todo) {
      check_is_S7(todo, Todo)

      new <- as.data.frame(todo)

      # if the category is missing inject
      if (is.na(new$category)) {
        default_cat <- self$default_category()@id
        new$category <- default_cat
      }

      res <- DBI::dbAppendTable(private$con, "todos", new)

      # if it is successful
      if (res == 1L) {
        private$search$add_data(new$title, new)
        todo
      } else {
        res
      }
    },

    #' @description
    #' Add a Category object to the portfolio.
    #' @param category A Category object created with `new_category()`.
    #' @return The number of rows affected.
    add_category = function(category) {
      check_is_S7(category, Category)
      DBI::dbAppendTable(
        private$con,
        "categories",
        as.data.frame(category)
      )
    },

    #' @description
    #' Get the default "other" category.
    #' @return A Category object.
    default_category = function() {
      res <- DBI::dbGetQuery(
        private$con,
        "select id, title, description from categories where title = 'other'"
      )

      Category(res$id, res$title, res$description)
    },

    #' @description
    #' List all completed todos.
    #' @return A data frame of completed todos with tags parsed from JSON.
    list_completed = function() {
      res <- DBI::dbGetQuery(
        private$con,
        "select * from todos where completed is not null"
      )
      res$tags <- from_jsonb(res$tags)
      res
    },

    #' @description
    #' List all incomplete todos.
    #' @return A data frame of incomplete todos with tags parsed from JSON.
    list_incomplete = function() {
      res <- DBI::dbGetQuery(
        private$con,
        "select * from todos where completed is null"
      )
      res$tags <- from_jsonb(res$tags)
      res
    },

    #' @description
    #' List all todos (completed and incomplete).
    #' @return A data frame of all todos with tags parsed from JSON.
    list_all = function() {
      res <- DBI::dbGetQuery(
        private$con,
        "select * from todos"
      )
      res$tags <- from_jsonb(res$tags)
      res
    },

    #' @description
    #' Retrieve a specific todo by its ULID.
    #' @param id The ULID of the todo to retrieve.
    #' @return A Todo object.
    get_todo = function(id) {
      todo <- DBI::dbGetQuery(
        private$con,
        "select * from todos where id = ?",
        params = list(id)
      )

      todo_from_row(todo)
    },

    #' @description
    #' NOT YET IMPLEMENTED
    #' Get the BM25 search engine object.
    #' @return The BM25 search engine object.
    search_engine = function() {
      private$search
    },

    #' @description
    #' Mark a todo as completed.
    #' @param id The ULID of the todo to mark as complete.
    #' @return The number of rows affected.
    mark_complete = function(id) {
      DBI::dbExecute(
        private$con,
        "UPDATE todos SET completed = ? WHERE id = ?",
        params = list(Sys.time(), id)
      )
    },

    #' @description
    #' Delete a todo by its ULID.
    #' @param id The ULID of the todo to delete.
    #' @return The number of rows affected.
    delete_todo = function(id) {
      DBI::dbExecute(
        private$con,
        "DELETE FROM todos WHERE id = ?",
        params = list(id)
      )
    },

    #' @description
    #' Update one or more fields of an existing todo.
    #' @param id The ULID of the todo to update.
    #' @param priority New priority level (1-5).
    #' @param deadline New deadline as POSIXct.
    #' @param title New title.
    #' @param description New description.
    #' @param tags New tags as a character vector.
    #' @param category New category ULID.
    #' @return The number of rows affected.
    update_todo = function(
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
    },

    #' @description
    #' List all categories.
    #' @return A data frame of all categories.
    list_categories = function() {
      DBI::dbGetQuery(private$con, "SELECT * FROM categories")
    },

    #' @description
    #' Retrieve a specific category by its ULID.
    #' @param id The ULID of the category to retrieve.
    #' @return A Category object.
    get_category = function(id) {
      cat <- DBI::dbGetQuery(
        private$con,
        "SELECT * FROM categories WHERE id = ?",
        params = list(id)
      )
      category_from_row(cat)
    },

    #' @description
    #' Update one or more fields of an existing category.
    #' @param id The ULID of the category to update.
    #' @param title New title.
    #' @param description New description.
    #' @return The number of rows affected.
    update_category = function(id, title = NULL, description = NULL) {
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
  )
)

resolve_chief_path <- function(path = NULL) {
  if (is.null(path)) {
    path <- Sys.getenv(
      "CHIEF_PATH",
      unset = getOption(
        "chief.path",
        file.path(tools::R_user_dir(package = "chief", "data"), "todo.sqlite3")
      )
    )
  }

  if (!file.exists(path)) {
    cli::cli_alert("Creating database at {.path {path}}")
    dir.create(dirname(path), recursive = TRUE)
    file.create(path)
  }
  path
}
