#'
#' DESCARGA AUTOMÁTICA DE LOS DATOS DIARIOS DE LA CALIDAD DEL AIRE
#' EN LA CIUDAD DE MADRID
#' 
#' Pablo Hidalgo
#' 
#' 1. Se extrae mediante webscraping las url de los archivos .csv por años.
#' 2. Se descargan en un único data frame 
#' 3. Se crea el archivo data/raw/calidad_aire.RDS


# DEPENDENCIAS ------------------------------------------------------------

library(rvest)


# OBTENER UN ARCHIVO CSV DE LA WEB ---------------------------------------
# Ejemplo manual
# calidad_aire_2020 <- readr::read_csv2("https://datos.madrid.es/egob/catalogo/201410-10306609-calidad-aire-diario.csv")



# DESCARGA AUTOMATIZADA ---------------------------------------------------


url <- "https://datos.madrid.es/portal/site/egob/menuitem.c05c1f754a33a9fbe4b2e4b284f1a5a0/?vgnextoid=aecb88a7e2b73410VgnVCM2000000c205a0aRCRD&vgnextchannel=374512b9ace9f310VgnVCM100000171f5a0aRCRD&vgnextfmt=default"

# Extracción de url de los csv
url_csv <- read_html(url) %>% 
  html_nodes(".ico-csv") %>% 
  html_attr("href")

url_base <- "https://datos.madrid.es"

url_csv <- paste0(url_base, url_csv)

# Descarga de todos los csv
calidad_aire <- purrr::map_df(url_csv, readr::read_csv2)

# Guardado del archivo calidad del aire
saveRDS(calidad_aire, "data/raw/calidad_aire.RDS")
