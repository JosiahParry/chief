check_scalar <- function(
  x,
  ...,
  allow_null = FALSE,
  arg = rlang::caller_arg(x),
  error_call = rlang::caller_call()
) {
  if (!rlang::has_length(x, 1L)) {
    cli::cli_abort("{.arg {arg}} must be a scalar value")
  }
}


compact <- function(.x) Filter(length, .x)


#' Convert a vector to JSONB
#'
#' @param x the vector to convert
#' @param ... arguments passed to yyjsonr::write_json_raw
as_jsonb <- function(x, ...) {
  blob::as_blob(
    lapply(x, \(.x) {
      yyjsonr::write_json_raw(.x, ...)
    })
  )
}

#' Convert JSONB to an R object
#'
#' @param x a `blob` object to parse
#' @param ... arguments passed to yyjsonr::read_json_raw()
from_jsonb <- function(x, ...) {
  lapply(x, \(.x) yyjsonr::read_json_raw(.x, ...))
}

from_jsonb_value <- function(x, ...) {
  res <- from_jsonb(x, ...)
  if (rlang::is_empty(res[[1]])) {
    character()
  } else {
    res[[1]]
  }
}
