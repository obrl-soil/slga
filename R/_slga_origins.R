# calc raster::origin for SLGA products
options(digits = 22)
# formula adapted from https://github.com/rspatial/raster/blob/master/R/origin.R
org <- function(product = NULL) {
  e <- c(
    'xmin' = slga_product_info$xmin[which(slga_product_info$Code == product)],
    'ymin' = slga_product_info$ymin[which(slga_product_info$Code == product)],
    'xmax' = slga_product_info$xmax[which(slga_product_info$Code == product)],
    'ymax' = slga_product_info$ymax[which(slga_product_info$Code == product)]
  )
  r <- abs(
    c(slga_product_info$offset_x[which(slga_product_info$Code == product)],
      slga_product_info$offset_y[which(slga_product_info$Code == product)]))

  x <- e['xmin'] - r[1]*(round(e['xmin'] / r[1]))
  y <- e['ymax'] - r[2]*(round(e['ymax'] / r[2]))

  if (isTRUE(all.equal((r[1] + x), abs(x)))) {
    x <- abs(x)
  }
  if (isTRUE(all.equal((r[2] + y), abs(y)))) {
    y <- abs(y)
  }
  return(c(x, y))
}

org('ACLEP_AU_TRN_N')
org('ACLEP_AU_NAT_C')
org('ACLEP_AU_SAT_D')
org('ACLEP_AU_TAS_N')
org('ACLEP_AU_WAT_D')

# and terrain
orgt <- function(product = NULL) {
  e <- c(
    'xmin' = slga_terrain_info$xmin[which(slga_terrain_info$Code == product)],
    'ymin' = slga_terrain_info$ymin[which(slga_terrain_info$Code == product)],
    'xmax' = slga_terrain_info$xmax[which(slga_terrain_info$Code == product)],
    'ymax' = slga_terrain_info$ymax[which(slga_terrain_info$Code == product)]
  )
  r <- abs(
    c(slga_terrain_info$offset_x[which(slga_terrain_info$Code == product)],
      slga_terrain_info$offset_y[which(slga_terrain_info$Code == product)]))

  x <- e['xmin'] - r[1]*(round(e['xmin'] / r[1]))
  y <- e['ymax'] - r[2]*(round(e['ymax'] / r[2]))

  if (isTRUE(all.equal((r[1] + x), abs(x)))) {
    x <- abs(x)
  }
  if (isTRUE(all.equal((r[2] + y), abs(y)))) {
    y <- abs(y)
  }
  return(c(x, y))
}

sapply(slga_terrain_info$Code, orgt)

