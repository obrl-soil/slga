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
#' @importFrom raster getValues raster subs writeRaster
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
    r[which(raster::getValues(r) == -3.4028234663852886e+38)] <- NA_real_
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
    raster::raster(out_dest)
  } else {
    r
  }
}
