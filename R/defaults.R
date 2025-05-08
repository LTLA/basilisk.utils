#' Defaults for \pkg{biocconda}
#'
#' @return
#' For \code{defaultCommand}, a string specifying the expected command-line invocation of an existing conda installation.
#' 
#' For \code{defaultDownloadVersion}, a string specifying the version of conda to download if no existing installation can be found.
#'
#' For \code{defaultMinimumVersion}, a string specifying the minimum version of an existing conda installation.
#'
#' For \code{defaultCacheDirectory}, a string containing the path to the cache directory for \pkg{biocconda}-managed conda installations.
#'
#' @details
#' The \code{BIOCCONDA_CONDA_COMMAND} environment variable will override the default setting of \code{defaultCommand}.
#'
#' The \code{BIOCCONDA_CONDA_DOWNLOAD_VERSION} environment variable will override the default setting of \code{defaultDownloadVersion}.
#'
#' The \code{BIOCCONDA_CONDA_MINIMUM_VERSION} environment variable will override the default setting of \code{defaultMinimumVersion}.
#'
#' The \code{BIOCCONDA_CONDA_CACHE_DIRECTORY} environment variable will override the default setting of \code{defaultCacheDirectory}.
#'
#' @author Aaron Lun
#' @examples
#' defaultCommand()
#' defaultDownloadVersion()
#' defaultMinimumVersion()
#' defaultCacheDirectory()
#' 
#' @name defaults
NULL

#' @export
#' @rdname defaults
defaultCommand <- function() {
    Sys.getenv("BIOCCONDA_CONDA_COMMAND", "conda")
}


#' @export
#' @rdname defaults
defaultDownloadVersion <- function() {
    Sys.getenv("BIOCCONDA_CONDA_DOWNLOAD_VERSION", "24.11.3-0")
}

#' @export
#' @rdname defaults
defaultMinimumVersion <- function() {
    Sys.getenv("BIOCCONDA_CONDA_MINIMUM_VERSION", "24.11.3")
}

#' @export
#' @importFrom tools R_user_dir
#' @rdname defaults
defaultCacheDirectory <- function() {
    Sys.getenv("BIOCCONDA_CONDA_CACHE_DIRECTORY", R_user_dir("biocconda", "cache"))
}
