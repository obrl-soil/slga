#' download SLGA soils metadata
#'
#' Retrieves metadata from Soil and Landscape Grid of Australia soils WCS
#' endpoints in XML or list format.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}.
#' @param attribute Character, one of the options from column 'Code' in
#'   \code{\link[slga:slga_attribute_info]{slga_attribute_info}}, where 'Type' =
#'   'Soil'.
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
#' @param req_type Character; one of 'cap' or 'desc'. Defaults to 'desc'.
#' @param format Character; one of 'xml' or 'native'. Defaults to 'native'.
#' @return A list or xml document object, depending on the value of 'format'.
#' @note WCS services < v 2.0 can only return XML formatted data; JSON is not an
#'   option.
#' @importFrom httr GET content
#' @importFrom xml2 as_list
#' @export
#'
metadata_soils <- function(product = NULL, attribute = NULL,
                           component = NULL, depth = NULL,
                           req_type = 'desc', format = 'native') {

  req_type <- match.arg(req_type, c('cap' , 'desc'))
  format <- match.arg(format, c('native', 'xml'))
  this_url <-
    switch(req_type,
             'cap'  = make_soils_url(product = product, attribute = attribute,
                                     req_type = 'cap'),
             'desc' = make_soils_url(product = product, attribute = attribute,
                                     component = component, depth = depth,
                                     req_type = 'desc'))

  this_metadata <- httr::GET(url = this_url) # WCS < 2.0 won't return JSON ;_;

  if(format == 'native') {
    xml2::as_list(content(this_metadata, encoding = 'UTF-8'))
  } else {
    content(this_metadata, encoding = 'UTF-8')
  }
}

#' download SLGA landscape metadata
#'
#' Retrieves metadata from Soil and Landscape Grid of Australia landscape WCS
#' endpoints in XML or list format.
#'
#' @param product Character, one of the options from column 'Short_Name' in
#'   \code{\link[slga:slga_product_info]{slga_product_info}}, where 'Type' =
#'   'Landscape'.
#' @param req_type Character; one of 'cap' or 'desc'. Defaults to 'desc'.
#' @param format Character; one of 'xml' or 'native'. Defaults to 'native'.
#' @return A list or xml document object, depending on the value of 'format'.
#' @note \itemize{
#'   \item{WCS services < v 2.0 can only return XML formatted data; JSON is not an
#'   option.}
#'   \item{Parameter `product` is optional for `req_type = 'desc'`, leave out to
#'   get metadata for all available landscape products.}
#'   }
#' @importFrom httr GET content
#' @importFrom xml2 as_list
#' @export
#'
metadata_lscape <- function(product  = NULL,
                            req_type = 'desc',
                            format   = 'native') {

  req_type <- match.arg(req_type, c('cap' , 'desc'))
  format <- match.arg(format, c('native', 'xml'))
  this_url <-
    switch(req_type,
           'cap'  = make_lscape_url(product = product, req_type = 'cap'),
           'desc' = make_lscape_url(product = product, req_type = 'desc'))

  this_metadata <- httr::GET(url = this_url) # WCS < 2.0 won't return JSON ;_;

  if(format == 'native') {
    xml2::as_list(content(this_metadata, encoding = 'UTF-8'))
  } else {
    content(this_metadata, encoding = 'UTF-8')
  }
}
