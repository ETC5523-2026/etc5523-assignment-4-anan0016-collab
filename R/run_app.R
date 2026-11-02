#' Launch Pop-Up Scout
#'
#' Opens the Pop-Up Scout Shiny app, which helps someone planning a clothing
#' pop-up in Melbourne's CBD compare street locations by foot traffic during
#' their own trading days, hours and months.
#'
#' @return Called for its side effect of starting the app. Does not return a
#'   useful value.
#'
#' @importFrom bslib bs_theme
#' @importFrom ggplot2 ggplot
#' @export
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function() {
  app_dir <- system.file("app", package = "melbfoot")
  if (app_dir == "") {
    stop("Could not find the Pop-Up Scout app. Try reinstalling melbfoot.")
  }
  shiny::runApp(app_dir, display.mode = "normal")
}