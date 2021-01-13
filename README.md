
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Travis build
status](https://travis-ci.com/obrl-soil/slga.svg?branch=master)](https://travis-ci.com/obrl-soil/slga)
[![Coverage
status](https://codecov.io/gh/obrl-soil/slga/branch/master/graph/badge.svg)](https://codecov.io/github/obrl-soil/slga?branch=master)
[![CRAN](https://www.r-pkg.org/badges/version/slga)](https://cran.r-project.org/package=slga)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/slga)](https://www.r-pkg.org/pkg/slga)

# slga

`slga` offers the ability to download geographic subsets of raster data
from the [Soil and Landscape Grid of
Australia](https://www.clw.csiro.au/aclep/soilandlandscapegrid/index.html).
The Grid was generated in 2014 from a compilation of Australian soil and
landscape data and contains a set of modelled soil attributes that meet
the globalsoilmap.net specification.

Also available for download are a set of terrain and climate covariates
considered useful in soils modelling. These are primarily derived from
[GeoScience Australia’s](https://www.ga.gov.au) [SRTM DEM
products](https://www.ga.gov.au/scientific-topics/national-location-information/digital-elevation-data).

All products are returned in GDA94 long/lat (EPSG:4283) and have a cell
resolution of 3" (roughly 90m).

## Installation

Install from CRAN with

``` r
install.packages('slga')
```

Install from github with

``` r
devtools::install_github("obrl-soil/slga")
```

## How it works

`slga` uses the WCS endpoints provided by the SLGA to access data. The
package endeavours to return requested products as simple subsets of the
parent dataset, with no hidden server-side resampling.

## Example

``` r
library(raster)
library(slga)
library(ggplot2)
```

``` r
# get surface clay content for King Island
aoi <- c(152.95, -27.55, 153.07, -27.45)
bne_surface_clay <- get_slga_data(product = 'NAT', attribute = 'CLY',
                                  component = 'all', depth = 1,
                                  aoi = aoi, write_out = FALSE)
```

<img src="man/figures/README-dplot-1.png" width="90%" style="display: block; margin: auto;" />

See the package vignette for further detail.

### Warning\!

While it is possible to download data for large extents using this
package, please be aware that the data volume can get large, and it will
not be very quick or efficient. If you want to obtain SLGA data for a
significant proportion of Australia, you may prefer to access the full
datasets via the [CSIRO Data Access
Portal](https://data.csiro.au/dap/home?execution=e1s1). Note that 1"
(30m) versions of the slga terrain attributes are also available on that
portal.

### Asking for help

If you get stuck using this package or the data it provides, please post
a question on [Stack Overflow](https://stackoverflow.com/) (for internet
connectivity problems) or the [GIS
StackExchange](https://gis.stackexchange.com/) (for raster/geospatial
issues). This means that others can benefit from the discussion, and
more people are available to help you. You’re welcome to ping me in a
comment on those websites or on twitter (@obrl\_soil) to get my
attention.

-----
