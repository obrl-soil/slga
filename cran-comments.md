## Release Summary

## Resubmission 

Comments addressed:

  1. Please unwrap the examples if they are executable in < 5 sec, or create additionally small toy examples to allow automatic testing, (or replace \dontrun{} with \donttest{}).

  1. Unwrapped and simplified one example, changed all others to \donttest{}

## Test environments

  * Local: Windows 10, R 3.6.0 and Ubuntu 18.04 bionic, R 3.6.1 via WSL-2 (allows testing with newer GDAL/GEOS/PROJ stack also)
  * Travis-CI (Ubuntu 16.04.6 LTS, R 3.6.1)
  * win-build via devtools::check_win_devel (R Under development (unstable) (2019-07-05 r76784))

## R CMD Check Results

  * Local: 0 errors | 0 warnings | 0 notes (both Windows and Ubuntu)
  * Travis-CI:  0 errors | 0 warnings | 0 notes
  * win-build: 1 note "Possibly mis-spelled words in DESCRIPTION: geospatial" (Not a mis-spelling)
