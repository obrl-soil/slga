#' Validate soils product/attribute combination
#'
#' Check whether the requested soils attribute is available for the requested
#' soils product.
#'
#' @param product Character, one of the options from column 'Code' in
#'   code{\link[slga:slga_product_info]{slga_product_info}} where Type = 'Soil'.
#' @param attribute Character, one of the options from column 'Code' in
#'   code{\link[slga:slga_attribute_info]{slga_attribute_info}}.
#' @return Logical; TRUE if available
#' @examples
#' check_avail('NAT', 'CFG')
#' check_avail('SA',  'CFG')
#' @importFrom utils data
#' @export
#'
check_avail <- function(product = NULL, attribute = NULL) {
  slga_attribute_info <- NULL
  utils::data('slga_attribute_info', envir = environment())
  slga_attribute_info[which(slga_attribute_info$Code == attribute), product]
}

#' Filename generator
#'
#' generates a filename for an SLGA raster request
#' @param product Character, one of the options from column 'Code' in
#'   code{\link[slga:slga_product_info]{slga_product_info}} where Type = 'Soil'.
#' @param attribute Character, one of the options from column 'Code' in
#'   code{\link[slga:slga_attribute_info]{slga_attribute_info}}.
#' @param component Character, one of 'ALL', 'VAL', 'CIS', 'CLO', or
#'   'CHI'. Defaults to 'ALL'.
#' @param depth Integer from 1 to 6.
#' @return filename string
#' @keywords internal
#'
slga_filenamer <- function(product = NULL, attribute = NULL,
                           component = NULL, depth = NULL) {
  depth_pretty <- switch(depth,
                         `1` = "000_005", `2` = "005_015", `3` = "015_030",
                         `4` = "030_060", `5` = "060_100", `6` = "100_200")
  paste(product, attribute, component, depth_pretty, sep = '_')
}

#' GET soil or landscape data
#'
#' Quietly sends a httr GET request to an SLGA web service endpoint.
#'
#' @param url valid output from \code{\link[slga:make_soils_url]{make_soils_url}}
#'  or \code{\link[slga:make_lscape_url]{make_lscape_url}}
#' @param out_temp location to write content - valid file path with .tif
#'   extension.
#' @return httr \code{\link[httr:response]{response()}} object with content
#'   stored on disk
#' @keywords internal
#' @importFrom httr GET user_agent write_disk
#'
get_slga_data <- function(url = NULL, out_temp = NULL) {
  suppressMessages(
  httr::GET(url = url, httr::write_disk(out_temp),
            httr::user_agent('https://github.com/obrl-soil/slga')))
}

#' Make a circular mask
#'
#' Generates a circular masking matrix
#' @param buff The number of cells away from the central cell to mask. The
#' return matrix will have dimensions of (2 \* buff) + 1.
#' @return masking matrix for use in point queries with values of 0 in the 'keep
#' zone' and NA otherwise.
#' @keywords internal
#' @note adapted from
#'   https://scrogster.wordpress.com/2012/10/05/applying-a-circular-moving-window-filter-to-raster-data-in-r/
#'   . Used in SLGA when getting summary statistics around points, but can
#'   potentially be applied to any raster/point data combination. See recipe
#'   below.
#' @examples \dontrun{
#' library(raster)
#' library(sf)
#' # concept demo
#' plot(sf::st_buffer(sf::st_point(c(0,0)), 5), axes = TRUE, reset = FALSE)
#' plot(raster::raster(make_circ_mask(10),
#'      xmn = -5, xmx = 5, ymn = -5, ymx = 5), add = TRUE)
#'
#' # test with real data
#' poi <- c(152, -27)
#' aoi <- validate_poi(poi = poi, product = 'SLPPC', buff = 3)
#' slope <- get_lscape_data('SLPPC', aoi)
#' plot(slope)
#' masker <- raster(slope)
#' masker[] <- make_circ_mask(5)
#' slope <- slope + masker
#' plot(slope)
#' plot(st_point(poi), add = T, pch = 19, col = 'red')
#' plot(sf::st_buffer(sf::st_centroid(sf::st_as_sfc(aoi)),
#'      0.000833 * 5), add = TRUE)
#'
#' }
#'
make_circ_mask <- function(buff = NULL) {

  size <- buff * 2 + 1
  prog <- seq(-buff, buff)

  vals <- mapply(function(row, col) {
     dist <- sqrt(prog[row] ^ 2 + prog[col] ^ 2)
     if(dist <= buff) { 0L } else { NA_integer_}
    },
    row = rep(seq(size), times = size),
    col = rep(seq(size), each  = size)
  )
  matrix(vals, ncol = size, nrow = size, byrow = TRUE)
}
