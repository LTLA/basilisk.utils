# library(testthat); library(basilisk.utils); source("test-download.R")

test_that("download() works as expected", {
    path <- download()
    expect_identical(download(), path) # just re-uses the cached path.

    # Checking that we can actually run the binary.
    ver <- basilisk.utils:::get_version(condaBinary(path))
    expect_match(as.character(ver), "^[0-9]+\\.[0-9]+\\.[0-9]+$")
})
