# Create MCP Server for Portfolio

Creates an MCP server that exposes Portfolio methods as tools for
managing todos and categories via the Model Context Protocol.

## Usage

``` r
chief_mcp_server(path = NULL)
```

## Arguments

- path:

  Optional path to the SQLite database. If NULL, uses
  `resolve_chief_path()` to find the database location.

## Value

An MCP server object
