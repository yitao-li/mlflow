ArtifactRepository <- R6::R6Class("ArtifactRepository",
  public = list(
    initialize = function(artifact_uri) {
      self$artifact_uri <- artifact_uri
    },
    log_artifact = function(local_file, artifact_path = NULL, ...) {
      stop("Not implemented")
    },
    log_artifacts = function(local_dir, artifact_path = NULL, ...) {
      stop("Not implemented")
    },
    list_artifacts = function(path = NULL, ...) {
      stop("Not implemented")
    },
    is_artifacts_directory = function(artifact_path) {
      length(self$list_artifacts(artifact_path)) > 0
    },
    download_artifacts = function(artifact_path, dst_path = NULL, ...) {
      .download_file <- function(full_path) {
        dir_path <- fs::path_dir(full_path)
        local_dir_path <- file.path(dst_path, dir_path)
        local_file_path <- file.path(dst_path, full_path)
        if (!fs::dir_exists(local_dir_path)) {
          fs::dir_create(local_dir_path, recurse = TRUE)
        }
        self$download_file(remote_file_path = full_path, local_path = local_file_path)

        local_file_path
      }

      .download_artifact_dir <- function(dir_path) {
        local_dir <- file.path(dst_path, dir_path)
        dir_content <- self$list_artifacts(dir_path)
        dir_content <- dir_content[dir_content$path != "." && dir_content$path != dir_path]
        if (length(dir_content) == 0) {
          if (!fs::file_exists(local_dir)) {
            fs::dir_create(local_dir, recurse = TRUE)
          }
        } else {
          for (file_info in dir_content) {
            if (file_info$is_dir) {
              .download_artifact_dir(dir_path = file_info$path)
            } else {
              .download_file(file_info$path)
            }
          }
        }

        local_dir
      }

      if (is.null(dst_path)) {
        dst_path <- tempfile(pattern = "mlflow_")
        fs::dir_create(dst_path)
      }
      dst_path <- fs::path_abs(dst_path)

      if (!fs::file_exists(dir_path)) {
        stop(
          "The destination path for downloaded artifacts does not exist! ",
          "Destination path: ", dst_path
        )
      } else if (!fs::is_dir(dir_path)) {
        stop(
          "The destination path for downloaded artifacts must be a directory!",
          " Destination path: ", dst_path
        )
      }

      if (self$is_artifacts_directory(artifact_path)) {
        .download_artifacts_dir(artifact_path)
      } else {
        .download_file(artifact_path)
      }
    },
    download_file = function(remote_file_path, local_path) {
      stop("Not implemented")
    },
    delete_artifacts = function(artifact_path = NULL) {
      stop("Not implemented")
    },
    artifact_uri = NA_character_
  )
)
