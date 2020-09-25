#'
#' DESCARGA AUTOMÁTICA DE DATOS DIARIOS DE CALIDAD DEL AIRE
#' EN LA CIUDAD DE MADRID
#' 
#' Detalle
#' 

# DEPENDENCIAS ------------------------------------------------------------

library(rvest)


# DESCARGA AUTOMATIZADA ---------------------------------------------------

url <- "https://datos.madrid.es/sites/v/index.jsp?vgnextoid=aecb88a7e2b73410VgnVCM2000000c205a0aRCRD&vgnextchannel=374512b9ace9f310VgnVCM100000171f5a0aRCRD"
url_csv <- read_html(url) %>% 
  html_nodes(".ico-csv") %>% 
  html_attr("href")
url_base <- "https://datos.madrid.es"


calidad_aire <- purrr::map_df(paste0(url_base, url_csv), 
                              readr::read_csv2
                              )


# GUARDADO DE DATOS -------------------------------------------------------

saveRDS(calidad_aire, "data/raw/calidad_aire.RDS")
