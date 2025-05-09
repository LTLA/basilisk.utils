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
    Sys.getenv("BIOCCONDA_CONDA_CACHE_DIRECTORY", .get_default_cache_directory())
}

.get_default_cache_directory <- function() {
    if (isWindows()) {
        # The Windows Miniforge3 installer (at least, as of 24.3.0-0)
        # doesn't allow paths longer than 46 characters, so just throw it
        # in the user's home directory and hope for the best.
        inst_path <- Sys.getenv("userprofile")
        if (basename(inst_path) == "Documents") {
            inst_path <- dirname(inst_path)
        }
        inst_path <- file.path(inst_path, ".basilisk")
    } else {
        inst_path <- R_user_dir("biocconda", "cache")
    }
}

