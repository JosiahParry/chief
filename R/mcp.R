#' Create MCP Server for Portfolio
#'
#' Creates an MCP server that exposes Portfolio methods as tools for managing
#' todos and categories via the Model Context Protocol.
#'
#' @param path Optional path to the SQLite database. If NULL, uses
#'   `resolve_chief_path()` to find the database location.
#' @return An MCP server object
#' @export
chief_mcp_server <- function(path = NULL) {
  portfolio <- Portfolio$new(path)

  tool_add_todo <- mcpr::new_tool(
    name = "add_todo",
    description = "Create a new todo item",
    input_schema = mcpr::schema(
      properties = mcpr::properties(
        title = mcpr::property_string(
          "Title",
          "The todo title",
          required = TRUE
        ),
        description = mcpr::property_string(
          "Description",
          "Detailed description of the todo",
          required = FALSE
        ),
        deadline = mcpr::property_string(
          "Deadline",
          "Deadline as ISO 8601 date string (e.g., '2026-01-15')",
          required = FALSE
        ),
        priority = mcpr::property_number(
          "Priority",
          "Priority level from 1 (lowest) to 5 (highest)",
          required = FALSE
        ),
        tags = mcpr::property_array(
          "Tags",
          "List of tags for categorization",
          items = mcpr::property_string("Tag", "A tag string"),
          required = FALSE
        ),
        category = mcpr::property_string(
          "Category",
          "Category ID (ULID) for the todo",
          required = FALSE
        )
      )
    ),
    handler = function(params) {
      args <- list(title = params$title)
      if (!is.null(params$description)) {
        args$description <- params$description
      }
      if (!is.null(params$deadline)) {
        args$deadline <- as.POSIXct(params$deadline)
      }
      if (!is.null(params$priority)) {
        args$priority <- as.integer(params$priority)
      }
      if (!is.null(params$tags)) {
        args$tags <- unlist(params$tags)
      }
      if (!is.null(params$category)) {
        args$category <- params$category
      }

      todo <- do.call(new_todo, args)
      result <- portfolio$add_todo(todo)

      mcpr::response_text(paste0("Successfully added todo with ID: ", todo@id))
    }
  )

  resource_get_todo <- mcpr::new_resource(
    name = "Todo by ID",
    description = "Retrieve a specific todo by ID",
    uri = "chief://todos/{id}",
    mime_type = "application/json",
    handler = function(params) {
      todo <- portfolio$get_todo(params$id)
      mcpr::response(as.data.frame(todo))
    }
  )

  # Tool 3: Update Todo
  tool_update_todo <- mcpr::new_tool(
    name = "update_todo",
    description = "Update fields of an existing todo",
    input_schema = mcpr::schema(
      properties = mcpr::properties(
        id = mcpr::property_string(
          "ID",
          "The ULID of the todo to update",
          required = TRUE
        ),
        title = mcpr::property_string(
          "Title",
          "New title for the todo",
          required = FALSE
        ),
        description = mcpr::property_string(
          "Description",
          "New description",
          required = FALSE
        ),
        deadline = mcpr::property_string(
          "Deadline",
          "New deadline as ISO 8601 date string",
          required = FALSE
        ),
        priority = mcpr::property_number(
          "Priority",
          "New priority level (1-5)",
          required = FALSE
        ),
        tags = mcpr::property_array(
          "Tags",
          "New list of tags",
          items = mcpr::property_string("Tag", "A tag string"),
          required = FALSE
        ),
        category = mcpr::property_string(
          "Category",
          "New category ID",
          required = FALSE
        )
      )
    ),
    handler = function(params) {
      args <- list(id = params$id)
      if (!is.null(params$title)) {
        args$title <- params$title
      }
      if (!is.null(params$description)) {
        args$description <- params$description
      }
      if (!is.null(params$deadline)) {
        args$deadline <- as.POSIXct(params$deadline)
      }
      if (!is.null(params$priority)) {
        args$priority <- as.integer(params$priority)
      }
      if (!is.null(params$tags)) {
        args$tags <- unlist(params$tags)
      }
      if (!is.null(params$category)) {
        args$category <- params$category
      }

      result <- do.call(portfolio$update_todo, args)
      mcpr::response_text(paste0("Updated ", result, " row(s)"))
    }
  )

  tool_delete_todo <- mcpr::new_tool(
    name = "delete_todo",
    description = "Delete a todo by ID",
    input_schema = mcpr::schema(
      properties = mcpr::properties(
        id = mcpr::property_string(
          "ID",
          "The ULID of the todo to delete",
          required = TRUE
        )
      )
    ),
    handler = function(params) {
      result <- portfolio$delete_todo(params$id)
      mcpr::response_text(paste0("Deleted ", result, " row(s)"))
    }
  )

  tool_mark_complete <- mcpr::new_tool(
    name = "mark_complete",
    description = "Mark a todo as completed",
    input_schema = mcpr::schema(
      properties = mcpr::properties(
        id = mcpr::property_string(
          "ID",
          "The ULID of the todo to mark complete",
          required = TRUE
        )
      )
    ),
    handler = function(params) {
      result <- portfolio$mark_complete(params$id)
      mcpr::response_text(paste0(
        "Successfully marked todo ",
        params$id,
        " as complete"
      ))
    }
  )

  resource_list_all <- mcpr::new_resource(
    name = "All Todos",
    description = "List all todos (completed and incomplete)",
    uri = "chief://todos/all",
    mime_type = "application/json",
    handler = function(params) {
      result <- portfolio$list_all()
      mcpr::response(result)
    }
  )

  resource_list_incomplete <- mcpr::new_resource(
    name = "Incomplete Todos",
    description = "List all incomplete todos",
    uri = "chief://todos/incomplete",
    mime_type = "application/json",
    handler = function(params) {
      result <- portfolio$list_incomplete()
      mcpr::response(result)
    }
  )

  resource_list_completed <- mcpr::new_resource(
    name = "Completed Todos",
    description = "List all completed todos",
    uri = "chief://todos/completed",
    mime_type = "application/json",
    handler = function(params) {
      result <- portfolio$list_completed()
      mcpr::response(result)
    }
  )

  # Tool 9: Add Category
  tool_add_category <- mcpr::new_tool(
    name = "add_category",
    description = "Create a new category",
    input_schema = mcpr::schema(
      properties = mcpr::properties(
        title = mcpr::property_string(
          "Title",
          "The category title",
          required = TRUE
        ),
        description = mcpr::property_string(
          "Description",
          "Description of the category",
          required = FALSE
        )
      )
    ),
    handler = function(params) {
      args <- list(title = params$title)
      if (!is.null(params$description)) {
        args$description <- params$description
      }

      category <- do.call(new_category, args)
      result <- portfolio$add_category(category)

      mcpr::response_text(paste0(
        "Successfully added category with ID: ",
        category@id
      ))
    }
  )

  # Resource: Get Category
  resource_get_category <- mcpr::new_resource(
    name = "Category by ID",
    description = "Retrieve a specific category by ID",
    uri = "chief://categories/{id}",
    mime_type = "application/json",
    handler = function(params) {
      category <- portfolio$get_category(params$id)
      mcpr::response(as.data.frame(category))
    }
  )

  # Tool 11: Update Category
  tool_update_category <- mcpr::new_tool(
    name = "update_category",
    description = "Update fields of an existing category",
    input_schema = mcpr::schema(
      properties = mcpr::properties(
        id = mcpr::property_string(
          "ID",
          "The ULID of the category to update",
          required = TRUE
        ),
        title = mcpr::property_string(
          "Title",
          "New title for the category",
          required = FALSE
        ),
        description = mcpr::property_string(
          "Description",
          "New description",
          required = FALSE
        )
      )
    ),
    handler = function(params) {
      args <- list(id = params$id)
      if (!is.null(params$title)) {
        args$title <- params$title
      }
      if (!is.null(params$description)) {
        args$description <- params$description
      }

      result <- do.call(portfolio$update_category, args)
      mcpr::response_text(paste0("Updated ", result, " row(s)"))
    }
  )

  # Resource: List Categories
  resource_list_categories <- mcpr::new_resource(
    name = "All Categories",
    description = "List all categories",
    uri = "chief://categories",
    mime_type = "application/json",
    handler = function(params) {
      result <- portfolio$list_categories()
      mcpr::response(result)
    }
  )

  # Create MCP server
  mcp <- mcpr::new_server(
    name = "Chief Portfolio Server",
    description = "MCP server for managing todos and categories",
    version = as.character(utils::packageVersion("chief"))
  )

  # Add tools (write operations)
  mcp <- mcpr::add_capability(mcp, tool_add_todo)
  mcp <- mcpr::add_capability(mcp, tool_update_todo)
  mcp <- mcpr::add_capability(mcp, tool_delete_todo)
  mcp <- mcpr::add_capability(mcp, tool_mark_complete)
  mcp <- mcpr::add_capability(mcp, tool_add_category)
  mcp <- mcpr::add_capability(mcp, tool_update_category)

  # Add resources (read operations)
  mcp <- mcpr::add_capability(mcp, resource_get_todo)
  mcp <- mcpr::add_capability(mcp, resource_list_all)
  mcp <- mcpr::add_capability(mcp, resource_list_incomplete)
  mcp <- mcpr::add_capability(mcp, resource_list_completed)
  mcp <- mcpr::add_capability(mcp, resource_get_category)
  mcp <- mcpr::add_capability(mcp, resource_list_categories)

  mcp
}
