#' Find conda
#'
#' Find an existing conda installation or, if none can be found, install a \pkg{biocconda}-managed conda instance.
#'
#' @param command String containing the command to check for an existing installation.
#' @param minimum.version String specifying the minimum acceptable version of an existing installation.
#' @param can.download Logical scalar indicating whether to download conda if no acceptable existing installation can be found.
#' @param forget Logical scalar indicating whether to forget the results of the last call.
#' @param ... Further arguments to pass to \code{\link{download}}.
#'
#' @details
#' If the \code{BIOCCONDA_FIND_OVERRIDE} environment variable is set to a command or path to a conda executable, it is returned directly and all other options are ignored.
#'
#' By default, \code{find} will remember the result of its last call in the current R session, to avoid re-checking the versions, cache, etc.
#' This can be disabled by setting \code{forget=TRUE} to force a re-check, e.g., to detect a new version of conda that was installed while the R session is active.
#'
#' @return String containing the command to use to run conda.
#'
#' @author Aaron Lun
#' @examples
#' cmd <- find()
#' system2(cmd, "--version")
#'
#' @export
find <- function(
    command=defaultCommand(),
    minimum.version=defaultMinimumVersion(),
    can.download=TRUE,
    forget=FALSE,
    ...)
{
    if (!forget && !is.na(cached$previous)) {
        return(cached$previous)
    }

    override <- Sys.getenv("BIOCCONDA_FIND_OVERRIDE", NA)
    if (!is.na(override)) {
        cached$previous <- override
        return(override)
    }

    if (Sys.which(command) != "") {
        version <- get_version(command)
        if (version >= minimum.version) {
            cached$previous <- command
            return(command)
        }
    }

    if (!can.download) {
        cached$previous <- NULL
        return(NULL)
    }

    acquired <- condaBinary(download(...))
    cached$previous <- acquired
    acquired 
}

get_version <- function(command) {
    test <- system2(command, "--version", stdout=TRUE)
    vstring <- gsub("conda ", "", test)
    package_version(vstring)
}

cached <- new.env()
cached$previous <- NA
