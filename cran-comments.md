## Release Summary

Update for compatibility with sf 1.0

## Test environments

  * Local: 
    * Windows 10, R 4.1.0 (using PROJ 7.2.1)
    * Windows 10, R-devel build 2021-06-11 r80479 (using PROJ 7.2.1)
    * Ubuntu 18.04 bionic, R 4.1.0 via WSL-2 (using PROJ 7.0.0)
  * Github Actions via usethis::use_github_check_standard() 

## R CMD Check Results

  * Local: 
    * Windows 0 errors | 0 warnings | 0 notes
    * Ubuntu  0 errors | 0 warnings | 1 note (SSL error 60 on
      https://www.clw.csiro.au/aclep/soilandlandscapegrid/ProductDetails-SoilAttributes.html,
      local machine issue - domain cert reads as valid in browsers)
  * Github Actions: 0 errors | 0 warnings | 0 notes
  
Note that running the examples inside `\donttest{}` wrappers on Ubuntu appears to generate an error related to R CMD check's environment - as near as I can tell it can't find the tempfile downloaded from the SLGA API. The examples work correctly on Ubuntu in a normal R session, and they also run correctly when using `devtools::run_examples(run_donttest = TRUE)`. No such problems are encountered on Windows.
 
## Downstream dependencies

There are currently no downstream dependencies for this package.
