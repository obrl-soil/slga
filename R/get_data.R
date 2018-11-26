#' download single SLGA soils raster subset
#'
#' Retrieves SLGA gridded soil data in raster format from WCS service.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}.
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
#' @param write_out Boolean, whether to write the retrieved dataset to the
#'   working directory as a GeoTiff.
#' @return Raster dataset for a single combination of product, attribute,
#'   component, depth, and area of interest.
#' @note Output rasters are restricted to a maximum size of 3x3 decimal degrees.
#' @keywords internal
#' @importFrom httr content GET
#' @importFrom raster getValues raster writeRaster
#'
get_soils_raster <- function(product   = NULL,
                             attribute = NULL,
                             component = NULL,
                             depth     = NULL,
                             aoi       = NULL,
                             write_out = TRUE) {

  # check availability
  if(check_avail(product, attribute) == FALSE) {
    stop("The requested attribute is not available as part of the requested
         product. Please check data('slga_attribute_info').")
  }

  # generate URL
  this_url <- make_soils_url(product = product, attribute = attribute,
                             component = component, depth = depth,
                             aoi = aoi)
  # get data
  got <- httr::GET(url = this_url)

  # convert raw to GTiff
  # code depth for filename
  depth_pretty <- switch(depth,
                         `1` = "000_005", `2` = "005_015", `3` = "015_030",
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
  # NB on the coast there are sometimes patches of offshore '0' values
  # they should be NA, but there's a risk of ditching onshore 0's
  # so can't safely remove, particularly with ci_low datasets
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

#' Get SLGA soils data
#'
#' Downloads SLGA gridded soils data in raster format from public WCS
#' services.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}.
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
#' @note Output rasters are restricted to a maximum size of 3x3 decimal degrees.
#'   Outputs are also aligned to the parent dataset rather than the aoi. Further
#'   resampling may be required for some applications.
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
#' @export
#'
get_soils_data <- function(product   = NULL,
                           attribute = NULL,
                           component = 'all',
                           depth     = NULL,
                           aoi       = NULL,
                           write_out = TRUE) {

  if(nchar(product > 3)) {
    stop('Please use get_lscape_data() for landscape attributes.')
  }
  component <- match.arg(component,
                          c('all', 'ci', 'value', 'ci_low', 'ci_high'))
  depth_pretty <-
    switch(depth, `1` = "000_005", `2` = "005_015", `3` = "015_030",
           `4` = "030_060", `5` = "060_100", `6` = "100_200")

  switch(component, 'all' = {
    val <- get_soils_raster(product = product, attribute = attribute,
                            component = 'value', depth = depth,
                            aoi = aoi, write_out = FALSE)
    clo <- suppressMessages(
      get_soils_raster(product = product, attribute = attribute,
                       component = 'ci_low', depth = depth,
                       aoi = aoi, write_out = FALSE)
      )

    chi <-  suppressMessages(
      get_soils_raster(product = product, attribute = attribute,
                       component = 'ci_high', depth = depth,
                       aoi = aoi, write_out = FALSE)
      )

    s <- raster::stack(val, clo, chi)
    names(s) <- paste(product, attribute, c('VAL', 'CLO', 'CHI'), depth_pretty,
                      sep = '_')

    if(write_out == TRUE) {
      out_name <- paste(product, attribute, 'ALL', depth_pretty, sep = '_')
      out_dest <- file.path(getwd(), paste0(out_name, '.tif'))
      raster::writeRaster(s, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      raster::stack(out_dest)
    } else {
      s
    }
  },
  'ci' = {
    clo <- get_soils_raster(product = product, attribute = attribute,
                             component = 'ci_low', depth = depth,
                             aoi = aoi, write_out = FALSE)
    chi <-  suppressMessages(
      get_soils_raster(product = product, attribute = attribute,
                       component = 'ci_high', depth = depth,
                       aoi = aoi, write_out = FALSE)
    )

    s <- raster::stack(clo, chi)
    names(s) <- paste(product, attribute, c('CLO', 'CHI'), depth_pretty,
                      sep = '_')

    if(write_out == TRUE) {
      out_name <- paste(product, attribute, 'CIS', depth_pretty, sep = '_')
      out_dest <- file.path(getwd(), paste0(out_name, '.tif'))
      raster::writeRaster(s, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      raster::stack(out_dest)
    } else {
      s
    }
  },
  'value' = {
    val <- get_soils_raster(product = product, attribute = attribute,
                            component = 'value', depth = depth,
                            aoi = aoi, write_out = FALSE)
    names(val) <- paste(product, attribute, 'VAL', depth_pretty,
                      sep = '_')
    if(write_out == TRUE) {
      out_dest <- file.path(getwd(), paste0(names(val), '.tif'))
      raster::writeRaster(val, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      raster::raster(out_dest)
    } else {
      val
    }
  },
  'ci_low' = {
    clo <- get_soils_raster(product = product, attribute = attribute,
                            component = 'ci_low', depth = depth,
                            aoi = aoi, write_out = FALSE)
    names(clo) <- paste(product, attribute, 'CLO', depth_pretty,
                        sep = '_')
    if(write_out == TRUE) {
      out_dest <- file.path(getwd(), paste0(names(clo), '.tif'))
      raster::writeRaster(clo, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      raster::raster(out_dest)
    } else {
      clo
    }
  },
  'ci_high' = {
    chi <- get_soils_raster(product = product, attribute = attribute,
                            component = 'ci_high', depth = depth,
                            aoi = aoi, write_out = FALSE)
    names(chi) <- paste(product, attribute, 'CHI', depth_pretty,
                        sep = '_')
    if(write_out == TRUE) {
      out_dest <- file.path(getwd(), paste0(names(chi), '.tif'))
      raster::writeRaster(chi, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
      raster::raster(out_dest)
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
#'   \code{\link[slga:slga_product_info]{slga_product_info}}.
#' @param aoi Vector of WGS84 coordinates defining a rectangular area of
#'   interest. The vector may be specified directly in the order xmin, xmax,
#'   ymin, ymax, or the function can derive an aoi from the boundary of an `sf`
#'   or `raster` object.
#' @param write_out Boolean, whether to write the retrieved dataset to the
#'   working directory as a GeoTiff.
#' @return Raster dataset for a single landscape product.
#' @note Output rasters are restricted to a maximum size of 3x3 decimal degrees.
#' @importFrom httr content GET
#' @importFrom raster getValues raster writeRaster
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

  # generate URL
  this_url <- make_lscape_url(product = product, aoi = aoi)
  # get data
  got <- httr::GET(url = this_url)

  # convert raw to GTiff
  out_temp <- file.path(tempdir(), paste0('SLGA_', product, '.tif'))
  con <- file(out_temp, open = "wb")
  writeBin(httr::content(got), con)
  close(con)

  # pull back in and tidy up
  r <- raster::raster(out_temp)
  # NA values vary for landscape products
  # don't alter TPMSK/TPIND???
  if(product %in% c('RELCL')) {
    r[which(raster::getValues(r) == 0)] <- NA_integer_
  }

  if(product == 'MRVBF') {
    r[which(raster::getValues(r) == 255)] <- NA_integer_
  }

  if(product %in% c('SLPPC', 'SLMPC', 'ASPCT', 'REL1K', 'REL3C', 'TWIND',
                    'CAPRT', 'PLNCV', 'PRFCV')) {
    r[which(raster::getValues(r) == -3.402823e+38)] <- NA_real_
  }

  if(product %in% c('PSIND', 'NRJAN', 'NRJUL', 'TSJAN', 'TSJUL')) {
    r[which(raster::getValues(r) == -9999)] <- NA_real_
  }

  # write final product to working directory if directed
  if(write_out == TRUE) {
    out_dest <- file.path(getwd(), paste0('SLGA_', product, '.tif'))
    if(product %in% c('RELCL', 'MRVBF')) {
      raster::writeRaster(r, out_dest, datatype = 'INT2S',
                          NAflag = -9999, overwrite = TRUE)
    } else {
      raster::writeRaster(r, out_dest, datatype = 'FLT4S',
                          NAflag = -9999, overwrite = TRUE)
    }
    raster::raster(out_dest)
  } else {
    r
  }
}
