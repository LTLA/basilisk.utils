isWindows <- function() {
    .Platform$OS.type=="windows" 
}

unlink2 <- function(x, recursive=TRUE, force=TRUE, ...) {
    status <- unlink(x, recursive=recursive, force=force, ...)
    if (any(failed <- status!=0L)) {
        stop("failed to remove '", x[failed][1], "'")
    }
}

dir.create2 <- function(path, recursive=TRUE, ...) {
    if (!dir.create(path, recursive=recursive, ...)) {
        stop("failed to create '", path, "'") 
    }
}
