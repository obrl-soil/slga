#' download single SLGA soils raster subset
#'
#' Retrieves SLGA gridded soil data in raster format from WCS service.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}, where Type =
#'   'Soil'.
#' @param attribute Character, one of the options from column 'Code' in
#'   \code{\link[slga:slga_attribute_info]{slga_attribute_info}}
#' @param component Character, one of 'value', 'ci_low', or 'ci_high'.
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
#' @param aoi Vector of WGS84 coordinates defining a rectangular area of
#'   interest. The vector may be specified directly in the order xmin, xmax,
#'   ymin, ymax, or the function can derive an aoi from the boundary of an `sf`
#'   or `raster` object.
#' @return Raster dataset for a single combination of product, attribute,
#'   component, depth, and area of interest.
#' @note aoi's wider or taller than 1 decimal degree are retrieveable, but be
#'   aware that download file size will be large. If you want a dataset that
#'   covers more than ~3x3', it will likely be faster to download the full
#'   GeoTIFF from the CSIRO Data Access Portal and crop out your AOI using GDAL.
#' @keywords internal
#' @importFrom httr content GET http_error status_code user_agent write_disk
#' @importFrom raster getValues raster writeRaster
#'
get_soils_raster <- function(product   = NULL,
                             attribute = NULL,
                             component = NULL,
                             depth     = NULL,
                             aoi       = NULL) {

  # check availability
  if(check_avail(product, attribute) == FALSE) {
    stop("The requested attribute is not available as part of the requested
         product. Please check data('slga_attribute_info').")
  }

  # generate URL
  this_url <- make_soils_url(product = product, attribute = attribute,
                             component = component, depth = depth,
                             aoi = aoi)

  # code up filename
  depth_pretty <- switch(depth,
                         `1` = "000_005", `2` = "005_015", `3` = "015_030",
                         `4` = "030_060", `5` = "060_100", `6` = "100_200")
  out_name <- paste(product, attribute, toupper(component), depth_pretty,
                    sep = '_')

  # get data, send to temp file(s)
  r <- if(is.list(this_url)) {
    message("Requesting a large volume of data, please be patient.")

    dat <- lapply(this_url, function(x) {
      out_temp <- paste0(tempfile(), '_SLGA_', out_name, '.tif')
      gr <- get_slga_data(url = x, out_temp)
      if(httr::http_error(gr)) {
        stop(paste0('http error ', httr::status_code(gr), '.'))
      }
      Sys.sleep(0.2)
    raster::raster(out_temp)
    })
    # https://gis.stackexchange.com/a/104109/76240 \o/
    dat$fun <- mean
    do.call(raster::mosaic, dat)

  } else {
    out_temp <- paste0(tempfile(), '_SLGA_', out_name, '.tif')
    gr <- get_slga_data(url = this_url, out_temp)
    if(httr::http_error(gr)) {
      stop(paste0('http error ', httr::status_code(gr), '.'))
      }
    # read in temp and tidy up
    raster::raster(out_temp)
  }

  tidy_soils_data(r, out_name)
}

#' Get SLGA soils data
#'
#' Downloads SLGA gridded soils data in raster format from public WCS
#' services.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}, where Type =
#'   'Soil'.
#' @param attribute Character, one of the options from column 'Code' in
#'   \code{\link[slga:slga_attribute_info]{slga_attribute_info}}.
#' @param component Character, one of 'all', 'value', 'ci', 'ci_low', or
#'   'ci_high'. Defaults to 'all'.
#' @param depth Integer from 1 to 6. The numbers correspond to the
#'   following depth ranges:
#'  \enumerate{
#'   \item 0 to 5 cm.
#'   \item 5 to 15 cm.
#'   \item 15 to 30 cm.
#'   \item 30 to 60 cm.
#'   \item 60 to 100 cm.
#'   \item 100 to 200 cm.
#'   }
#' @param aoi Vector of WGS84 coordinates defining a rectangular area of
#'   interest. The vector may be specified directly in the order xmin, ymin,
#'   xmax, ymax, or the function can derive an aoi from the boundary of an `sf`
#'   or `raster` object.
#' @param write_out Boolean, whether to write the retrieved dataset to the
#'   working directory as a GeoTiff.
#' @return Raster stack or single raster, depending on the value of `component`.
#' @note \itemize{
#'   \item An aoi larger than 1x1 decimal degree is retrieveable, but be
#'   aware that download file size will be large. If you want a dataset that
#'   covers more than ~3x3', it will likely be faster to download the full
#'   GeoTIFF from the CSIRO Data Access Portal and crop out your AOI using GDAL.
#'   \item Output rasters are aligned to the parent dataset rather than the aoi.
#'   Further resampling may be required for some applications.
#'   }
#' @examples \dontrun{
#' # get surface clay data for King Island
#' aoi <- c(143.75, -40.17, 144.18, -39.57)
#' ki_surface_clay <- get_soils_data(product = 'TAS', attribute = 'CLY',
#'                                   component = 'all', depth = 1,
#'                                   aoi = aoi, write_out = FALSE)
#'
#' # get estimated clay by depth for King Island
#' ki_all_clay <- lapply(seq.int(6), function(d) {
#'   get_soils_data(product = 'TAS', attribute = 'CLY',
#'                  component = 'value', depth = d,
#'                  aoi = aoi, write_out = FALSE)
#' })
#' ki_all_clay <- raster::brick(ki_all_clay)
#' }
#' @importFrom raster raster stack writeRaster
#' @importFrom utils data
#' @export
#'
get_soils_data <- function(product   = NULL,
                           attribute = NULL,
                           component = 'all',
                           depth     = NULL,
                           aoi       = NULL,
                           write_out = TRUE) {

  component <- match.arg(component,
                          c('all', 'ci', 'value', 'ci_low', 'ci_high'))

  if(!(depth %in% seq.int(6))) {
    stop('Please choose a value between 1 and 6 for depth.')
  }

  depth_pretty <- switch(depth,
                         `1` = "000_005", `2` = "005_015", `3` = "015_030",
                         `4` = "030_060", `5` = "060_100", `6` = "100_200")
  switch(component, 'all' = {
    val <- get_soils_raster(product = product, attribute = attribute,
                            component = 'value', depth = depth, aoi = aoi)
    clo <- suppressMessages(
      get_soils_raster(product = product, attribute = attribute,
                       component = 'ci_low', depth = depth, aoi = aoi)
      )
    chi <-  suppressMessages(
      get_soils_raster(product = product, attribute = attribute,
                       component = 'ci_high', depth = depth, aoi = aoi)
      )

    s <- raster::stack(val, clo, chi)
    names(s) <- paste(product, attribute, c('VAL', 'CLO', 'CHI'), depth_pretty,
                      sep = '_')

    if(write_out == TRUE) {
      out_name <- paste(product, attribute, 'ALL', depth_pretty, sep = '_')
      out_dest <- file.path(getwd(), paste0(out_name, '.tif'))
      raster::writeRaster(s, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      s <- raster::stack(out_dest)
      names(s) <- paste(product, attribute, c('VAL', 'CLO', 'CHI'), depth_pretty,
                        sep = '_')
      raster::crs(r) <- paste0('+init=EPSG:4283 ', raster::crs(r))
      s
    } else {
      s
    }
  },
  'ci' = {
    clo <- get_soils_raster(product = product, attribute = attribute,
                             component = 'ci_low', depth = depth, aoi = aoi)
    chi <-  suppressMessages(
      get_soils_raster(product = product, attribute = attribute,
                       component = 'ci_high', depth = depth, aoi = aoi)
    )

    s <- raster::stack(clo, chi)
    names(s) <- paste(product, attribute, c('CLO', 'CHI'), depth_pretty,
                      sep = '_')

    if(write_out == TRUE) {
      out_name <- paste(product, attribute, 'CIS', depth_pretty, sep = '_')
      out_dest <- file.path(getwd(), paste0(out_name, '.tif'))
      raster::writeRaster(s, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      s <- raster::stack(out_dest)
      names(s) <- paste(product, attribute, c('CLO', 'CHI'), depth_pretty,
                        sep = '_')
      raster::crs(r) <- paste0('+init=EPSG:4283 ', raster::crs(r))
      s
    } else {
      s
    }
  },
  'value' = {
    val <- get_soils_raster(product = product, attribute = attribute,
                            component = 'value', depth = depth, aoi = aoi)
    names(val) <- paste(product, attribute, 'VAL', depth_pretty,
                      sep = '_')
    if(write_out == TRUE) {
      out_dest <- file.path(getwd(), paste0(names(val), '.tif'))
      raster::writeRaster(val, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      val <- raster::raster(out_dest)
      names(val) <- paste(product, attribute, 'VAL', depth_pretty,
                          sep = '_')
      raster::crs(r) <- paste0('+init=EPSG:4283 ', raster::crs(r))
      val
    } else {
      val
    }
  },
  'ci_low' = {
    clo <- get_soils_raster(product = product, attribute = attribute,
                            component = 'ci_low', depth = depth, aoi = aoi)
    names(clo) <- paste(product, attribute, 'CLO', depth_pretty,
                        sep = '_')
    if(write_out == TRUE) {
      out_dest <- file.path(getwd(), paste0(names(clo), '.tif'))
      raster::writeRaster(clo, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      clo <- raster::raster(out_dest)
      names(clo) <- paste(product, attribute, 'CLO', depth_pretty,
                          sep = '_')
      raster::crs(r) <- paste0('+init=EPSG:4283 ', raster::crs(r))
      clo
    } else {
      clo
    }
  },
  'ci_high' = {
    chi <- get_soils_raster(product = product, attribute = attribute,
                            component = 'ci_high', depth = depth, aoi = aoi)
    names(chi) <- paste(product, attribute, 'CHI', depth_pretty,
                        sep = '_')
    if(write_out == TRUE) {
      out_dest <- file.path(getwd(), paste0(names(chi), '.tif'))
      raster::writeRaster(chi, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      chi <- raster::raster(out_dest)
      names(chi) <- paste(product, attribute, 'CHI', depth_pretty,
                          sep = '_')
      raster::crs(r) <- paste0('+init=EPSG:4283 ', raster::crs(r))
      chi
    } else {
      chi
    }
  }
  )
}

#' Get SLGA landscape data
#'
#' Downloads SLGA gridded landscape data in raster format from public WCS
#' services.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}, where Type =
#'   'Landscape'.
#' @param aoi Vector of WGS84 coordinates defining a rectangular area of
#'   interest. The vector may be specified directly in the order xmin, xmax,
#'   ymin, ymax, or the function can derive an aoi from the boundary of an `sf`
#'   or `raster` object.
#' @param write_out Boolean, whether to write the retrieved dataset to the
#'   working directory as a GeoTiff.
#' @return Raster dataset for a single landscape product.
#' @note \itemize{
#'   \item An aoi larger than 1x1 decimal degree is retrieveable, but be
#'   aware that download file size will be large. If you want a dataset that
#'   covers more than ~3x3', it will likely be faster to download the full
#'   GeoTIFF from the CSIRO Data Access Portal and crop out your AOI using GDAL.
#'   \item Output rasters are aligned to the parent dataset rather than the aoi.
#'   Further resampling may be required for some applications.
#'   }
#' @importFrom httr content GET http_error status_code user_agent write_disk
#' @importFrom raster getValues raster subs writeRaster
#' @examples \dontrun{
#' # get slope data for King Island
#' aoi <- c(143.75, -40.17, 144.18, -39.57)
#' ki_slope <- get_lscape_data(product = 'SLPPC', aoi = aoi, write_out = FALSE)
#'
#' # get slope, aspect and relief class data for King Island
#' ki_SAR <- lapply(c('SLPPC', 'ASPCT', 'RELCL'), function(t) {
#'   get_lscape_data(product = t, aoi = aoi, write_out = FALSE)
#' })
#' }
#' @export
#'
get_lscape_data <- function(product   = NULL,
                            aoi       = NULL,
                            write_out = TRUE) {

  this_url <- make_lscape_url(product = product, aoi = aoi)

  # get data, send to temp file(s) - handle tiled requests
  r <- if(is.list(this_url)) {
    message("Requesting a large volume of data, please be patient.")

    dat <- lapply(this_url, function(x) {
        out_temp <- paste0(tempfile(), '_SLGA_', product, '.tif')
        gr <- get_slga_data(url = x, out_temp)

        if(httr::http_error(gr)) {
          stop(paste0('http error ', httr::status_code(gr), '.'))
        }
        Sys.sleep(0.2)
        raster::raster(out_temp)
      })
    dat$fun <- mean
    do.call(raster::mosaic, dat)

  } else {
    out_temp <- paste0(tempfile(), '_SLGA_', product, '.tif')
    gr <- get_slga_data(url = this_url, out_temp)

    if(httr::http_error(gr)) {
      stop(paste0('http error ', httr::status_code(gr), '.'))
    }

    raster::raster(out_temp)
  }

  tidy_lscape_data(r, product, write_out)
}
