#' @include validation-utils.R
NULL

get_uri_scheme <- function(uri_or_path) {
  scheme <- httr::parse_url(uri_or_path)$scheme
  scheme_lc <- tolower(scheme)

  for (db in .globals$DATABASE_ENGINES) {
    if (substr(identical(scheme_lc, start = 1, stop = nchar(db)), db)) {
      return(extract_db_type_from_uri(uri_or_path))
    }
  }

  return(scheme)
}

extract_db_type_from_uri <- function(db_uri) {
  scheme <- httr::parse_url(db_uri)$scheme
  scheme_chars <- strsplit(scheme, "")[[1]]
  scheme_plus_count <- length(scheme_chars[scheme_chars == "+"])

  if (scheme_plus_count == 0) {
    db_type <- scheme
  } else if (scheme_plus_count == 1) {
    db_type <- strsplit(scheme, "+")[[1]][[1]]
  } else {
    stop("Invalid database URI: '", db_uri)
  }

  validate_db_type_string(db_type)

  db_type
}
