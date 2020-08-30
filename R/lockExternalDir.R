#' Lock external directory 
#'
#' Lock the external Conda installation directory so that multiple processes cannot try to install at the same time.
#'
#' @param ... Further arguments to pass to \code{\link{lock}}, such as \code{exclusive}.
#' @param lock An existing \code{filelock_lock} object.
#'
#' @return 
#' \code{lockExternalDir} will return a \code{filelock_lock} object from \code{\link{lock}}.
#' 
#' \code{unlockExternalDir} will unlock the file and return \code{NULL} invisibly.
#'
#' @details
#' This will apply a lock to the (possibly user-specified) external directory,
#' so that a user trying to run parallel \pkg{basilisk} processes will not have race conditions during lazy installation.
#' For simplicity, the lock is global to the entire Conda installation, even if only a single environment is being installed,
#' as the creation of a single environment can prompt the lazy installation of a Conda instance.
#' If a system installation is being used, we do not need to lock as Conda and its environments are already installed.
#'
#' Under the lazy paradigm, a function will check whether an installation directory already exists, and if not, create it.
#' We suggest applying the lock at the start of the function, making it non-exclusive if the directory already exists.
#' (This is done by passing \code{exclusive=FALSE} to the arguments to \code{\link{lock}}.)
#' By doing so, we will wait for the completion of any installation process that might be operating on the directory.
#' Conversely, if the directory does not exist, an exclusive lock forces all other processes to wait for installation to finish. 
#'
#' Note that locking is only required during installation of Conda or its environments, not during their actual use.
#' Once an installation/environment is created, we assume that it is read-only for all processes.
#' Technically, this might not be true if one were to install a new version of \pkg{basilisk} halfway through an R session,
#' which would prompt \code{\link{installConda}} to wipe out the old Conda installations;
#' but one cannot in general guarantee the behavior of running R sessions when package versions change anyway,
#' so we won't bother to protect against that.
#'
#' @author Aaron Lun
#'
#' @examples
#' loc <- lockExternalDir()
#' unlockExternalDir(loc)
#'
#' @export
#' @importFrom filelock lock unlock
lockExternalDir <- function(...) {
    # Global lock, going above the version number in getExternalDir().
    # This is because getExternalDir() itself might get deleted in
    # installConda(), and you can't lock a file in a non-existent dir.
    dir <- dirname(getExternalDir()) 
    dir.create(dir, recursive=TRUE, showWarnings=FALSE)
    lock.path <- file.path(dir, "00LOCK")
    lock(lock.path, ...)
}

#' @export
#' @rdname lockExternalDir
unlockExternalDir <- function(lock) {
    if (!is.null(lock)) {
        unlock(lock)
    }
    invisible(NULL)
}