#' Validate soils product/attribute combination
#'
#' Check whether the requested soils attribute is available for the requested
#' soils product.
#'
#' @param product Character, one of the options from column 'Code' in
#'   code{\link[slga:slga_product_info]{slga_product_info}} where Type = 'Soil'.
#' @param attribute Character, one of the options from column 'Code' in
#'   code{\link[slga:slga_attribute_info]{slga_attribute_info}}.
#' @return Logical; TRUE if available
#' @examples
#' check_avail('NAT', 'CFG')
#' check_avail('SA',  'CFG')
#' @importFrom utils data
#' @export
#'
check_avail <- function(product = NULL, attribute = NULL) {
  slga_attribute_info <- NULL
  utils::data('slga_attribute_info', envir = environment())
  slga_attribute_info[which(slga_attribute_info$Code == attribute), product]
}

#' GET soil or landscape data
#'
#' Quietly sends a httr GET request to SLGA web service endpoint.
#'
#' @param url valid output from \code{\link[slga:make_soils_url]{make_soils_url}}
#'  or \code{\link[slga:make_lscape_url]{make_lscape_url}}
#' @param out_temp location to write content - valid file path with .tif
#'   extension.
#' @return httr \code{\link[httr:response]{response()}} object with content
#'   stored on disk
#' @keywords internal
#' @importFrom httr GET user_agent write_disk
#'
get_slga_data <- function(url = NULL, out_temp = NULL) {
  suppressMessages(
  httr::GET(url = url, httr::write_disk(out_temp),
            httr::user_agent('https://github.com/obrl-soil/slga')))
}
