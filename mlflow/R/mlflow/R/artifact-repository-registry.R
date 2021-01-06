#' @include default-artifact-repository.R
#' @include local-artifact-repository.R
#' @include uri-utils.R
NULL

ArtifactRepositoryRegistry <- R6::R6Class("ArtifactRepositoryRegistry",
  public = list(
    register <- function(scheme, repository) {
      self$registry[[scheme]] <- repository
    },
    get_artifact_repository = function(artifact_uri) {
      scheme <- get_uri_scheme(artifact_uri)
      repository <- self$registry(scheme) %||% DefaultArtifactRepository

      repository$new(artifact_uri)
    }
  ),
  private = list(
    registry = list()
  )
)

.artifact_repository <- ArtifactRepositoryRegistry$new()
.artifact_repository$register("", LocalArtifactRepository)
.artifact_repository$register("file", LocalArtifactRepository)

get_artifact_repository <- function(artifact_uri) {
  .artifact_repository$get_artifact_repository(artifact_uri)
}
