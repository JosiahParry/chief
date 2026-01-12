# example using rbm25 to create a database to search and query
# we can add data to this via:
# Usage
# BM25$add_data(data, metadata = NULL)
# Arguments
# data
# a vector of strings

# metadata
# a data.frame with metadata for each document, default is NULL

# Returns

# example
# library(rbm25)
# library(dplyr)
# library(stringr)
# library(janeaustenr)

# original_books <- austen_books() |>
#   group_by(book) |>
#   mutate(
#     linenumber = row_number(),
#     chapter = cumsum(
#       str_detect(
#         text,
#         regex("^chapter [\\divxlc]", ignore_case = TRUE)
#       )
#     ),
#     text = tolower(text)
#   ) |>
#   rename(content = text) |>
#   ungroup()

# # create the search engine
# tictoc::tic()
# bm <- BM25$new(data = original_books$content, metadata = original_books)
# tictoc::toc()

# tictoc::tic()
# res <- bm$query(query = "elizabeth bennet", max_n = 1000)
# tictoc::toc()
