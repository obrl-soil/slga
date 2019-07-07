#' Tidy soils rasters
#'
#' Does some post-processing on soils datasets downloaded from SLGA - mostly
#' about setting NA correctly
#'
#' @param r raster object downloaded over WCS
#' @param product character; the SLGA soils product in question
#' @return a raster, but a better one
#' @keywords internal
#' @importFrom raster crs getValues raster subs writeRaster
#' @importFrom sf sf_extSoftVersion
#'
tidy_soils_data <- function(r = NULL, out_name = NULL) {

  names(r) <- out_name
  # NB on the coast there are sometimes patches of offshore '0' values
  # they should be NA, but there's a risk of ditching onshore 0's
  # so can't safely remove, particularly with ci_low datasets
  r[which(raster::getValues(r) == -9999)] <- NA_real_

  # fix proj string to 4283 properly (4151 is otherwise identical :/)
  fx <- '+init=epsg:4283 '
  # cross-platform PROJ versioning shenanigans resolved by
  #if(grepl('^5|^6', sf::sf_extSoftVersion()[[3]])) { fx <- tolower(fx) }
  # revisit the above if the rwinlib/gdal2 stack changes
  r@crs@projargs <- paste0(fx, r@crs@projargs)
  r
}

#' tidy landscape parameter rasters
#'
#' Does some post-processing on landscape datasets downloaded from SLGA - mostly
#' about setting NA correctly
#'
#' @param r raster object downloaded over WCS
#' @param product character; the SLGA terrain product in question
#' @param write_out Boolean, whether to write the processed dataset to the
#'   working directory as a GeoTiff.
#' @return a raster, but a better one
#' @keywords internal
#' @importFrom raster crs getValues raster subs writeRaster
#' @importFrom sf sf_extSoftVersion
#'
tidy_lscape_data <- function(r = NULL, product = NULL, write_out = NULL) {
  names(r) <- paste0('SLGA_', product)

  # TPMSK needs reclassifying so you can mask with tpi + tpm
  if(product == 'TPMSK') {
    df <- data.frame(c(0,1,255), c(NA_integer_, 0L, NA_integer_))
    r <- raster::subs(r, df, by = 1, which = 2)
  }

  # NA values otherwise vary by landscape product
  if(product %in% c('RELCL', 'TPIND')) {
    r[which(raster::getValues(r) == 0)] <- NA_integer_
  }

  if(product %in% c('MRVBF')) {
    r[which(raster::getValues(r) == 255)] <- NA_integer_
  }

  if(product %in% c('SLPPC', 'SLMPC', 'ASPCT', 'REL1K', 'REL3C', 'TWIND',
                    'CAPRT', 'PLNCV', 'PRFCV')) {
    r[which(raster::getValues(r) < -3.4e+38)] <- NA_real_
  }

  if(product %in% c('PSIND', 'NRJAN', 'NRJUL', 'TSJAN', 'TSJUL')) {
    r[which(raster::getValues(r) == -9999)] <- NA_real_
  }

  if(write_out == TRUE) {
    out_dest <- file.path(getwd(), paste0('SLGA_', product, '.tif'))
    if(product %in% c('RELCL', 'MRVBF', 'TPIND', 'TPMSK')) {
      raster::writeRaster(r, out_dest, datatype = 'INT2S',
                          NAflag = -9999, overwrite = TRUE)
    } else {
      raster::writeRaster(r, out_dest, datatype = 'FLT4S',
                          NAflag = -9999, overwrite = TRUE)
    }
    r <- raster::raster(out_dest)
    # argh
    fx <- '+init=epsg:4283 '
    #if(grepl('^5|^6', sf::sf_extSoftVersion()[[3]])) { fx <- tolower(fx) }
    r@crs@projargs <- paste0(fx, r@crs@projargs)
    r
  } else {
    fx <- '+init=epsg:4283 '
    #if(grepl('^5|^6', sf::sf_extSoftVersion()[[3]])) { fx <- tolower(fx) }
    r@crs@projargs <- paste0(fx, r@crs@projargs)
    r
  }
}
