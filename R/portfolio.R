#' @export
Portfolio <- R6::R6Class(
  "Portfolio",
  private = list(
    path = NULL,
    con = NULL,
    search = NULL
  ),

  public = list(
    initialize = function(path = NULL) {
      private$path <- resolve_chief_path(path)
      private$con <- DBI::dbConnect(
        RSQLite::SQLite(),
        dbname = private$path
      )
      self$create()
    },

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

      # insert a default category of "other"
      self$add_category(new_category("other"))

      # instantiate the search engine
      private$search <- rbm25::BM25$new()

      invisible(self)
    },

    connection = function() {
      private$con
    },

    close = function() {
      if (!is.null(private$con)) {
        DBI::dbDisconnect(private$con)
        private$con <- NULL
      }
      invisible(self)
    },
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

    add_category = function(category) {
      check_is_S7(category, Category)
      DBI::dbAppendTable(
        private$con,
        "categories",
        as.data.frame(category)
      )
    },

    default_category = function() {
      res <- DBI::dbGetQuery(
        private$con,
        "select id, title, description from categories where title = 'other'"
      )

      Category(res$id, res$title, res$description)
    },
    list_completed = function() {
      res <- DBI::dbGetQuery(
        private$con,
        "select * from todos where completed is not null"
      )
      res$tags <- from_jsonb(res$tags)
      res
    },

    list_incomplete = function() {
      res <- DBI::dbGetQuery(
        private$con,
        "select * from todos where completed is null"
      )
      res$tags <- from_jsonb(res$tags)
      res
    },

    list_all = function() {
      res <- DBI::dbGetQuery(
        private$con,
        "select * from todos"
      )
      res$tags <- from_jsonb(res$tags)
      res
    },

    get_todo = function(id) {
      todo <- DBI::dbGetQuery(
        private$con,
        "select * from todos where id = ?",
        params = list(id)
      )

      todo_from_row(todo)
    },

    build_search = function() {
      todos <- self$list_all()
      private$search$add_data(todos$title, todos)
    },

    search_engine = function() {
      private$search
    },

    mark_complete = mark_complete,
    delete_todo = delete_todo,
    update_todo = update_todo,
    list_categories = list_categories,
    get_category = get_category,
    update_category = update_category
  )
)

resolve_chief_path <- function(path = NULL) {
  env <- Sys.getenv("CHIEF_PATH", unset = NA_character_)
  if (!is.na(env) && nzchar(env)) {
    return(env)
  }

  opt <- getOption("chief.path")
  if (!is.null(opt) && nzchar(opt)) {
    return(opt)
  }

  if (!is.null(path) && nzchar(path)) {
    return(path)
  }

  ":memory:"
}
