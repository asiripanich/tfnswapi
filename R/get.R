ua <- httr::user_agent("http://github.com/asiripanich/tfnswapi")
tfnsw_base_api_url <- "https://api.transport.nsw.gov.au/"

#' Get data using GET API.
#'
#' @param api Character. API name (e.g. 'carpark' for
#'  https://opendata.transport.nsw.gov.au/node/6223/exploreapi#!/carpark/GetCarPark).
#' @param params a named list. Any parameters that the API accepts can be specified
#'  here.
#' @param key Character (optional). An API key can be provided, else if emptied
#'  it will look for any previously registered API key.
#' @param descriptor This field is only used if the response is of type
#'  `application/x-google-protobuf`. You must select one of `transit_realtime` variables.
#'  By default this is `transit_realtime.FeedMessage`.
#'
#' @return a response with parsed content.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # See what facilities are available
#' tfnswapi_get("carpark")
#' tfnswapi_get("carpark", params = list(facility = 2))
#' }
tfnswapi_get <- function(api,
                         params = NULL,
                         key = tfnswapi_get_api_key(),
                         descriptor = transit_realtime.FeedMessage) {
  path <- construct_path(api)

  response <- tfnswapi_get_response(path, params, key)

  response$content <- switch(httr::http_type(response),
    "application/json" = parse_json_response(response),
    "application/x-google-protobuf" = parse_ggprotobuf_response(response, descriptor),
    stop("Don't know how to parse ", httr::http_type(response))
  )

  if (httr::status_code(response) != 200) {
    stop(
      sprintf(
        "TfNSW API request failed [%s]\n%s\n<%s>\n<%s>",
        httr::status_code(response),
        parsed$ErrorDetails$Message,
        parsed$ErrorDetails$RequestMethod,
        parsed$ErrorDetails$RequestedUrl
      ),
      call. = FALSE
    )
  }

  structure(
    response,
    class = "tfnswapi"
  )
}

#' @param path Character.
#' @rdname tfnswapi_get
#' @export
tfnswapi_get_response <- function(path, params = NULL, key = tfnswapi_get_api_key()) {
  checkmate::assert_string(path)
  checkmate::assert_list(params, names = "unique", any.missing = FALSE, null.ok = TRUE)

  url <- httr::modify_url(tfnsw_base_api_url, path = path, query = params)

  headers <- httr::add_headers("Authorization" = paste0("apikey ", key))

  # return response
  httr::GET(url, ua, headers)
}

parse_json_response <- function(response) {
  jsonlite::fromJSON(httr::content(response, "text"), simplifyVector = FALSE)
}

parse_ggprotobuf_response <- function(response, descriptor = transit_realtime.FeedMessage) {
  FeedMessage <- RProtoBuf::read(descriptor = descriptor, input = response$content)
  json <- RProtoBuf::toJSON(FeedMessage)
  lst <- jsonlite::fromJSON(json)
}

construct_path <- function(api) {
  checkmate::assert_string(api)
  glue::glue("v1/{api}")
}
