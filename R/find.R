#' @export
find <- function(
    command=defaultCommand(),
    minimum.version=defaultMinimumVersion(),
    can.download=TRUE,
    force.check=FALSE,
    ...)
{
    if (!force.check && !is.na(cached$previous)) {
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

    acquired <- download(...)
    cached$previous <- acquired
    acquired 
}

get_version <- function(command) {
    test <- system2(command, "--version", stdout=TRUE)
    vstring <- gsub("conda ", "", vstring)
    package_version(vstring)
}

cached <- new.env()
cached$previous <- NA
