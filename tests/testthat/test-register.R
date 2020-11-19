test_that("register works", {
  # skip_if(!isTRUE(as.logical(Sys.getenv("CI"))))
  Sys.setenv("TFNSW_API_KEY" = "")
  tfnswapi_register(key = "key", add_to_renviron = T)
  expect_true(tfnswapi_has_api_key())
  checkmate::expect_string(tfnswapi_get_api_key())
  expect_error(tfnswapi_register(key = key, add_to_renviron = T))
  tfnswapi_register(key = Sys.getenv("TFNSW_API_KEY_DUP"), add_to_renviron = T, overwrite = T)
})
