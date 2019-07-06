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
#' \item{NAT}{Whether the attribute is available as part of this product.}
#' \item{NAT_3D}{Whether the attribute is available as part of this product.}
#' \item{SA}{Whether the attribute is available as part of this product.}
#' \item{TAS}{Whether the attribute is available as part of this product.}
#' \item{WA}{Whether the attribute is available as part of this product.}
#' }
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
#' @format A data frame with 23 observations and 14 variables \describe{
#' \item{Type}{Product Type - Soil or Landscape}
#' \item{Product}{Product Name}
#' \item{Short_Name}{Product short name}
#' \item{Code}{Product code}
#' \item{xmin}{left bounding longitude in decimal degrees}
#' \item{xmax}{right bounding longitude in decimal degrees}
#' \item{ymin}{bottom latitude in decimal degrees}
#' \item{ymax}{top bounding latitude in decimal degrees}
#' \item{offset_x}{Cell resolution in x dimension}
#' \item{offset_y}{Cell resolution in y dimension}
#' \item{origin_x}{x coordinate result of
#'   \code{\link[raster:origin]{raster::origin()}} for this dataset.}
#' \item{origin_y}{y coordinate result of
#'   \code{\link[raster:origin]{raster::origin()}} for this dataset.}
#' \item{ncol}{number of raster cells in x dimension}
#' \item{nrow}{number of raster cells in y dimension}
#' }
#' @source See also
#' \url{http://www.clw.csiro.au/aclep/soilandlandscapegrid/ProductDetails-SoilAttributes.html}
#'
'slga_product_info'

#' Central Brisbane surface clay content
#'
#' A rasterStack containing modelled estimated percent clay content for central
#' Brisbane, in South East Queensland.
#'
#' The dataset was retrieved from the National Soil Attributes Clay WCS on
#' 2019/07/07 using the demonstration code in
#' \code{\link[slga:get_soils_data]{get_soils_data}}.
#'
#' The dataset has three named layers. The first is the estimated value, the
#' second is the 5\% confidence limit, and the third is the 95\% confidence
#' limit.
#'
#' The dataset is in WGS84 (EPSG:4326) and has a resolution of 3 arc seconds,
#' which is approximately 80x90m when projected into EPSG:28355 or EPSG:3577.
#'
#' Note that some off-shore areas have a value of 0 rather than NA. A coastline
#' masking layer will be required to safely remove these values.
#'
"bne_surface_clay"

