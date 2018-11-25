#' download SLGA datasets
#'
#' Retrieves SLGA gridded soil and landscape data in raster format from WCS
#' service.
#'
#' @params product Character, one of the options from column 'Code' in
#'   `slga_product_info`.
#' @param attribute Character, one of the options from column 'Code' in
#'   `slga_attribute_info`.
#' @param component Character, one of 'value', 'ci_low', or 'ci_high'.
#' @param depth Integer, a number from 1 to 6. The numbers correspond to the
#'   following depth ranges:
#'  \itemize{
#'   \item{1}{0 to 5 cm.}
#'   \item{2}{5 to 15 cm.}
#'   \item{3}{15 to 30 cm.}
#'   \item{4}}{30 to 60 cm.}
#'   \item{5}{60 to 100 cm.}
#'   \item{6}{100 to 200 cm.}}
#' @param aoi Vector of WGS84 coordinates defining a rectangular area of
#'   interest. The vector may be specified directly in the order xmin, xmax,
#'   ymin, ymax, or the function can derive an aoi from the boundary of an `sf`
#'   or `raster` object.
#' @param write_out Boolean, whether to write the retrieved dataset to the
#'   working directory as a GeoTiff.
#' @return Raster dataset for a single combination of product, attribute,
#'   component, depth, and area of interest.
#' @Note Output rasters are restricted to a maximum size of 3x3 decimal degrees.
#' @importFrom httr content GET
#' @importFrom raster getValues raster writeRaster
#' @export
#'

get_single_raster <- function(product   = NULL,
                              attribute = NULL,
                              component = NULL,
                              depth     = NULL,
                              aoi       = NULL,
                              write_out = TRUE) {

  # generate URL
  this_url <- make_slga_url(product = product, attribute = attribute,
                            component = component, depth = depth,
                            aoi = aoi)
  # get data
  got <- httr::GET(url = this_url)

  # convert raw to GTiff
  # code depth for filename
  depth_pretty <-
    switch(depth, `1` = "000_005", `2` = "005_015", `3` = "015_030",
           `4` = "030_060", `5` = "060_100", `6` = "100_200")
  out_name <- paste(product, attribute, toupper(component), depth_pretty,
                    sep = '_')
  out_temp <- file.path(tempdir(), paste0(out_name, '.tif'))

  # write GET contents as GTiff to tmpdir
  con <- file(out_temp, open = "wb")
  writeBin(httr::content(got), con)
  close(con)

  # pull back in and tidy up
  r <- raster::raster(out_temp)
  r[which(raster::getValues(r) == -9999)] <- NA_real_

  # write final product to working directory if directed
  if(write_out == TRUE) {
    out_dest <- file.path(getwd(), paste0(out_name, '.tif'))
    raster::writeRaster(r, out_dest, datatype = 'FLT4S', NAflag = -9999, overwrite = TRUE)
    raster::raster(out_dest)
  } else {
    r
  }
}
