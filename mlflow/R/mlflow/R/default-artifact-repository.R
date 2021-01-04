#' @include artifact-repository.R
#' @include cli.R
#' @include tracking-utils.R
NULL
NULL

# default implementation: fall back to MLflow CLI or MLflow REST endpoints
DefaultArtifactRepository <- R6::R6Class("DefaultArtifactRepository",
  public = list(
    log_artifact = function(local_file, artifact_path = NULL, ...) {
      mlflow_cli_log_artifact(
        path = local_file,
        artifact_path = artifact_path,
        ...
      )
    },
    log_artifacts = function(local_dir, artifact_path = NULL, ...) {
      mlflow_cli_log_artifact(
        path = local_dir,
        artifact_path = artifact_path,
        ...
      )
    },
    download_artifacts = function(artifact_path, dst_path = NULL, ...) {
      mlflow_cli_download_artifacts(
        path = artifact_path,
        dst_path = dst_path,
        ...
      )
    },
    list_artifacts = function(path = NULL, ...) {
      mlflow_rest_list_artifacts(path = path, ...)
    }
  ),
  private = list(
    mlflow_cli_log_artifact = function(path, artifact_path = NULL, run_id = NULL, client = NULL) {
      c(client, run_id) %<-% resolve_client_and_run_id(client, run_id)
      artifact_param <- NULL
      if (!is.null(artifact_path)) artifact_param <- "--artifact-path"

      if (as.logical(fs::is_file(path))) {
        command <- "log-artifact"
        local_param <- "--local-file"
      } else {
        command <- "log-artifacts"
        local_param <- "--local-dir"
      }

      mlflow_cli("artifacts",
                 command,
                 local_param,
                 path,
                 artifact_param,
                 artifact_path,
                 "--run-id",
                 run_id,
                 client = client
      )

      invisible(mlflow_list_artifacts(run_id = run_id, path = artifact_path, client = client))
    },
    mlflow_cli_download_artifacts = function(path, dst_path = NULL, run_id = NULL, client = NULL) {
      run_id <- resolve_run_id(run_id)
      client <- resolve_client(client)
      args <- list(
        "artifacts", "download",
        "--run-id", run_id,
        "--artifact-path", path
      )
      if (!is.null(dst_path)) {
        args <- append(args, list("--storage-dir", dst_path))
      }
      args <- append(
        args,
        list(
          echo = FALSE,
          stderr_callback = function(x, p) {
            if (grepl("FileNotFoundError", x)) {
              stop(
                gsub("(.|\n)*(?=FileNotFoundError)", "", x, perl = TRUE),
                call. = FALSE
              )
            }
          },
          client = client
        )
      )
      result <- do.call(mlflow_cli, args)

      gsub("\n", "", result$stdout)
    },
    mlflow_rest_list_artifacts <- function(path = NULL, run_id = NULL, client = NULL) {
      run_id <- resolve_run_id(run_id)
      client <- resolve_client(client)

      response <- mlflow_rest(
        "artifacts", "list",
        client = client, verb = "GET",
        query = list(
          run_uuid = run_id,
          run_id = run_id,
          path = path
        )
      )

      message(glue::glue("Root URI: {uri}", uri = response$root_uri))

      files_list <- if (!is.null(response$files)) response$files else list()
      files_list <- purrr::map(
        files_list,
        function(file_info) {
          if (is.null(file_info$file_size)) {
            file_info$file_size <- NA
          }
          file_info
        }
      )

      files_list %>%
        purrr::transpose() %>%
        purrr::map(unlist) %>%
        tibble::as_tibble()
    }
  )
)
