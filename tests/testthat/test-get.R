test_that("tfnswapi_get works", {
  skip_on_ci()
  response <- tfnswapi_get(api = "carpark", params = list(facility = 2))
  checkmate::expect_list(response, names = "unique")
})

test_that("gtfsr", {
  skip_on_ci()
  response <- tfnswapi_get("gtfs/realtime/buses")
  checkmate::expect_class(response, "tfnswapi")
})
