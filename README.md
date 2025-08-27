# Self-managed conda for Bioconductor

|Environment|Status|
|---|---|
|BioC-release|[![Release OK](https://bioconductor.org/shields/build/release/bioc/basilisk.utils.svg)](https://bioconductor.org/checkResults/release/bioc-LATEST/basilisk.utils/)|
|BioC-devel|[![Devel OK](https://bioconductor.org/shields/build/devel/bioc/basilisk.utils.svg)](https://bioconductor.org/checkResults/devel/bioc-LATEST/basilisk.utils/)|

This package provisions and manages a Conda instance (if one is not already available) for use in the Bioconductor ecosystem.
It also provides utilities for other packages or users to easily create their own Conda environments.
It was originally intended to support the [**basilisk**](https://github.com/LTLA/basilisk) package,
but now that **basilisk** no longer relies on Conda, **basilisk.utils** has been repurposed for more general-purpose Conda management.
