#' Check whether an API key has been registered.
#'
#' @return Logical.
#' @export
#'
#' @examples
#'
#' tfnswapi_has_api_key()
tfnswapi_has_api_key = function() {
  has_api_key()
}

#' Get registered API key.
#'
#' @return Character.
#' @export
#'
#' @examples
#'
#' tfnswapi_get_api_key()
tfnswapi_get_api_key = function() {
  get_api_key()
}

has_api_key = function() {
  checkmate::assert_flag(get_api_key() != '')
}

get_api_key = function() {
  Sys.getenv("TFNSW_API_KEY")
}
