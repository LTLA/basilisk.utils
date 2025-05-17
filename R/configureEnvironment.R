#' Create environments with system installs 
#'
#' Create conda environments during installation of the R package, typically by calling this function in a package's \code{configure} file.
#'
#' @param src String containing the local path to an R source file that defines the environments to be created.
#'
#' @return 
#' \code{NULL} is invisibly returned.
#' Conda environments are created in the R package installation directory if system installs are enabled.
#' Otherwise, no action is performed.
#'
#' @details
#' Sometimes, the lazy creation of new environments is not desirable.
#' For example, administrators of multi-user R instances would not want to create a separate environment in each user's cache.
#' Similarly, users of Docker images would not want to recreate the environment inside every new container. 
#'
#' In these cases, an alternative is to use a \dQuote{system install}, where the environments are created during R package installation.
#' Each environment is directly created in the package's installation directory and is immediately available when \code{\link{createEnvironment}} is called.
#' Administrators can enable this mode by setting the \code{BIOCCMAKE_USE_SYSTEM_INSTALL} environment variable to 1.
#' Note that this setting takes effect during R package installation so should be set before (re-)installation of \pkg{basilisk.utils} and its dependencies.
#'
#' Developers can support system installs by adding \code{configure(.win)} scripts to the root of their package.
#' These scripts should call \code{\link{configureEnvironments}} to trigger creation of the conda environments during R package installation.
#' Details of the environments to be created are taken from the \code{src} file, which should be executable as a standalone R file (i.e., it can be \code{\link{source}}d).
#' Each conda environment is defined as a list with a name ending in \code{_args}, where the list contains at least the mandatory arguments to \code{\link{createEnvironment}}.
#' (Caching-related arguments are ignored.)
#'
#' Packages that support system installs should also set \code{StagedInstall: no} in their \code{DESCRIPTION} files.
#' This ensures that the conda environments are created with the correct hard-coded paths in the package installation directory.
#'
#' @author Aaron Lun
#' @examples
#' # If we have a package with an 'R/environments.R' file,
#' # we could put the following in our 'configure' file.
#' \dontrun{configureEnvironments('R/environments.R')}
#'
#' @export
configureEnvironments <- function(src) {
    if (!.use_system_install()) {
        return(invisible(NULL))
    }

    env.vars <- .extract_environments(src)
    if (length(env.vars) == 0L) {
        return(invisible(NULL))
    }

    defaults <- formals(createEnvironment)
    required <- setdiff(names(formals(.create_environment)), "env.loc")

    for (args in env.vars) {
        loc <- .system_install_path(args$pkg, args$name, installed=FALSE)
        dir.create(dirname(loc), recursive=TRUE, showWarnings=FALSE)
        cur.args <- list(env.loc=loc)
        cur.args <- c(cur.args, args[intersect(required, names(args))])
        cur.args <- c(cur.args, defaults[setdiff(required, names(args))])
        do.call(.create_environment, cur.args)
    }

    invisible(NULL)
}

.extract_environments <- function(src) {
    envir <- new.env()
    eval(parse(file=src), envir=envir)

    # Only retaining those that are lists of environment names.
    env.vars <- ls(envir)
    env.vars <- env.vars[grepl("_args$", env.vars)]
    env.vars <- lapply(env.vars, function(nm) get(nm, envir=envir, inherits=FALSE))
    env.vars[vapply(env.vars, is.list, FALSE)]
}

.use_system_install <- function() {
    identical(Sys.getenv("BIOCCONDA_USE_SYSTEM_INSTALL", ""), "1")
}

.system_install_path <- function(package, name, installed) {
    candidate <- test.cache$path
    if (is.null(candidate)) {
        if (installed) {
            return(system.file("biocconda", name, package=package, mustWork=TRUE))
        }
        candidate <- .libPaths()[1]
    }
    file.path(candidate, package, "biocconda", name)
}

# Provided for ease of testing only.
test.cache <- new.env()
test.cache$path <- NULL

.set_test_system_install_path <- function(path) {
    old <- test.cache$path
    test.cache$path <- path
    invisible(old)
}
