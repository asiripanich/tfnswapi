ua <- httr::user_agent("http://github.com/asiripanich/tfnswapi")
tfnsw_base_api_url = "https://api.transport.nsw.gov.au/"

#' Get data using GET API.
#'
#' @param api Character. API name (e.g. 'carpark' for
#'  https://opendata.transport.nsw.gov.au/node/6223/exploreapi#!/carpark/GetCarPark).
#' @param params a named list. Any parameters that the API accepts can be specified
#'  here.
#' @param key Character (optional). An API key can be provided, else if emptied
#'  it will look for any previously registered API key.
#'
#' @return a response list
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#'  # See what facilities are available
#'  tfnswapi_get("carpark")
#'  tfnswapi_get("carpark", params = list(facility = 2))
#'
#' }
tfnswapi_get = function(api, params = NULL, key = tfnswapi_get_api_key()) {

  checkmate::assert_string(api)
  checkmate::assert_list(params, names = "unique", any.missing = FALSE, null.ok = TRUE)

  path = c("v1", api)
  url = httr::modify_url(tfnsw_base_api_url, path = path, query = params)

  headers = httr::add_headers("Authorization" = paste0("apikey ", key),
                              "Accept" = "application/json")

  resp <- httr::GET(url, ua, headers)

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(httr::content(resp, "text"), simplifyVector = FALSE)

  if (httr::status_code(resp) != 200) {
    stop(
      sprintf(
        "TfNSW API request failed [%s]\n%s\n<%s>\n<%s>",
        httr::status_code(resp),
        parsed$ErrorDetails$Message,
        parsed$ErrorDetails$RequestMethod,
        parsed$ErrorDetails$RequestedUrl
      ),
      call. = FALSE
    )
  }

  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "tfnswapi"
  )
}