## Generated with
#slga_attribute_info <-
#  data.frame(
#    "Name" =
#       c('Available Water Capacity', 'Bulk Density (Fine Earth)',
#         'Bulk Density (Whole Earth)', 'Cation Exchange Capacity',
#         'Cation Exchange Capacity (Effective)', 'Clay',  'Coarse Fragments',
#         'Depth of Regolith', 'Depth of Soil', 'Electrical Conductivity',
#         'Organic Carbon', 'pH CaCl2',  'pH Water', 'Sand', 'Silt',
#         'Total Nitrogen', 'Total Phosphorus'),
#    "Code" =
#      c('AWC', 'BDF', 'BDW', 'CEC', 'ECE', 'CLY', 'CFG', 'DER', 'DES', 'ECD',
#        'SOC', 'PHC', 'PHW', 'SND', 'SLT', 'NTO', 'PTO'),
#    "Units" =
#      c('%', 'g/cm', 'g/cm', 'meq/100g', 'meq/100g', '%', '%', 'Meters',
#        'Meters',  'dS/m', '%', 'pH Units', 'pH Units', '%', '%', '%', '%'),
#    "Transformation" =
#      c('None', 'None', 'None', 'Log', 'Log', 'None', 'None', 'None', 'None',
#        'Log', 'Log', 'None', 'None', 'None', 'None', 'Log', 'Log'),
#    'NAT' =
#      c(TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE,
#        TRUE, FALSE, TRUE, TRUE, TRUE, TRUE),
#    'NAT_3D' =
#      c(TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE,
#        TRUE, FALSE, TRUE, TRUE, TRUE, TRUE),
#    'SA' =
#      c(TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE,
#        TRUE, FALSE, TRUE, TRUE, FALSE, FALSE),
#    'TAS' =
#      c(FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE,
#        FALSE, TRUE, TRUE, TRUE, FALSE, FALSE),
#    'WA' =
#      c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, FALSE,
#        FALSE, TRUE, TRUE, TRUE, FALSE, FALSE),
#    stringsAsFactors = FALSE)
#
#slga_product_info <- data.frame(
#  'Type' = 'Soil',
#  'Product'    = c("National_3D", "National", "South_Australia", "Tasmania",
#                   "Western_Australia"),
#  'Short_Name' = c('NAT_3D', 'NAT', 'SA', 'TAS', 'WA'),
#  'Code'       = c("ACLEP_AU_TRN_N", "ACLEP_AU_NAT_C", "ACLEP_AU_SAT_D",
#                   "ACLEP_AU_TAS_N", "ACLEP_AU_WAT_D"),
#  'xmin'       = c(112.9995833334, 112.9995833334, 131.58708333370001,
#                   143.73458333389601, 112.99958333299942),
#  'ymin'       = c(-44.000416667014399, -44.0004166670142, -38.129583333586297,
#                   -43.706250000342799, -35.134583335670328),
#  'xmax'       = c(153.99958333406099, 153.99958333406099, 141.01791666718501,
#                   148.65041666730801, 129.09541666600785),
#  'ymax'       = c(-10.0004166664663, -10.0004166664663, -31.521250000146399,
#                   -39.377916666939697, -13.742916669435452),
#  'offset_x'   = c(0.00083333333334676806, 0.00083333333334676806,
#                   0.00083333333334673478, 0.00083333333334666821,
#                   0.00083333333331651199),
#  'offset_y'   = c(-0.00083333333334676709, -0.00083333333334676221,
#                   -0.00083333333334677153, -0.00083333333334676578,
#                   -0.00083333333331651253),
#  'origin_x'   = c(0.00041666491159730867, 0.00041666491159730867,
#                   0.00041666491719638543, 0.00041666492933245536, #
#                   -0.00041666471960866147),
#  'origin_y'   = c(-0.00041666630509595848, -0.00041666630515457825,
#                   -0.00041666630476555611, -0.00041666630497161350,
#                   0.00041666362047187988),
#  'ncol'       = c(40800, 40800, 7930, 5194, 25670),
#  'nrow'       = c(49200, 49200, 11317, 5899, 19315),
#  stringsAsFactors = FALSE
#)
#
#slga_terrain_info <-
# data.frame(
#   "Type"        = 'Landscape',
#   "Product"     = c('Prescott Index', 'Net Radiation [January]', 'Net Radiation [July]',
#                  'Total Shortwave Sloping Surf [January]', 'Total Shortwave Sloping Surf [July]',
#                  'Slope [percent]', 'Slope [percent] Median 300m Radius', 'Slope Relief Class',
#                  'Aspect', 'Relief [1000m radius]', 'Relief [300m radius]', 'Topographic Wetness Index',
#                  'TPI Mask', 'SRTM_TopographicPositionIndex', 'Contributing Area [partial]',
#                  'MrVBF', 'Plan Curvature', 'Profile Curvature'),
#   "Short_Name"  =  c('PSIND', 'NRJAN', 'NRJUL', 'TSJAN', 'TSJUL', 'SLPPC', 'SLMPC',
#                     'RELCL', 'ASPCT', 'REL1K', 'REL3C', 'TWIND', 'TPMSK', 'TPIND',
#                     'CAPRT', 'MRVBF', 'PLNCV', 'PRFCV'),
#   "Code"       = 'SRTM_attributes_3s_ACLEP_AU',
#   'xmin'     = c(rep(112.99958333333333, 5), 112.99958333340001, 112.99958333339997,
#                  112.9995833334, 112.99958333340001, 112.99958333340001, 112.99958333340001,
#                  112.99958333339997, 112.99958333340001, 112.99958333340001,
#                  112.99958333339997, 112.9995833309998, 112.99958333340001, 112.99958333340001),
#   'ymin'     = c(rep(-44.000416666666666,5), -44.000416667015159, -44.000416667014996,
#                  -44.000416665779959, -44.000416667015159, -44.000416667015159, -44.000416667015159,
#                  -44.000416667014996, -44.000416667015159, -44.000416667015159,
#                  -44.000416667014996, -44.000416667380001, -44.000416667015159, -44.000416667015159),
#   'xmax'     = c(rep(154.00041666666667, 5), 153.99958333406073, 153.99958333406303,
#                  153.99958333175948, 153.99958333406073, 153.99958333406073, 153.99958333406073,
#                  153.99958333406303, 153.99958333406073, 153.99958333406073,
#                  153.99958333406303, 153.99958333428009, 153.99958333406073, 153.99958333406073),
#   'ymax'     = c(rep(-9.9995833333333337, 5), -10.001249999799626, -10.001249999799711,
#                  -10.000416667140001, -10.000416666466279, -10.001249999799626, -10.001249999799626,
#                  -10.001249999799711, -10.001249999799626, -10.001249999799626,
#                  -10.001249999799711, -10.000416664660001, -10.001249999799626, -10.001249999799626),
#   'offset_x' = c(rep(0.00083333333333333328, 5), 0.00083333333334676264,
#                  0.00083333333334681024, 0.00083333333329998951, 0.00083333333334676264,
#                  0.00083333333334676264, 0.00083333333334676264, 0.00083333333334681024,
#                  0.00083333333334676264, 0.00083333333334676264, 0.00083333333334681024,
#                  0.00083333333340000597, 0.00083333333334676264, 0.00083333333334676264),
#   'offset_y' = c(rep(-0.00083333333333333328, 5), -0.00083333333334678628,
#                  -0.0008333333333467802,  -0.00083333333329999894, -0.00083333333334678628,
#                  -0.00083333333334678628, -0.00083333333334678628, -0.0008333333333467802,
#                  -0.00083333333334678628, -0.00083333333334678628, -0.0008333333333467802,
#                  -0.0008333333334, -0.00083333333334678628, -0.00083333333334678628),
#   'origin_x' = c(0.00041666666665207686, 0.00041666666665207686, 0.00041666666665207686,
#                  0.00041666666665207686, 0.00041666666665207686, 0.00041666491235048397,
#                  0.00041666490584191251, -0.00041666207857815607, 0.00041666491235048397,
#                  0.00041666491235048397, 0.00041666491235048397, 0.00041666490584191251,
#                  0.00041666491235048397, 0.00041666491235048397, 0.00041666490584191251,
#                  0.00041665529238343879, 0.00041666491235048397, 0.00041666491235048397),
#   'origin_y' = c(0.00041666666666628771, 0.00041666666666628771, 0.00041666666666628771,
#                  0.00041666666666628771, 0.00041666666666628771, -0.00041666630484371581,
#                  -0.00041666630500181157, 0.00041666579328669684, -0.00041666630484371581,
#                  -0.00041666630484371581, -0.00041666630484371581, -0.00041666630500181157,
#                  -0.00041666630484371581, -0.00041666630484371581, -0.00041666630500181157,
#                  -0.00041666386000116518,-0.00041666630484371581, -0.00041666630484371581),
#   'ncol'     = c(rep(49200, 5), rep(49199, 13)),
#   'nrow'     = c(rep(40800, 5), 40798, 40798, 40799, 40799, 40798, 40798, 40798,
#                  40798, 40798, 40799, 40798, 40798, 40798),
#   stringsAsFactors = FALSE
#   )
#
#slga_product_info <- rbind(slga_product_info, slga_terrain_info)
#
# aoi <- c(152.95, -27.55, 153.07, -27.45)
# bne_surface_clay <- get_soils_data(product = 'NAT', attribute = 'CLY',
#                                    component = 'ALL', depth = 1,
#                                    aoi = aoi, write_out = FALSE)
#usethis::use_data(slga_attribute_info, overwrite = TRUE)
#usethis::use_data(slga_product_info, overwrite = TRUE)
#x
