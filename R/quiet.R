#' quiet
#'
#' Function for supressing printed messages from a function.
#'
#' @param x - expression to be silenced.
#'
#' @return none
#'
#' @author Tyler W Bradshaw, \email{tyler.w.bradshaw@duke.edu}
#'
#' @references none
#'
#' @keywords none
#'
#' @export
#'
#' @examples
#' quiet(myfun(x))
quiet <- function(x) {
  sink(tempfile())
  on.exit(sink())
  invisible(force(x))
}
