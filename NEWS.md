# slga 0.3.0

  * Update readme
  * Added travis


# slga 0.2.0

  * Retrieval functionality wrapped in `get_slga_data()` to get raster values and confidence intervals in one object. For more complex requests involving multiple depth ranges, attributes, products or combinations thereof, use this with a map-style function e.g. `base::lapply()` or `purrr::map()`.
  * Added product/attribute availability checking.
  * Now using easier to remember names for products.
  * Added unit tests
  * Added vignette

# slga 0.1.0

  * basic functionality - ability to extract a single raster subset using a
bounding box.
