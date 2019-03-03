#' Make SLGA WCS URL
#'
#' Generate the URL for a particular soils product, attribute, component and
#' depth available from the Soil and Landscape Grid of Australia.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}.
#' @param attribute Character, one of the options from column 'Code' in
#'   \code{\link[slga:slga_attribute_info]{slga_attribute_info}}, where 'Type' =
#'   'Soil'.
#' @param component Character, one of 'VAL', 'CLO', or 'CHI'.
#' @param depth Integer, a number from 1 to 6.
#' @param aoi Vector of WGS84 coordinates defining a rectangular area of
#'   interest. The vector may be specified directly in the order xmin, ymin,
#'   xmax, ymax, or the function can derive an aoi from the boundary of an `sf`
#'   or `raster` object.
#' @param req_type Character; one of 'cap', 'cov' or 'desc'. Defaults to 'cov'.
#' @keywords internal
#' @importFrom utils data
#'
make_soils_url <- function(product = NULL, attribute = NULL,
                          component = NULL, depth = NULL,
                          aoi = NULL, req_type = 'cov') {

  slga_product_info <- NULL
  utils::data('slga_product_info', envir = environment())
  slga_attribute_info <- NULL
  utils::data('slga_attribute_info', envir = environment())

  req_type <- match.arg(req_type, c('cap', 'cov', 'desc'))
  url_root <- "http://www.asris.csiro.au/ArcGis/services/TERN"
  product   <-
    match.arg(product,
              slga_product_info$Short_Name[which(slga_product_info$Type == 'Soil')])
  product_long <-
    slga_product_info$Code[which(slga_product_info$Short_Name == product)]
  if(is.null(attribute)) { stop('Please specify an attribute.') } # fu match.arg
  attribute <- match.arg(attribute, slga_attribute_info$Code)

  #getcap operates at a higher level so
  if(req_type == 'cap') {
    return(
      paste0(url_root, "/", attribute, "_", product_long,
           "/MapServer/WCSServer?",
           "REQUEST=GetCapabilities&SERVICE=WCS&VERSION=1.0.0")
    )
  }

  # desccov can operate at service or coverage level so
  if(all(req_type == 'desc', is.null(depth))) {
    return(
    paste0(url_root, "/", attribute, "_", product_long,
           "/MapServer/WCSServer?",
           "REQUEST=DescribeCoverage&SERVICE=WCS&VERSION=1.0.0")
    )
  }

  component <- match.arg(component, c('VAL', 'CLO', 'CHI'))
  if(!(depth %in% seq.int(6))) {
    stop('Please choose a value between 1 and 6 for depth.')
  }

  component <- switch(component, 'VAL' = 0L, 'CHI' = 1L, 'CLO' = 2L)
  depth     <- switch(depth, `1` =  1L, `2` =  4L, `3` = 7L,
                             `4` = 10L, `5` = 13L, `6` = 16L)
  layer_id  <- component + depth

  switch(
    req_type,
    # layer level description
    'desc' =
      paste0(url_root, "/", attribute, "_", product_long,
             "/MapServer/WCSServer?",
             "REQUEST=DescribeCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=",
             layer_id),
    # actual data
    'cov' = {
      res <- abs(
        c(slga_product_info$offset_x[which(slga_product_info$Short_Name == product)],
          slga_product_info$offset_y[which(slga_product_info$Short_Name == product)]))

      if(is.list(aoi)) {
        lapply(aoi, function(x) {
          cols <- round(abs(x[1] - x[3]) / res[1])
          rows <- round(abs(x[2] - x[4]) / res[2])
          paste0(url_root, "/", attribute, "_", product_long, "/MapServer/WCSServer?",
                 "REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=", layer_id,
                 "&CRS=EPSG:4283&BBOX=", paste(x, collapse = ','),
                 "&WIDTH=", cols,
                 "&HEIGHT=", rows,
                 "&FORMAT=GeoTIFF")
        })
        } else {
          cols <- round(abs(aoi[1] - aoi[3]) / res[1])
          rows <- round(abs(aoi[2] - aoi[4]) / res[2])
          paste0(url_root, "/", attribute, "_", product_long, "/MapServer/WCSServer?",
             "REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=", layer_id,
             "&CRS=EPSG:4283&BBOX=", paste(aoi, collapse = ','),
             "&WIDTH=", cols,
             "&HEIGHT=", rows,
             "&FORMAT=GeoTIFF")
      }
    }
  )
}

