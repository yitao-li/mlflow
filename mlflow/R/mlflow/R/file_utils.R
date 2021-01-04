local_file_uri_to_path <- function(uri) {
  path <- (
    if (identical(substr(uri, start = 1, stop = 5), "file:")) {
      httr::parse_url(uri)$path
    } else {
      uri
    }
  )

  utils::URLdecode(path)
}
