# library(testthat); library(basilisk.utils); source("setup.R"); source("test-configureEnvironments.R")

ext <- tempfile(fileext=".R")
write(file=ext, "
foo_args <- list(
    pkg='foo',
    name='test-env',
    version='1.0.0',
    packages='hdf5'
)

bar_args <- list(
    pkg='foo',
    name='more-test-env',
    version='1.0.0',
    packages='pandas'
)

whee <- list(
    pkg='foo',
    name='extra-test-env',
    version='1.0.0',
    packages='pandas'
)

other_args <- 2
")

test_that("environment extraction works as expected", {
    out <- basilisk.utils:::.extract_environments(ext)
    expect_identical(length(out), 2L)

    names <- sort(vapply(out, function(x) x$name, ""))
    expect_identical(names, c("more-test-env", "test-env"))
})

test_that("configureEnvironments works as expected", {
    olds <- set_system_install("1")
    on.exit(reset_system_install(olds), add=TRUE, after=TRUE)

    test.loc <- tempfile()
    oldl <- basilisk.utils:::.set_test_system_install_path(test.loc)
    on.exit(basilisk.utils:::.set_test_system_install_path(oldl), add=TRUE, after=TRUE)

    configureEnvironments(ext)
    expect_true(file.exists(createEnvironment("foo", "test-env", "1.0.0", "hdf5")))
    expect_true(file.exists(createEnvironment("foo", "more-test-env", "1.0.0", "pandas")))
})

test_that("configureEnvironments no-ops outside of a system install", {
    olds <- set_system_install(NA)
    on.exit(reset_system_install(olds), add=TRUE, after=TRUE)

    test.loc <- tempfile()
    oldl <- basilisk.utils:::.set_test_system_install_path(test.loc)
    on.exit(basilisk.utils:::.set_test_system_install_path(oldl), add=TRUE, after=TRUE)

    configureEnvironments(ext)
    expect_identical(length(list.files(test.loc)), 0L)
})
