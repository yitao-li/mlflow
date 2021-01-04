is_valid_artifact_path <- function(path) {
  if (fs::is_absolute_path(path)) {
    FALSE
  } else {
    normalized_path <- fs::path_norm(fs::path_rel(path))

    identical(normalized_path, path) &&
      !identical(normalized_path, ".") &&
      !identical(substr(normalized_path, start = 1, end = 2), "..")
  }
}

bad_path_msg <- function(name) {
  paste0(
    "Names may be treated as files in certain cases, and must not resolve to ",
    "other names when treated as such. This name would resolve to '",
    fs::path_norm(path),
    "'"
  )
}

validate_artifact_path <- function(path) {
  if (!is_valid_artifact_path(path)) {
    stop("Invalid artifact path: '", path, "'. ", bad_path_msg(path))
  }
}
