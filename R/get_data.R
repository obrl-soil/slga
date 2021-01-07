#' Download single SLGA soils raster subset
#'
#' Retrieves SLGA gridded soil data in raster format from WCS service.
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}, where Type =
#'   'Soil'.
#' @param attribute Character, one of the options from column 'Code' in
#'   \code{\link[slga:slga_attribute_info]{slga_attribute_info}}
#' @param component Character, one of 'VAL', 'CLO', or 'CHI'.
#' @param depth Integer, a number from 1 to 6.
#' @param aoi Vector of WGS84 coordinates defining a rectangular area of
#'   interest. The vector may be specified directly in the order xmin, xmax,
#'   ymin, ymax, or the function can derive an aoi from the boundary of an `sf`
#'   or `raster` object.
#' @param skip_val boolean, filthy hack for point data requests, prevents double
#' validation expanding bbox size
#' @return Raster dataset for a single combination of product, attribute,
#'   component, depth, and area of interest.
#' @note aoi's wider or taller than 1 decimal degree are retrievable, but be
#'   aware that download file size will be large. If you want a dataset that
#'   covers more than ~3x3', may be faster to download the full
#'   GeoTIFF from the CSIRO Data Access Portal and crop out your AOI using GDAL.
#' @keywords internal
#' @importFrom httr content GET http_error status_code user_agent write_disk
#' @importFrom raster getValues raster writeRaster
#' @importFrom utils setTxtProgressBar txtProgressBar
#'
get_soils_raster <- function(product   = NULL,
                             attribute = NULL,
                             component = NULL,
                             depth     = NULL,
                             aoi       = NULL,
                             skip_val  = FALSE) {

  # check availability
  if(check_avail(product, attribute) == FALSE) {
    stop("The requested attribute is not available as part of the requested
         product. Please check data('slga_attribute_info').")
  }

  # validate aoi
  if(skip_val == FALSE) {
    aoi <- validate_aoi(aoi, product)
  }

  # generate URL
  this_url <- make_soils_url(product = product, attribute = attribute,
                             component = component, depth = depth,
                             aoi = aoi)

  # code up filename
  out_name <- slga_filenamer(product = product, attribute = attribute,
                             component = component, depth = depth)
  # get data, send to temp file(s)
  r <- if(is.list(this_url)) {
    message("Requesting a large volume of data, please be patient...")
    pb <- utils::txtProgressBar(min = 0, max = length(this_url), style = 3)
    dat <- mapply(function(x, i) {
      out_temp <- paste0(tempfile(), '_SLGA_', out_name, '.tif')
      gr <- get_slga_data(url = x, out_temp)
      if(httr::http_error(gr)) {
        stop(paste0('http error ', httr::status_code(gr), '.'))
      }
      Sys.sleep(0.2)
      utils::setTxtProgressBar(pb, i)
      raster::raster(out_temp)
      }, x = this_url, i = seq_along(this_url))
    close(pb)
    # https://gis.stackexchange.com/a/104109/76240 \o/
    dat$fun <- mean
    # CRS warnings spurious and redundant with later amendment
    suppressWarnings(do.call(raster::mosaic, dat))

  } else {
    out_temp <- paste0(tempfile(), '_SLGA_', out_name, '.tif')
    gr <- get_slga_data(url = this_url, out_temp)
    if(httr::http_error(gr)) {
      stop(paste0('http error ', httr::status_code(gr), '.'))
    }
    # CRS warning spurious and redundant with later amendment
    suppressWarnings(raster::raster(out_temp))
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
#' @param component Character, one of the following:
#' \itemize{
#'  \item 'VAL' - predicted value surface.
#'  \item 'CLO' - lower 95\% confidence interval surface.
#'  \item 'CHI' - upper 95\% confidence interval surface.
#'  \item 'CIS' - both confidence interval surfaces.
#'  \item 'ALL' - value and both confidence interval surfaces.
#'  }
#'  Defaults to 'ALL'.
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
#' @param write_out Boolean, whether to write the retrieved dataset to disk.
#'   Defaults to FALSE.
#' @param filedir directory in which to write files if write_out == TRUE.
#' @return Raster stack or single raster, depending on the value of `component`.
#' @note \itemize{
#'   \item An aoi larger than 1x1 decimal degree is retrieveable, but be
#'   aware that download file size will be large. If you want a dataset that
#'   covers more than ~3x3', it may be faster to download the full
#'   GeoTIFF from the CSIRO Data Access Portal and crop out your AOI using GDAL.
#'   \item Output rasters are aligned to the parent dataset rather than the aoi.
#'   Further resampling may be required for some applications.
#'   \item specify `depth = 1` for attributes 'DES' and 'DER' as they are
#'   whole-of-profile parameters.
#'   }
#' @examples \donttest{
#' # get surface clay data for central Brisbane
#' aoi <- c(152.95, -27.55, 153.07, -27.45)
#' bne_surface_clay <- get_soils_data(product = 'NAT', attribute = 'CLY',
#'                                    component = 'ALL', depth = 1,
#'                                    aoi = aoi, write_out = FALSE)
#'
#' # get estimated clay by depth for central Brisbane
#' bne_all_clay <- lapply(seq.int(6), function(d) {
#'   get_soils_data(product = 'NAT', attribute = 'CLY',
#'                  component = 'VAL', depth = d,
#'                  aoi = aoi, write_out = FALSE)
#' })
#' bne_all_clay <- raster::brick(bne_all_clay)
#' }
#' @importFrom raster raster stack writeRaster
#' @importFrom utils data
#' @export
#'
get_soils_data <- function(product   = NULL,
                           attribute = NULL,
                           component = 'ALL',
                           depth     = NULL,
                           aoi       = NULL,
                           write_out = FALSE,
                           filedir) {

  component <- match.arg(component,
                          c('ALL', 'VAL', 'CIS', 'CLO', 'CHI'))

  if(!(depth %in% seq.int(6))) {
    stop('Please choose a value between 1 and 6 for depth.')
  }

  if(all(write_out == TRUE, missing(filedir))) {
    stop('Please supply a destination directory.')
  }

  switch(component, 'ALL' = {
    rs <- lapply(c('VAL', 'CLO', 'CHI'), function(l) {
      suppressMessages(
        get_soils_raster(product = product, attribute = attribute,
                         component = l, depth = depth, aoi = aoi)
      )
    })
    s <- raster::stack(rs)
    s_names <- names(s)

    if(write_out == TRUE) {
      out_name <- slga_filenamer(product = product, attribute = attribute,
                                 component = 'ALL', depth = depth)
      out_dest <- file.path(filedir, paste0(out_name, '.tif'))
      raster::writeRaster(s, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      s <- raster::stack(out_dest)
      names(s) <- s_names
      s
    } else {
      s
    }
  },
  'CIS' = {
    rs <- lapply(c('CLO', 'CHI'), function(l) {
      suppressMessages(
        get_soils_raster(product = product, attribute = attribute,
                         component = l, depth = depth, aoi = aoi)
      )
    })
    s <- raster::stack(rs)
    s_names <- names(s)

    if(write_out == TRUE) {
      out_name <- slga_filenamer(product = product, attribute = attribute,
                                 component = 'CIS', depth = depth)
      out_dest <- file.path(filedir, paste0(out_name, '.tif'))
      raster::writeRaster(s, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      s <- raster::stack(out_dest)
      names(s) <- s_names
      s
    } else {
      s
    }
  },
  'VAL' = {
    val <- get_soils_raster(product = product, attribute = attribute,
                            component = 'VAL', depth = depth, aoi = aoi)
    v_name <- names(val)
    if(write_out == TRUE) {
      out_dest <- file.path(filedir, paste0(v_name, '.tif'))
      raster::writeRaster(val, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      val <- raster::raster(out_dest)
      names(val) <- v_name
      val
    } else {
      val
    }
  },
  'CLO' = {
    clo <- get_soils_raster(product = product, attribute = attribute,
                            component = 'CLO', depth = depth, aoi = aoi)
    c_nm <- names(clo)
    if(write_out == TRUE) {
      out_dest <- file.path(filedir, paste0(c_nm, '.tif'))
      raster::writeRaster(clo, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      clo <- raster::raster(out_dest)
      names(clo) <- c_nm
      clo
    } else {
      clo
    }
  },
  'CHI' = {
    chi <- get_soils_raster(product = product, attribute = attribute,
                            component = 'CHI', depth = depth, aoi = aoi)
    c_nm <- names(chi)
    if(write_out == TRUE) {
      out_dest <- file.path(filedir, paste0(c_nm, '.tif'))
      raster::writeRaster(chi, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      chi <- raster::raster(out_dest)
      names(chi) <- c_nm
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
#'   working directory as a GeoTiff. Defaults to FALSE.
#' @param filedir directory in which to write files if write_out == TRUE.
#' @return Raster dataset for a single landscape product.
#' @note \itemize{
#'   \item An aoi larger than 1x1 decimal degree is retrieveable, but be
#'   aware that download file size will be large. If you want a dataset that
#'   covers more than ~3x3', it may be faster to download the full
#'   GeoTIFF from the CSIRO Data Access Portal and crop out your AOI using GDAL.
#'   \item Output rasters are aligned to the parent dataset rather than the aoi.
#'   Further resampling may be required for some applications.
#'   }
#' @importFrom httr content GET http_error status_code user_agent write_disk
#' @importFrom raster getValues raster subs writeRaster
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @examples \donttest{
#' # get slope data for central Brisbane
#' aoi <- c(152.95, -27.55, 153.07, -27.45)
#' bne_slope <- get_lscape_data(product = 'SLPPC', aoi = aoi, write_out = FALSE)
#'
#' # get slope, aspect and relief class data for central Brisbane
#' bne_SAR <- lapply(c('SLPPC', 'ASPCT', 'RELCL'), function(t) {
#'   get_lscape_data(product = t, aoi = aoi, write_out = FALSE)
#' })
#' }
#' @export
#'
get_lscape_data <- function(product   = NULL,
                            aoi       = NULL,
                            write_out = FALSE, filedir) {

  if(all(write_out == TRUE, missing(filedir))) {
    stop('Please supply a destination directory.')
  }

  aoi <- validate_aoi(aoi, product)

  this_url <- make_lscape_url(product = product, aoi = aoi)

  # get data, send to temp file(s) - handle tiled requests
  r <- if(is.list(this_url)) {
    message("Requesting a large volume of data, please be patient...")
    pb <- utils::txtProgressBar(min = 0, max = length(this_url), style = 3)
    dat <- mapply(function(x, i) {
        out_temp <- paste0(tempfile(), '_SLGA_', product, '.tif')
        gr <- get_slga_data(url = x, out_temp)

        if(httr::http_error(gr)) {
          stop(paste0('http error ', httr::status_code(gr), '.'))
        }
        Sys.sleep(0.2)
        utils::setTxtProgressBar(pb, i)
        raster::raster(out_temp)
    }, x = this_url, i = seq_along(this_url))
    close(pb)
    dat$fun <- mean
    # CRS warning spurious and redundant with later amendment
    suppressWarnings(do.call(raster::mosaic, dat))

  } else {
    out_temp <- paste0(tempfile(), '_SLGA_', product, '.tif')
    gr <- get_slga_data(url = this_url, out_temp)

    if(httr::http_error(gr)) {
      stop(paste0('http error ', httr::status_code(gr), '.'))
    }
    # CRS warning spurious and redundant with later amendment
    suppressWarnings(raster::raster(out_temp))
  }

  tidy_lscape_data(r, product, write_out, filedir)
}
