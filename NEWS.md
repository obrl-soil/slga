# slga 1.1.1 [CRAN]

  * Update CRS handling to be compatible with modern PROJ; sf 0.9 is now required
  * All urls are now https

# slga 1.1.0 [CRAN]

  * User must now specify output directory when writing retrieved data to disk (CRAN rules).

# slga 1.0.2

  * slight change to crs string fix addressing inconsistent behaviour across proj versions
  * smaller example dataset for CRAN

# slga 1.0.1

  * Little tweaks and tidyups

# slga 1.0.0

  * Added functions `get_soils_point()` and `get_lscape_point()`, which return non-spatial data summaries. The value for a pixel directly under a point can be requested, or statistical summaries of the area within `n` pixels of a point. 
  * API change in `get_soils_data()` - component names for requesting soils data are different ('VAL' vs 'value' etc)
  * Functions `get_soils_data()` and `get_lscape_data()` no longer write rasters to your working directory unless you tell them to (use option `write_out = TRUE`). 

# slga 0.8.0
  
  * Refactored aoi processing and main request functions (all under-the-hood stuff)
  * Bugfix - EPSG:4283 should no longer be misinterpreted as EPSG:4151 in other software (e.g. QGIS)
  * pkgdown doco
  * progress bars for staged requests

# slga 0.7.0

  * http error handling
  * staged requests where aoi larger than 1x1 degrees
  * exported `check_avail()` for making sure a given soil attribute is available on a given product.

# slga 0.6.0

  * S3 methods for validating aoi (internal only). Covered: numeric vector, raster, rasterExtent, sf, sfc.
  * Bugfix for tempfile names.
  * Bugfix for bounding box.
  * Better crs checking.
  * Outputs in GDA94 like they should have been already.

# slga 0.5.0

  * data type fixes for lscape, more efficient download method.
  * Added `metadata_soils()` and `metadata_lscape()` to provide access to service metadata in XML or JSON format.

# slga 0.4.0

  * Add access to landscape datasets - API change per below.
  * Renamed `get_slga_data()` to `get_soils_data()`. 
  * Added `get_lscape_data()` for landscape parameter retrieval, plus supporting internal functions.
  * Modified `slga_product_info` to contain landscape parameters.
  * Extended vignette to cover landscape dataset retrieval.  

# slga 0.3.0

  * Updated README.md.
  * Added travis and codecov.

# slga 0.2.0

  * Retrieval functionality wrapped in `get_slga_data()` to get raster values and confidence intervals in one object. For more complex requests involving multiple depth ranges, attributes, products or combinations thereof, use this with a map-style function e.g. `base::lapply()` or `purrr::map()`.
  * Added product/attribute availability checking.
  * Now using easier to remember names for products.
  * Added unit tests.
  * Added vignette.

# slga 0.1.0

  * basic functionality - ability to extract a single raster subset using a bounding box.
