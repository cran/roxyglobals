#' Use roxyglobals
#'
#' Configures roxygen to use [global_roclet()], adds roxyglobals to Suggests
#' @return nothing
#' @export
#'
#' @examples
#' \dontrun{
#' use_roxyglobals()
#' }
use_roxyglobals <- function() {
  assert_in_pkg(".")

  # add dependency
  desc::desc_set_dep(utils::packageName(), type = "Suggests")

  # current roxygen options
  options <- options_get_roxygen()

  # add roclet
  options$roclets <- unique(c(
    options$roclets,
    # could use a string, but this should be refactor proof
    paste0(utils::packageName(), "::", substitute(global_roclet))
  ))

  # use global_roclet
  options_set_roxygen(options)

  # ensure roxyglobals options
  options_set_filename(options_get_filename())
  options_set_unique(options_get_unique())

  invisible()
}
