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

  tool_get_todo <- mcpr::new_tool(
    name = "get_todo",
    description = "Retrieve a specific todo by ID",
    input_schema = mcpr::schema(
      properties = mcpr::properties(
        id = mcpr::property_string(
          "ID",
          "The ULID of the todo to retrieve",
          required = TRUE
        )
      )
    ),
    handler = function(params) {
      todo <- portfolio$get_todo(params$id)
      mcpr::response_text(as.data.frame(todo))
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

  tool_list_all <- mcpr::new_tool(
    name = "list_all",
    description = "List all todos (completed and incomplete)",
    input_schema = mcpr::schema(
      properties = setNames(list(), character())
    ),
    handler = function(params) {
      result <- portfolio$list_all()
      mcpr::response_text(result)
    }
  )

  tool_list_incomplete <- mcpr::new_tool(
    name = "list_incomplete",
    description = "List all incomplete todos",
    input_schema = mcpr::schema(
      properties = setNames(list(), character())
    ),
    handler = function(params) {
      result <- portfolio$list_incomplete()
      mcpr::response_text(result)
    }
  )

  tool_list_completed <- mcpr::new_tool(
    name = "list_completed",
    description = "List all completed todos",
    input_schema = mcpr::schema(
      properties = setNames(list(), character())
    ),
    handler = function(params) {
      result <- portfolio$list_completed()
      mcpr::response_text(result)
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

  # Tool 10: Get Category
  tool_get_category <- mcpr::new_tool(
    name = "get_category",
    description = "Retrieve a specific category by ID",
    input_schema = mcpr::schema(
      properties = mcpr::properties(
        id = mcpr::property_string(
          "ID",
          "The ULID of the category to retrieve",
          required = TRUE
        )
      )
    ),
    handler = function(params) {
      category <- portfolio$get_category(params$id)
      mcpr::response_text(as.data.frame(category))
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

  # Tool 12: List Categories
  tool_list_categories <- mcpr::new_tool(
    name = "list_categories",
    description = "List all categories",
    input_schema = mcpr::schema(
      properties = setNames(list(), character())
    ),
    handler = function(params) {
      result <- portfolio$list_categories()
      mcpr::response_text(yyjsonr::write_json_str(result))
    }
  )

  # Create MCP server
  mcp <- mcpr::new_server(
    name = "Chief Portfolio Server",
    description = "MCP server for managing todos and categories",
    version = as.character(packageVersion("chief"))
  )

  # Add all tools
  mcp <- mcpr::add_capability(mcp, tool_add_todo)
  mcp <- mcpr::add_capability(mcp, tool_get_todo)
  mcp <- mcpr::add_capability(mcp, tool_update_todo)
  mcp <- mcpr::add_capability(mcp, tool_delete_todo)
  mcp <- mcpr::add_capability(mcp, tool_mark_complete)
  mcp <- mcpr::add_capability(mcp, tool_list_all)
  mcp <- mcpr::add_capability(mcp, tool_list_incomplete)
  mcp <- mcpr::add_capability(mcp, tool_list_completed)
  mcp <- mcpr::add_capability(mcp, tool_add_category)
  mcp <- mcpr::add_capability(mcp, tool_get_category)
  mcp <- mcpr::add_capability(mcp, tool_update_category)
  mcp <- mcpr::add_capability(mcp, tool_list_categories)

  mcp
}
