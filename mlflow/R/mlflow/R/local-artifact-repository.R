#' @include artifact-repository.R
#' @include file-utils.R
#' @include validation-utils.R

LocalArtifactRepository <- R6::R6Class("LocalArtifactRepository",
  inherit = ArtifactRepository,
  public = list(
    initialize = function(...) {
      super$initialize(...)
      self$artifact_dir = local_file_uri_to_path(self$artifact_uri)
    },
    artifact_dir = function() {
      self$artifact_dir
    },
    log_artifact = function(local_file, artifact_path = NULL, ...) {
      artifact_dir <- prepare_artifact_dir(artifact_path)

      fs::file_copy(local_file, file.path(artifact_dir, basename(local_file)))
    },
    log_artifacts = function(local_dir, artifact_path = NULL, ...) {
      artifact_dir <- prepare_artifact_dir(artifact_path)

      fs::dir_copy(local_dir, artifact_dir)
    },
    is_artifacts_directory = function(artifact_path) {
      path <- (
        if (!is.null(artifact_path)) {
          fs::tidy_path(artifact_path)
        } else {
          ""
        }
      )
      list_dir <- file.path(self$artifact_dir, path)

      fs::is_dir(list_dir)
    }
    download_artifacts = function(artifact_path, dst_path = NULL, ...) {
      if (!is.null(dst_path)) {
        super$download_artifacts(artifact_path, fs::path_tidy(dst_path), ...)
      } else {
        local_artifact_path <- file.path(
          self$artifact_dir, fs::path_rel(artifact_path)
        )
        if (!fs::file_exists(local_artifact_path)) {
          stop("No such file or directory: '", local_artifact_path, "'")
        }

        fs::path_abs(local_artifact_path)
      }
    },
    list_artifacts <- function(path = NULL, ...) {
      if (!is.null(path)) {
        path <- fs::path_tidy(path)
      }
      list_dir <- (
        if (!is.null(path)) {
          file.path(self$artifact_dir, path)
        } else {
          self$artifact_dir
        }
      )
      if (fs::is_dir(list_dir)) {
        artifact_files <- fs::dir_ls(list_dir, recursive = TRUE)

        fs::dir_map(
          list_dir,
          function(x) {
            info <- fs::file_info(x)
            info$path <- fs::path_rel(x, start = list_dir)

            info
          },
          all = TRUE,
          recurse = TRUE
        )
      } else {
        list()
      }
    },
    download_file = function(remote_file_path, local_path) {
      remote_file_path <- file.path(self$artifact_dir, fs::path_tidy(remote_file_path))

      fs::copy_file(remote_file_path, local_path, overwrite = TRUE)
    },
    delete_artifacts = function(artifact_path = NULL) {
      artifact_path <- file.path(self$artifact_dir, fs::path_tidy(artifact_path))

      fs::file_delete(local_file_uri_to_path(artifact_path))
    }
  ),
  private = list(
    is_directory = function(artifact_path) {
      path <- (
        if (!is.null(artifact_path)) {
          file.path(self$artifact_dir, fs::path_rel(artifact_path))
        } else {
          self$artifact_dir
        }
      )

      fs::is_dir(path)
    },
    prepare_artifact_dir = function(artifact_path) {
      validate_artifact_path(artifact_path)

      if (!is.null(artifact_path)) {
        artifact_path <- fs::path_tidy(artifact_path)
      }

      artifact_dir <- (
        if (!is.null(artifact_path)) {
          file.path(self$artifact_dir, artifact_path)
        } else {
          self$artifact_dir
        }
      )
      if (!fs::file_exists(artifact_dir)) {
        fs::dir_create(artifact_dir, recurse = TRUE)
      }

      artifact_dir
    }
    artifact_dir = NA_character_
  )
