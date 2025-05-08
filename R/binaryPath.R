#' Get binary paths
#'
#' @param loc String containing the path to the root of a conda instance or environment.
#'
#' @return String containing the path to the conda or Python executable inside \code{loc}.
#' If \code{loc} is not supplied, the relative path from the root of the environment is returned.
#'
#' @details
#' This code is largely copied from \pkg{reticulate},
#' and is only present here as they do not export these utilities for general consumption.
#'
#' @author Aaron Lun
#'
#' @examples
#' condaBinary()
#' pythonBinary()
#'
#' @name binaryPath
#' @export
condaBinary <- function(loc) {
    if (isWindows()) {
        suffix <- "Scripts/conda.exe"
    } else {
        suffix <- "bin/conda"
    }
    if (missing(loc)) {
        return(suffix)
    } else {
        return(file.path(loc, suffix))
    }
}

#' @export
#' @rdname binaryPath 
pythonBinary <- function(loc) {
    if (isWindows()) {
        suffix <- "python.exe"
    } else {
        suffix <- "bin/python"
    }
    if (missing(loc)) {
        return(suffix)
    } else {
        return(file.path(loc, suffix))
    }
}
