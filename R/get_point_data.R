#' Get SLGA point data
#'
#' Get SLGA modelled soil data at a point location.
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}, where Type =
#'   'Soil'.
#' @param attribute Character, one of the options from column 'Code' in
#'   \code{\link[slga:slga_attribute_info]{slga_attribute_info}}
#' @param component Character, one of the following:
#' \itemize{
#'  \item 'VAL' - predicted value surface.
#'  \item 'CLO' - lower 95\% confidence interval surface.
#'  \item 'CHI' - upper 95\% confidence interval surface.
#'  \item 'CIS' - both confidence interval surfaces.
#'  \item 'ALL' - value and confidence interval surfaces.
#'  }
#'  Defaults to 'ALL'.
#' @param depth Integer, a number from 1 to 6. The numbers correspond to the
#'   following depth ranges:
#'  \enumerate{
#'   \item 0 to 5 cm.
#'   \item 5 to 15 cm.
#'   \item 15 to 30 cm.
#'   \item 30 to 60 cm.
#'   \item 60 to 100 cm.
#'   \item 100 to 200 cm.
#'   }
#' @param poi WGS84 coordinates defining a point of interest. Supply an
#'   sf-style point object (length-1 sfg or sfc, or single-row sf data frame) or
#'    a length-2 numeric vector (x, y).
#' @param buff Length-1 integer. Use if a summarised value around a point is desired.
#' Defaults to 0L, which returns the exact value(s) of the pixel under the `poi`.
#' A `buff` value of 1 will return a summary of the pixels in a one-cell range,
#' etc.
#' @param buff_shp One of 'square' or 'circle'. Use with buff > 0.
#' Defaults to 'square', in which case all values within the buffer are
#' summarised. A circular mask is applied to the data before summarising
#' otherwise.
#' @param stat Summary method applied where buff > 0. Defaults to median. Other
#' options include mean, modal, min, max, sd, IQR, quantile, and summary.
#' @return An data.frame with requested values.
#' @note If you have many points within a relatively small area, it will likely
#' be more efficient to grab a raster covering the whole area and extract
#' summary values yourself.
#' @importFrom raster as.data.frame cellStats raster stack
#' @examples {
#'   \donttest{
#'
#'   # get predicted clay value for 60-100cm at a point
#'   clay_pt <- get_soils_point('NAT', 'CLY', 'VAL', 5, c(153,-27.5))
#'
#'   # get the average predicted clay content for 60-100cm within ~300m
#'   avg_clay <- get_soils_point('NAT', 'CLY', 'ALL', 5, c(153, -27.5),
#'                               buff = 3, buff_shp = 'circle', stat = 'mean')
#'   }
#' }
#' @export
#'
get_soils_point <- function(product = NULL, attribute = NULL, component = 'ALL',
                            depth = NULL, poi = NULL, buff = 0L,
                            buff_shp = c('square', 'circle'), stat = 'median') {
  buff_shp <- match.arg(buff_shp)
  if(length(stat) > 1) { stop('Please request one stat at a time.') }
  # check availability
  if(check_avail(product, attribute) == FALSE) {
    stop("The requested attribute is not available as part of the requested
         product. Please check data('slga_attribute_info').")
  }

  # generate aoi from poi
  aoi <- validate_poi(poi = poi, product = product, buff = buff)

  # get data
  if(component == 'ALL') {
   data <- lapply(c('VAL', 'CLO', 'CHI'), function(l) {
      get_soils_raster(product, attribute, component = l,
                       depth, aoi, skip_val = TRUE)
      })
   data <- raster::stack(data)
  }

  if(component == 'CIS') {
    data <- lapply(c('CLO', 'CHI'), function(l) {
      get_soils_raster(product, attribute, component = l,
                       depth, aoi, skip_val = TRUE)
    })
    data <- raster::stack(data)
  }

  if(component %in% c('VAL', 'CLO', 'CHI')) {
    data <- get_soils_raster(product, attribute, component,
                             depth, aoi, skip_val = TRUE)
  }
  d_nm <- names(data)

  if(buff == 0) {
    return(as.data.frame(data))
  }

  # mask if asked
  if(all(buff_shp == 'circle', buff > 0)) {
    masker <- raster(data)
    masker[] <- make_circ_mask(buff)
    data <- data + masker
  }

  # otherwise, get stat for each layer
  summarised <- if(stat %in% c('quantile', 'summary')) {
    data.frame(unclass(
      raster::cellStats(data, stat = match.fun(stat), na.rm = TRUE)))
  } else {
    data.frame(as.list(
      raster::cellStats(data, stat = match.fun(stat), na.rm = TRUE)))
  }
  names(summarised) <- d_nm
  if(stat %in% c('quantile', 'summary')) {
    summarised$summary_method <- rownames(summarised)
    rownames(summarised) <- NULL
  } else  {
    summarised$summary_method <- stat
  }

  if(buff > 0) {
    summarised$ncells <- if(buff_shp == 'circle') {
      length(which(!is.na(masker[])))
    } else {
      (buff * 2 + 1) ^ 2
    }
  }

  summarised

  }

#' Get SLGA point landscape data
#'
#' Get SLGA landscape covariate data at a point location.
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}, where Type =
#'   'Landscape'.
#' @param poi WGS84 coordinates defining a point of interest. Supply an
#'   sf-style point object or a length-2 numeric vector (x, y).
#' @param buff Length-1 integer. Use if a summarised value around a point is desired.
#' Defaults to 0L, which returns the exact value(s) of the pixel under the `poi`.
#' A `buff` value of 1 will return a summary of the pixels in a one-cell range,
#' etc.
#' @param buff_shp One of 'square' or 'circle'. Use with buff > 0.
#' Defaults to 'square', in which case all values within the buffer are
#' summarised. A circular mask is applied to the data before summarising
#' otherwise.
#' @param stat Summary method applied where buff > 0. Defaults to median. Other
#' options include mean, modal, min, max, sd, IQR, quantile, and summary.
#' @return An data.frame with requested values.
#' @note If you have many points within a relatively small area, it will likely
#' be more efficient to grab a raster covering the whole area and extract
#' summary values yourself.
#' @importFrom httr http_error
#' @importFrom raster as.data.frame cellStats raster
#' @examples {
#'   \donttest{
#'
#'      # get the slope at a point
#'      slope_pt <- get_lscape_point('SLPPC', c(153,-27.5))
#'
#'      # get the average slope within ~300m of a point
#'      avg_slope <- get_lscape_point('SLPPC', c(153, -27.5),
#'                                    buff = 3, buff_shp = 'circle', stat = 'mean')
#'      }
#'  }
#' @export
#'
get_lscape_point <- function(product = NULL, poi = NULL,
                             buff = 0L, buff_shp = c('square', 'circle'),
                             stat = 'median') {
  buff_shp <- match.arg(buff_shp)
  if(length(stat) > 1) { stop('Please request one stat at a time.') }

  # generate aoi from poi
  aoi <- validate_poi(poi = poi, product = product, buff = buff)

  # generate URL
  this_url <- make_lscape_url(product = product, aoi = aoi)

  # code up filename
  out_temp <- paste0(tempfile(), '_SLGA_', product, '.tif')
  # get data
  gr <- get_slga_data(url = this_url, out_temp)
  if(httr::http_error(gr)) {
    stop(paste0('http error ', httr::status_code(gr), '.'))
  }
  # read in tempfile and tidy up
  data <- raster::raster(out_temp)
  data <- tidy_lscape_data(data, product, write_out = FALSE)
  d_nm <- names(data)

  if(buff == 0) {
    return(as.data.frame(data))
  }

  # mask if asked
  if(all(buff_shp == 'circle', buff > 0)) {
    masker <- raster(data)
    masker[] <- make_circ_mask(buff)
    data <- data + masker
  }

  # otherwise, get stat for each layer
  summarised <- if(stat %in% c('quantile', 'summary')) {
    data.frame(unclass(
      raster::cellStats(data, stat = match.fun(stat), na.rm = TRUE)))
  } else {
    data.frame(as.list(
      raster::cellStats(data, stat = match.fun(stat), na.rm = TRUE)))
  }
  names(summarised) <- d_nm
  if(stat %in% c('quantile', 'summary')) {
    summarised$summary_method <- rownames(summarised)
    rownames(summarised) <- NULL
  } else  {
    summarised$summary_method <- stat
  }

  if(buff > 0) {
    summarised$ncells <- if(buff_shp == 'circle') {
      length(which(!is.na(masker[])))
    } else {
      (buff * 2 + 1) ^ 2
    }
  }

  summarised

}
