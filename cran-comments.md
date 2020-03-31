## Release Summary

Update for compatibility with sf 0.9 and newer versions of PROJ

## Resubmission 

Fixed broken url (globalsoilmap.net is not currently active)

## Test environments

  * Local: Windows 10, R 3.6.3 and Ubuntu 18.04 bionic, R 3.6.3 via WSL-2 (allows testing with newer GDAL/GEOS/PROJ stack also)
  * Travis-CI (Ubuntu 16.04.6 LTS, R 3.6.2)
  * win-build via devtools::check_win_devel (R version 4.0.0 alpha (2020-03-26 r78078)) and devtools::check_win_release (R 3.6.3)

## R CMD Check Results

  * Local: 0 errors | 0 warnings | 0 notes (both Windows and Ubuntu)
  * Travis-CI:  0 errors | 0 warnings | 0 notes
  * win-build:  0 errors | 0 warnings | 1 note ('possibly invalid URLs' for the csiro domains - they're actually fine in-browser, not sure why that happens)
  
## Downstream dependencies

There are currently no downstream dependencies for this package
