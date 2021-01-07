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
#' @importFrom sf sf_extSoftVersion st_crs
#' @importFrom methods as
#'
tidy_soils_data <- function(r = NULL, out_name = NULL) {

  # fix CRS to have correct WKB in comments
  # rgdal's warning messages are spurious in this case and should disappear as
  # r-spatial PROJ handling continues to evolve
  suppressWarnings({
  prj <- sf::st_crs(4283)
  prj <- as(prj, 'CRS')
  raster::crs(r) <- prj
  })

  names(r) <- out_name
  # NB on the coast there are sometimes patches of offshore '0' values
  # they should be NA, but there's a risk of ditching onshore 0's
  # so can't safely remove, particularly with ci_low datasets
  r[which(raster::getValues(r) == -9999)] <- NA_real_
  r
}

#' tidy landscape parameter rasters
#'
#' Does some post-processing on landscape datasets downloaded from SLGA - mostly
#' about setting NA correctly
#'
#' @param r raster object downloaded over WCS
#' @param product character; the SLGA terrain product in question
#' @param write_out Boolean, whether to write the retrieved dataset to disk.
#'   Defaults to FALSE.
#' @param filedir directory in which to write files if write_out == TRUE.
#' @return a raster, but a better one
#' @keywords internal
#' @importFrom raster crs getValues raster subs writeRaster
#' @importFrom sf sf_extSoftVersion st_crs
#' @importFrom methods as
#'
tidy_lscape_data <- function(r = NULL, product = NULL, write_out = FALSE, filedir) {
  names(r) <- paste0('SLGA_', product)

  # fix CRS to have correct WKB in comments
  # rgdal's warning messages are spurious in this case and should disappear as
  # r-spatial PROJ handling continues to evolve
  suppressWarnings({
    prj <- sf::st_crs(4283)
    prj <- as(prj, 'CRS')
    raster::crs(r) <- prj
  })

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
    out_dest <- file.path(filedir, paste0('SLGA_', product, '.tif'))
    if(product %in% c('RELCL', 'MRVBF', 'TPIND', 'TPMSK')) {
      raster::writeRaster(r, out_dest, datatype = 'INT2S',  NAflag = -9999,
                          overwrite = TRUE)
    } else {
      raster::writeRaster(r, out_dest, datatype = 'FLT4S', NAflag = -9999,
                          overwrite = TRUE)
    }
    raster::raster(out_dest)
  }
  r
}
