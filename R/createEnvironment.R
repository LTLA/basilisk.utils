#' Create a new conda environment
#'
#' Create a new conda environment if it does not already exist in the cache/system.
#'
#' @param pkg String containing the name of the R package that owns this conda environment.
#' @param name String containing the name of the environment.
#' @param version String containing the version of the environment.
#' Ignored for system installs.
#' @param packages Character vector of conda packages (possibly with version specifications) to be installed in this environment.
#' @param cache.dir String containing the location of the cache for lazily instantiated environments.
#' If \code{NULL}, this defaults to a location returned by \code{\link[tools]{R_user_dir}} with \code{package}.
#' Ignored for system installs.
#' @param ignore.cache Logical scalar indicating whether to ignore cached environments if they already exist.
#' Ignored for system installs.
#' @param conda String containing the path to the conda command or executable.
#' If \code{NULL}, a suitable value is obtained from \code{\link{find}}.
#' @param extra Character vector of additional arguments to pass to \code{conda create}.
#' If \code{NULL}, the following options are automatically added: \code{-c conda-forge}, \code{--override-channels}, \code{--quiet}.
#'
#' @details
#' In general, \code{createEnvironment} should be called inside any function of a downstream package that relies on the conda environment.
#' On its first call, it will then lazily instantiate the environment based on the specified arguments.
#' All subsequent calls in the same or new R sessions will use the cached environments.
#'
#' The \code{version} string is used to distinguish between different versions of the same \code{name} environments. 
#' This allows package developers to safely update their environments without affecting other R installations that are re-using the same cache.
#' Older unused versions of the environment will be automatically removed over time via \pkg{dir.expiry}.
#'
#' Note that the \code{version} string does not necessarily have to be the same as the version of the \code{pkg} package.
#' Any version-like string is fine as long as they are compatible with \code{\link{package_version}}.
#' In fact, having independent versions for the environments and their parent package is often more convenient,
#' as it means that the environments don't always need to be recreated when the package is updated.
#'
#' To avoid lazy evaluation, administrators of an R installation can enable system installs, see \code{\link{configureEnvironments}} for details.
#'
#' @return String containing the path to the conda environment.
#'
#' @author Aaron Lun
#' @examples
#' createEnvironment(
#'    pkg="basilisk.utils.test",
#'    name="test_env",
#'    version="1.0.0",
#'    packages="hdf5"
#' )
#'
#' # Repeated calls will just get the same environment back.
#' createEnvironment(
#'    pkg="basilisk.utils.test",
#'    name="test_env",
#'    version="1.0.0",
#'    packages="hdf5"
#' )
#' 
#' @export
createEnvironment <- function(
    pkg, 
    name, 
    version, 
    packages,
    cache.dir=NULL, 
    ignore.cache=FALSE,
    conda=NULL,
    extra=NULL)
{
    if (.use_system_install()) {
        return(file.path(.system_install_path(pkg, name)))
    }

    if (is.null(cache.dir)) {
        cache.dir <- tools::R_user_dir(pkg, "cache")
    }
    env.loc <- file.path(cache.dir, name, version)

    # Unlocking wil also handle cleaning of old versions.
    lck <- lockDirectory(env.loc, exclusive=(!file.exists(env.loc) || ignore.cache))
    on.exit(unlockDirectory(lck), add=TRUE, after=FALSE)

    if (ignore.cache) {
        unlink2(env.loc, recursive=TRUE)
    }

    if (!file.exists(env.loc)) {
        .create_environment(env.loc, conda=conda, packages=packages, extra=extra)
    }

    env.loc
}

.create_environment <- function(env.loc, conda, packages, extra) {
    success <- FALSE
    on.exit(if (!success) unlink2(env.loc), add=TRUE, after=FALSE)

    if (is.null(conda)) {
        conda <- find()
    }

    if (is.null(extra)) {
        extra <- c("-c", "conda-forge", "--override-channels", "--quiet")
    }

    status <- system2(conda, c("create", "--prefix", env.loc, "--yes", packages, extra))
    if (status != 0L) {
        stop(sprintf("failed to create conda environment at '%s' (returned %i)", env.loc, status))
    }

    success <- TRUE
}
