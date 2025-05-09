set_system_install <- function(val) {
    old <- Sys.getenv("BIOCONDA_USE_SYSTEM_INSTALL", NA)
    if (is.na(val)) {
        Sys.unsetenv("BIOCCONDA_USE_SYSTEM_INSTALL")
    } else {
        Sys.setenv(BIOCCONDA_USE_SYSTEM_INSTALL=val)
    }
    old
}

reset_system_install <- function(old) {
    if (is.na(old)) {
        Sys.unsetenv("BIOCCONDA_USE_SYSTEM_INSTALL")
    } else {
        Sys.setenv(BIOCCONDA_USE_SYSTEM_INSTALL=old)
    }
}
