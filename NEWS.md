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
