#' Register TfNSW API key.
#'
#' @param key Character. TfNSW API key.
#' @param add_to_renviron Logical. Default is `FALSE`. If `TRUE` then the file directory
#'  of the authentication file will be added to your `.Renviron` file.
#' @param overwrite Logical. Default is `FALSE`. If `TRUE`, the existing `TFNSW_API_KEY`
#' R environment variable will be replaced with new `key`.
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{
#'
#' tfnswapi_register(key = "your-key")
#'
#' }
tfnswapi_register = function(key,
                             add_to_renviron = FALSE,
                             overwrite = FALSE) {
  key = force(key)
  checkmate::assert_string(key)
  checkmate::assert_flag(add_to_renviron)
  checkmate::assert_flag(overwrite)

  # save the file directory of the authentication file.
  if (add_to_renviron) {

    if (!overwrite & has_api_key()) {
      stop("Because overwrite is `FALSE` and `Sys.getenv('TFNSW_API_KEY')` ",
           "is not emptied, the authentication file cannot be over written.")
    }

    cli::cli_alert_info("Adding your TfNSW API key to {.file ~/.Renviron}. \\
                        You won't need to do this again next time. ;)")
    # grab .Renviron file path
    environ_file <- file.path(Sys.getenv("HOME"), ".Renviron")

    # create .Renviron file if it does not exist
    if(!file.exists(file.path(Sys.getenv("HOME"), ".Renviron"))) {
      cli::cli_alert_info('Creating file {environ_file}')
      file.create(environ_file)
    }

    # read in lines
    environ_lines <- readLines(environ_file)

    # if no key present, add; otherwise replace old one
    if (!any(stringr::str_detect(environ_lines, "TFNSW_API_KEY="))) {

      cli::cli_alert_info('Adding AURIN API Username and Password to {environ_file}')
      environ_lines <- c(environ_lines, glue::glue("TFNSW_API_KEY={key}"))
      writeLines(environ_lines, environ_file)

    } else {

      key_line_index <- which(stringr::str_detect(environ_lines, "TFNSW_API_KEY="))
      old_key <- stringr::str_extract(environ_lines[key_line_index], "(?<=TFNSW_API_KEY=)\\w+")
      cli::cli_alert_warning('Replacing old key ({.emph {old_key}}) with new key \\
                             ({.emph {key}}) in {.path {environ_file}}')
      environ_lines[key_line_index] <- glue::glue("TFNSW_API_KEY={key}")
      writeLines(environ_lines, environ_file)

    }

    # set key in current session
    Sys.setenv("TFNSW_API_KEY" = key)

  } else {

    # set key in current session
    cli::cli_alert_info("Saving your TfNSW API key for the current session only.
                        This will not be remembered and you will have to set it
                        again after you close this session.")
    Sys.setenv("TFNSW_API_KEY" = key)

  }

  return(invisible(NULL))

}
