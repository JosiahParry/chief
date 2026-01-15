# list tools
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/list",
    "params": {}
  }'


# list resources
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "resources/list",
    "params": {}
  }'




# Get all todos
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "resources/read",
    "params": {
      "name": "All Todos"
    }
  }'

# Get incomplete todos
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 4,
    "method": "resources/read",
    "params": {
      "name": "Incomplete Todos"
    }
  }'

# Get completed todos
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 5,
    "method": "resources/read",
    "params": {
      "name": "Completed Todos"
    }
  }'

# Get all categories
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 6,
    "method": "resources/read",
    "params": {
      "name": "All Categories"
    }
  }'




# Add a todo
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 7,
    "method": "tools/call",
    "params": {
      "name": "add_todo",
      "arguments": {
        "title": "Test Todo",
        "description": "Testing via curl",
        "priority": 3
      }
    }
  }'

# Update a todo (replace with actual ID)
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 8,
    "method": "tools/call",
    "params": {
      "name": "update_todo",
      "arguments": {
        "id": "01JHRQM8X9ABCDEFGHIJK",
        "title": "Updated Test Todo",
        "priority": 5
      }
    }
  }'

# Mark todo complete (replace with actual ID)
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 9,
    "method": "tools/call",
    "params": {
      "name": "mark_complete",
      "arguments": {
        "id": "01JHRQM8X9ABCDEFGHIJK"
      }
    }
  }'

# Delete a todo (replace with actual ID)
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 10,
    "method": "tools/call",
    "params": {
      "name": "delete_todo",
      "arguments": {
        "id": "01JHRQM8X9ABCDEFGHIJK"
      }
    }
  }'

# Add a category
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 11,
    "method": "tools/call",
    "params": {
      "name": "add_category",
      "arguments": {
        "title": "Work",
        "description": "Work related tasks"
      }
    }
  }'

# Update a category (replace with actual ID)
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 12,
    "method": "tools/call",
    "params": {
      "name": "update_category",
      "arguments": {
        "id": "01JHRQM8X9ABCDEFGHIJK",
        "title": "Updated Work",
        "description": "Updated description"
      }
    }
  }'