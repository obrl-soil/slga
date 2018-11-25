#' Make SLGA WCS URL
#'
#' Generate the URL for a particular product, attribute, component and depth
#' available from the Soil and Landscape Grid of Australia.
#'
#' @param product Character, one of the options from column 'Code' in
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
#' @keywords Internal
#' @importFrom utils data
#'
make_slga_url <- function(product = NULL, attribute = NULL,
                          component = NULL, depth = NULL,
                          aoi = NULL) {

  url_root <- "http://www.asris.csiro.au/ArcGis/services/TERN"
  utils::data('slga_product_info', envir = environment())
  utils::data('slga_attribute_info', envir = environment())

  product   <- match.arg(product,   slga_product_info$Code)
  attribute <- match.arg(attribute, slga_attribute_info$Code)
  component <- match.arg(component, c('value', 'ci_low', 'ci_high'))
  component <- switch(component, 'value' = 0L, 'ci_high' = 1L, 'ci_low' = 2L)
  layer_id  <- component + as.integer(depth)

  # aoi extent checking handled in helper function
  aoi <- validate_aoi(aoi, product)

  res <- abs(
    c(slga_product_info$offset_x[which(slga_product_info$Code == product)],
      slga_product_info$offset_y[which(slga_product_info$Code == product)]))

  cols <- round(abs(aoi[1] - aoi[3]) / res[1])
  rows <- round(abs(aoi[2] - aoi[4]) / res[2])

  paste0(url_root, "/", attribute, "_", product, "/MapServer/WCSServer?",
         "REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=", layer_id,
         "&CRS=EPSG:4283&BBOX=", paste(aoi, collapse = ','),
         "&WIDTH=", cols,
         "&HEIGHT=", rows,
         "&FORMAT=GeoTIFF")
}
