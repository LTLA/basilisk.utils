# library(testthat); library(basilisk.utils); source("setup.R"); source("test-createEnvironment.R")

cache <- tempfile()
envpath <- createEnvironment(
   pkg="basilisk.utils.test",
   name="test_env",
   version="1.0.0",
   packages="hdf5",
   cache.dir=cache
)
dummy <- ".basilisk.utils.test"
write(file=file.path(envpath, dummy), character(0))

test_that("environment caching works correctly", {
    # Make sure we don't get distracted by system installs here.
    old <- set_system_install(NA)
    on.exit(reset_system_install(old), add=TRUE, after=TRUE)

    envpath2 <- createEnvironment(
       pkg="basilisk.utils.test",
       name="test_env",
       version="1.0.0",
       packages="hdf5",
       cache.dir=cache
    )
    expect_identical(envpath, envpath2)
    expect_true(file.exists(file.path(envpath, dummy)))

    # Unless a new version is specified.
    envpath3 <- createEnvironment(
       pkg="basilisk.utils.test",
       name="test_env",
       version="1.0.1",
       packages="hdf5",
       cache.dir=cache
    )
    expect_false(identical(envpath, envpath3))

    # Or we forcibly ignore the cache.
    envpath4 <- createEnvironment(
       pkg="basilisk.utils.test",
       name="test_env",
       version="1.0.0",
       packages="hdf5",
       cache.dir=cache,
       ignore.cache=TRUE
    )
    expect_identical(envpath, envpath4)
    expect_false(file.exists(file.path(envpath, dummy)))
})

test_that("failed environment creation doesn't leave any residue", {
    # Make sure we don't get distracted by system installs here.
    old <- set_system_install(NA)
    on.exit(reset_system_install(old), add=TRUE, after=TRUE)

    expect_error(createEnvironment(
       pkg="basilisk.utils.test",
       name="test_fail",
       version="1.0.0",
       packages="aaronrandompackageshouldntexist",
       cache.dir=cache
    ), "failed")

    expect_true(file.exists(file.path(cache, "test_fail")))
    expect_false(file.exists(file.path(cache, "test_fail", "1.0.0")))
})
