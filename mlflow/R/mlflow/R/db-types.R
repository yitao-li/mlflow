#' @include globals.R

# Set of SQLAlchemy database schemas supported in MLflow for tracking server
# backends.

.POSTGRES <- "postgresql"
.MYSQL <- "mysql"
.SQLITE <- "sqlite"
.MSSQL <- "mssql"

.globals$DATABASE_ENGINES <- c(.POSTGRES, .MYSQL, .SQLITE, .MSSQL)
