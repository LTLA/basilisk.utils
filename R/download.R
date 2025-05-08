#' Install conda 
#'
#' Install conda via the Miniforge project to an appropriate destination path,
#' skipping the installation if said path already exists.
#'
#' @param download.version String specifying the Miniforge version to download.
#' @param cache.dir String specifying the location of the directory in which to cache Miniforge installations.
#' @param ignore.cache Logical scalar specifying whether to ignore any existing cached version of Miniforge,
#' in which case the binaries will be downloaded again.
#' 
#' @details
#' This function was originally created from code in \url{https://github.com/hafen/rminiconda},
#' also borrowing code from \pkg{reticulate}'s \code{install_miniconda} for correct Windows installation.
#' It downloads and runs a Miniforge installer to create a Bioconductor-managed Conda instance. 
#'
#' Whenever \code{download} is re-run, any old conda instances and their associated \pkg{basilisk} environments are deleted from the external installation directory.
#' This avoids duplication of large conda instances after their obselescence.
#'
#' @return
#' A conda instance is created at the cache location. 
#' Nothing is performed if a complete instance already exists at that location.
#' A string is returned containing the path to the conda installation.
#'  
#' @author Aaron Lun
#'
#' @examples
#' download()
#'
#' @export
#' @import dir.expiry 
download <- function(download.version=defaultDownloadVersion(), cache.dir=defaultCacheDirectory(), ignore.cache=FALSE) {
    dest_path <- file.path(cache.dir, download.version)
    lck <- lockDirectory(dest_path, exclusive=(!file.exists(dest_path) || ignore.cache))
    on.exit(unlockDirectory(lck), add=TRUE, after=FALSE)

    if (ignore.cache) {
        unlink(dest_path, recursive=TRUE)
    }

    if (!file.exists(dest_path)) {
        # Destroying the directory upon failure, to avoid difficult interpretations
        # of any remnant installation directories when this function is hit again.
        success <- FALSE
        on.exit({
            if (!success) {
                unlink2(dest_path, recursive=TRUE)
            }
        }, add=TRUE, after=FALSE)

        prefix <- "Miniforge3"
        base_url <- paste0("https://github.com/conda-forge/miniforge/releases/download/", download.version)

        if (isWindows()) {
            if (.Machine$sizeof.pointer != 8) {
                stop("Windows 32-bit architectures not supported by basilisk")
            }
            inst_file <- sprintf("%s-%s-Windows-x86_64.exe", prefix, download.version)
            tmploc <- .expedient_download(base_url, inst_file)

            parent <- dirname(dest_path)
            if (!file.exists(parent)) {
                dir.create2(parent)
            }
            sanitized_path <- gsub("/", "\\\\", dest_path) # Windows installer doesn't like forward slashes.

            inst_args <- c("/InstallationType=JustMe", "/RegisterPython=0", "/S", sprintf("/D=%s", sanitized_path))
            Sys.chmod(tmploc, mode = "0755")
            status <- system2(tmploc, inst_args)

        } else if (Sys.info()[["sysname"]] == "Darwin") {
            if (grepl("^arm", Sys.info()[["machine"]])) {
                arch <- "arm64"
            } else {
                arch <- "x86_64" 
            }
            inst_file <- sprintf("%s-%s-MacOSX-%s.sh", prefix, download.version, arch)
            tmploc <- .expedient_download(base_url, inst_file)
            inst_args <- sprintf(" %s -b -p %s", tmploc, dest_path)
            status <- system2("bash", inst_args)

        } else {
            if (Sys.info()[["machine"]] == "aarch64") {
                arch <- "aarch64"
            } else {
                arch <- "x86_64"
            }
            inst_file <- sprintf("%s-%s-Linux-%s.sh", prefix, download.version, arch)
            tmploc <- .expedient_download(base_url, inst_file)
            inst_args <- sprintf(" %s -b -p %s", tmploc, dest_path)
            status <- system2("bash", inst_args)
        }

        # Rigorous checks for proper installation, heavily inspired if not outright
        # copied from reticulate::install_miniconda.
        if (status != 0) {
            stop(sprintf("conda installation failed with status code '%s'", status))
        }
        conda.exists <- file.exists(condaBinary(dest_path))
        if (conda.exists && isWindows()) {
            # Sometimes Windows doesn't create this file. Why? WHO KNOWS.
            conda.exists <- file.exists(file.path(dest_path, "condabin/conda.bat"))
        }

        python.cmd <- pythonBinary(dest_path)
        report <- system2(python.cmd, c("-E", "-c", shQuote("print(1)")), stdout=TRUE, stderr=FALSE)
        if (!conda.exists || report!="1") {
            stop("conda installation failed for an unknown reason")
        }

        success <- TRUE
    }

    # We (indirectly) call dir.expiry::unlockDirectory on exit, which will
    # automatically implement the clearing logic; so there's no need to
    # explicitly call clearExternalDir here.
    touchDirectory(dest_path)
    dest_path
}

#' @importFrom utils download.file
#' @importFrom methods is
.expedient_download <- function(base_url, inst_file) {
    fname <- tempfile(fileext=inst_file)
    url <- paste0(base_url, "/", inst_file)
    tryCatch({
        if (download.file(url, fname, mode="wb")) {
            stop("failed to download the conda installer - check your internet connection or increase 'options(timeout=...)'") 
        }
    }, error=function(e) {
        unlink(fname, force=TRUE)
        stop(e)
    })
    fname
}
