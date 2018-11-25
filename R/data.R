#' SLGA Attribute Information
#'
#' A data frame containing information about the modelled soils attributes
#' available from the Soil and Landscape Grid of Australia.
#'
#' @format A data frame with 14 observations and 4 variables \describe{
#' \item{Name}{Attribute name}
#' \item{Code}{Short code for attribute}
#' \item{Units}{Attribute measurement units}
#' \item{Transformation}{Attribute measurement scaling}
#' @source See also
#' \url{http://www.clw.csiro.au/aclep/soilandlandscapegrid/ProductDetails-SoilAttributes.html}
#'
"slga_attribute_info"

#' SLGA Product Information
#'
#' A data frame containing information about the products available from the
#' Soil and Landscape Grid of Australia.
#'
#' All datasets are projected in EPSG:4326 (WGS84). Grid parameters have been
#' retrieved from metadata viewable with WCS DescribeCoverage requests.
#'
#' #' @format A data frame with 5 observations and 8 variables \describe{
#' \item{Region}{Region Name}
#' \item{Code}{Short code for region}
#' \item{xmin}{left bounding longitude in decimal degrees}
#' \item{xmax}{right bounding longitude in decimal degrees}
#' \item{ymin}{bottom latitude in decimal degrees}
#' \item{ymax}{top bounding latitude in decimal degrees}
#' \item{offset_x}{Cell resolution in x dimension}
#' \item{offset_y}{Cell resolution in y dimension}
#' \item{origin_x}{x coordinate result of `raster::origin()` for this dataset.}
#' \item{origin_y}{y coordinate result of `raster::origin()` for this dataset.}
#' \item{ncols}{number of raster cells in x dimension}
#' \item{nrows}{number of raster cells in y dimension}
#' @source See also
#' \url{http://www.clw.csiro.au/aclep/soilandlandscapegrid/ProductDetails-SoilAttributes.html}
#'
'slga_product_info'

## yo what about terrain atts???

# Generated with
#slga_attribute_info <- data.frame(
#  "Name" = c('Depth_to_Rock', 'Rooting_Depth', 'Organic_Carbon',
#             'pH_Soil_Water', 'PH_Soil_CaCl2', 'Clay', 'Silt', 'Sand',
#             'ECEC', 'Bulk_Density', 'Available_Water_Capacity',
#             'Electrical_Conductivity', 'Total_Phosphorus',
#             'Total_Nitrogen'),
#  "Code" = c('DER', 'DPE', 'SOC', 'PHW', 'PHC', 'CLY', 'SLT', 'SND',
#             'ECE', 'BDW', 'AWC', 'ECD', 'PTO', 'NTO'),
#  "Units" = c('Meters', 'Meters', '%', '', '', '%', '%', '%',
#              'meq/100g', 'g/cm', 'load%', 'dS/m', '%', '%'),
#  "Transformation" = c('None', 'None', 'Log', 'None', 'None', 'None',
#                       'None', 'None', 'Log', 'None', 'None', 'Log',
#                       'Log', 'Log'),
#  stringsAsFactors = FALSE)
#
#slga_product_info <- data.frame(
#  'Region' = c("National_3D", "National", "South_Australia", "Tasmania",
#               "Western_Australia"),
#  'Code' = c("ACLEP_AU_TRN_N", "ACLEP_AU_NAT_C", "ACLEP_AU_SAT_D",
#             "ACLEP_AU_TAS_N", "ACLEP_AU_WAT_D"),
#  'xmin'     = c(112.9995833334, 112.9995833334, 131.58708333370001, 143.73458333389601, 112.99958333299942),
#  'xmax'     = c(153.99958333406099, 153.99958333406099, 141.01791666718501, 148.65041666730801, 129.09541666600785),
#  'ymin'     = c(-44.000416667014399, -44.0004166670142, -38.129583333586297, -43.706250000342799, -35.134583335670328),
#  'ymax'     = c(-10.0004166664663, -10.0004166664663, -31.521250000146399, -39.377916666939697, -13.742916669435452),
#  'offset_x' = c(0.00083333333334676806, 0.00083333333334676806, 0.00083333333334673478, 0.00083333333334666821, 0.00083333333331651199),
#  'offset_y' = c(-0.00083333333334676709, -0.00083333333334676221, -0.00083333333334677153, -0.00083333333334676578, -0.00083333333331651253),
#  'origin_x' = c(0.00041666491159730867, 0.00041666491159730867, 0.00041666491719638543, 0.00041666492933245536, -0.00041666471960866147),
#  'origin_y' = c(-0.00041666630509595848, -0.00041666630515457825, -0.00041666630476555611, -0.00041666630497161350, 0.00041666362047187988),
#  'ncol' =c(40800, 40800, 7930, 5194, 25670),
#  'nrow' = c(49200, 49200, 11317, 5899, 19315),
#  stringsAsFactors = FALSE
#)
#
#usethis::use_data(slga_attribute_info)
#usethis::use_data(slga_product_info, overwrite = TRUE)