#' Make SLGA Landscape URL
#'
#' Generate the URL for a particular landscape attribute available from the Soil
#' and Landscape Grid of Australia.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}, where Type =
#'   'Landscape'.
#' @param aoi Vector of WGS84 coordinates defining a rectangular area of
#'   interest. The vector may be specified directly in the order xmin, ymin,
#'   xmax, ymax, or the function can derive an aoi from the boundary of an `sf`
#'   or `raster` object.
#' @param req_type Character; one of 'cap', 'cov', or 'desc'. Defaults to
#'   'cov'.
#' @keywords internal
#' @importFrom utils data
#'
make_lscape_url <- function(product = NULL, aoi = NULL, req_type = 'cov') {

  req_type <- match.arg(req_type, c('cap', 'cov', 'desc'))
  url_root <- "http://www.asris.csiro.au/ArcGis/services/TERN"
  service_root <- "/SRTM_attributes_3s_ACLEP_AU/MapServer/WCSServer?"

  if(req_type == 'cap') {
    return(
      paste0(url_root, service_root,
             "REQUEST=GetCapabilities&SERVICE=WCS&VERSION=1.0.0")
    )
  }

  if(all(req_type == 'desc', is.null(product))) {
    return(
      paste0(url_root, service_root,
             "REQUEST=DescribeCoverage&SERVICE=WCS&VERSION=1.0.0")
    )
  }

  slga_product_info <- NULL
  utils::data('slga_product_info', envir = environment())

  if(is.null(product)) { stop('Please specify a product.')}
  product   <-
    match.arg(product,
              slga_product_info$Short_Name[which(slga_product_info$Type
                                                 == 'Landscape')])
  layers    <-
    slga_product_info$Short_Name[which(slga_product_info$Type == 'Landscape')]
  layer_id  <- which(layers == product)

  if(req_type == 'desc') {
    return(
      paste0(url_root, service_root,
             "REQUEST=DescribeCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=",
             layer_id)
    )
  }

  res <- abs(
    c(slga_product_info$offset_x[which(slga_product_info$Short_Name == product)],
      slga_product_info$offset_y[which(slga_product_info$Short_Name == product)]))

  #### else if coverage request: ###

  if(is.list(aoi)) {
    lapply(aoi, function(x) {
      cols <- round(abs(x[1] - x[3]) / res[1])
      rows <- round(abs(x[2] - x[4]) / res[2])
      paste0(url_root, service_root,
             "REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=", layer_id,
             "&CRS=EPSG:4283&BBOX=", paste(x, collapse = ','),
             "&WIDTH=", cols,
             "&HEIGHT=", rows,
             "&FORMAT=GeoTIFF")
    })
  } else {
    cols <- round(abs(aoi[1] - aoi[3]) / res[1])
    rows <- round(abs(aoi[2] - aoi[4]) / res[2])
    paste0(url_root, service_root,
           "REQUEST=GetCoverage&SERVICE=WCS&VERSION=1.0.0&COVERAGE=", layer_id,
           "&CRS=EPSG:4283&BBOX=", paste(aoi, collapse = ','),
           "&WIDTH=", cols,
           "&HEIGHT=", rows,
           "&FORMAT=GeoTIFF")
  }
}

#' Make point URL
#'
#' Generate the URL for a point data query on the Soil and Landscape Grid of
#' Australia.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}, where Type =
#'   'Landscape'.
#' @param poi Vector of WGS84 coordinates defining a point area of
#'   interest. The vector may be specified directly in the order x, y,
#'   or the function can take in `sf` point objects.
#  @param buffer Boolean, whether to retrieve summary values for a buffered area
#   around each point.
#  @param stat Character; when buffer = TRUE, which summary to use. Defaults to
#    median.
#' @return URL string containing supplied parameters. NB not using this one yet.
#' @keywords internal
#' @importFrom utils data
#'
make_point_url <- function(product = NULL, poi = NULL) {

  url_root <- "http://www.asris.csiro.au/ASRISApi/api/SLGA/simple/Drill?"

  paste0(url_root,
         'longitude=', poi[1], '&latitude=', poi[2],
         '&layers=ALL', '&kernal=0', '&json=true')

}
