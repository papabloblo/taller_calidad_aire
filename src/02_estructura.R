#'
#' CAMBIO EN LA ESTRUCTURA DE LOS DATOS
#' 
#' 1. Nombres de las variables en minúscula
#' 2. El año se denomina anyo
#' 3. Se eliminan variables unarias (con un único valor)
#' 4. Se elimina punto_muestreo
#' 5. Se eleige el tipo de variable adecuada para cada dato
#' 6. Se genera una observación para cada estación, magnitud, anyo, mes y día.
#' 7. Se elimina días erróneos (día 31 de meses con 30 días y días de febrero)



# DEPENDENCIAS -----------------------------------------------------------

library(tidyverse)


# CARGA DE DATOS ----------------------------------------------------------

calidad_aire <- readRDS("data/raw/calidad_aire.RDS")


# NOMBRE DE VARIABLES A MINÚSCULA -----------------------------------------

names(calidad_aire) <- tolower(names(calidad_aire))
names(calidad_aire)[names(calidad_aire) == "ano"] <- "anyo"


# ELIMINACIÓN DE VARIABLES ------------------------------------------------

# Variables unarias
var_unarias <- sapply(calidad_aire, function(x) length(unique(x)) == 1)

# names(calidad_aire)[var_unarias]

calidad_aire <- calidad_aire[, !var_unarias]

calidad_aire$punto_muestreo <- NULL


# TIPO ADECUADO DE VARIABLES ----------------------------------------------

# calidad_aire$estacion <- as.integer(calidad_aire$estacion)
# calidad_aire$magnitud <- as.integer(calidad_aire$magnitud)
# calidad_aire$anyo <- as.integer(calidad_aire$anyo)
# calidad_aire$mes <- as.integer(calidad_aire$mes)

# De forma resumida
calidad_aire <- calidad_aire %>% 
  mutate_at(
    c("estacion", "magnitud", "anyo", "mes"),
    as.integer
    )

# Variables d01, d02, ..., d31 deben ser numéricas
calidad_aire <- calidad_aire %>% 
  mutate_at(vars(matches("d\\d\\d")), as.numeric)


# DÍAS DE COLUMNAS A FILAS ------------------------------------------------

calidad_aire_medicion <- calidad_aire %>% 
  select(-matches("v\\d\\d")) %>% 
  pivot_longer(
    cols = d01:d31,
    names_to = "dia",
    values_to = "medicion"
  ) %>% 
  mutate(
    dia = as.integer(str_remove(dia, "d"))
    )


calidad_aire_validado <- calidad_aire %>% 
  select(-matches("d\\d\\d")) %>% 
  pivot_longer(
    cols = v01:v31,
    names_to = "dia",
    values_to = "validado"
  ) %>% 
  mutate(
    dia = as.integer(str_remove(dia, "v"))
  )


calidad_aire <- calidad_aire_medicion %>% 
  left_join(calidad_aire_validado)


# ELIMINACIÓN DE DÍAS ERRÓNEOS --------------------------------------------

# Días 31 de meses con 30 días

calidad_aire <- calidad_aire %>% 
  filter(!(dia == 31 & mes %in% c(4, 6, 9, 11)))

# Días de febrero

calidad_aire <- calidad_aire %>% 
  filter(!(dia > 29 & mes == 2))

calidad_aire <- calidad_aire %>% 
  filter(!(!is.bisiesto(anyo) & dia == 29))



# VARIABLE FECHA ----------------------------------------------------------

calidad_aire$fecha <- lubridate::make_date(
  year = calidad_aire$anyo, 
  month = calidad_aire$mes, 
  day = calidad_aire$dia
  )


# NOMBRE DE LA MAGNITUD  --------------------------------------------------

magnitud_diccionario <- tribble(
  ~magnitud, ~magnitud2,
  1,  "so2",
  6,   "co",
  7,   "no",
  8,  "no2",
  9, "pm25",
  10, "pm10",
  12,  "nox",
  14,   "o3",
  20,  "tol",
  30,  "ben",
  35,  "ebe",
  42,  "tch",
  43,  "ch4",
  44,  "nmhc"
)

calidad_aire <- calidad_aire %>% 
  left_join(magnitud_diccionario)

calidad_aire$magnitud <- calidad_aire$magnitud2
calidad_aire$magnitud2 <- NULL

# VARIABLE POR MAGNITUD ---------------------------------------------------

calidad_aire <- calidad_aire %>% 
  pivot_wider(names_from = magnitud, 
              values_from = medicion
  )

