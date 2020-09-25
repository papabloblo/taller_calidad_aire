
# DEPENDENCIAS -------------------------------------------------------------

library(tidyverse)
source("src/utils.R")


# CARGA DE DATOS ----------------------------------------------------------

calidad_aire <- readRDS("data/raw/calidad_aire.RDS")

names(calidad_aire) <- tolower(names(calidad_aire))
names(calidad_aire)[names(calidad_aire) == "ano"] <- "anyo"


# ELIMINACIÓN DE VARIABLES ------------------------------------------------

length(unique(calidad_aire$provincia)) == 1
calidad_aire$provincia <- NULL

var_unarias <- map_lgl(calidad_aire, 
                       function(x) length(unique(x)) == 1
                       )

calidad_aire <- calidad_aire[, !var_unarias]

calidad_aire$punto_muestreo <- NULL

glimpse(calidad_aire)


# TIPO ADECUADO DE VARIABLES ----------------------------------------------

# calidad_aire$mes <- as.integer(calidad_aire$mes)
# 
# calidad_aire <- calidad_aire %>% 
#   mutate(
#     mes = as.integer(mes),
#     anyo = as.integer(anyo)
#   )
# 

calidad_aire <- calidad_aire %>% 
  mutate_at(
    c("estacion", "magnitud", "anyo", "mes"),
    as.integer
  )
glimpse(calidad_aire)


calidad_aire <- calidad_aire %>% 
  mutate_at(
    vars(starts_with("d")),
    as.numeric
  )

calidad_aire <- calidad_aire %>% 
  mutate_at(
    c("d01", "d02", "d03", "d31"),
    as.numeric
  )

glimpse(calidad_aire)


# DÍAS DE COLUMNAS A FILAS ------------------------------------------------

calidad_aire_medicion <- calidad_aire %>% 
  select(-starts_with("v"))

calidad_aire_medicion <- calidad_aire_medicion %>% 
  pivot_longer(
    cols = d01:d31,
    names_to =  "dia",
    values_to = "medicion"
  )


calidad_aire_medicion$dia <- substr(calidad_aire_medicion$dia,
                                    start = 2,
                                    stop = 3
                                    )

calidad_aire_medicion$dia <- as.integer(calidad_aire_medicion$dia)



calidad_aire_validado <- calidad_aire %>% 
  select(-starts_with("d")) %>% 
  pivot_longer(
    cols = v01:v31,
    names_to =  "dia",
    values_to = "validado"
  ) %>% 
  mutate(
    dia = as.integer(substr(dia, start = 2, stop = 3))
  )


calidad_aire <- calidad_aire_medicion %>%
  left_join(calidad_aire_validado)


# ELIMINACIÓN DE DÍAS ERRÓNEOS --------------------------------------------

meses_30 <- c(4, 6, 9, 11)

calidad_aire <- calidad_aire %>% 
  filter(!(dia == 31 & mes %in% meses_30))

# Ejercio: eliminar los días no válidos de febrero
# (Cuidado con los años bisiestos)


calidad_aire <- calidad_aire %>% 
  filter(!(mes == 2 & dia >= 30))

calidad_aire <- calidad_aire %>% 
  filter(!(!is.bisiesto(anyo) & mes == 2 & dia == 29))

# VALORES NO VALIDADOS ----------------------------------------------------

calidad_aire$medicion[calidad_aire$validado == "N"] <- NA

calidad_aire %>% 
  filter(validado == "N")

calidad_aire$validado <- NULL


# VARIABLE FECHA ----------------------------------------------------------
calidad_aire

calidad_aire$fecha <- lubridate::make_date(
  year = calidad_aire$anyo,
  month = calidad_aire$mes,
  day = calidad_aire$dia
)

calidad_aire

# magnitud_diccionario <- data.frame(
#   magnitud = c(1, 6, 7, 8),
#   magnitud2 = c("so2", "co")
# )


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



#'
#'
#'  f(x1, x2, x3,...) = y


# VARIABLE POR MAGNITUD ---------------------------------------------------

calidad_aire <- calidad_aire %>% 
  pivot_wider(
    names_from = magnitud,
    values_from = medicion
  )


# ORDENACIÓN LÓGICA DE VARIABLES ------------------------------------------

calidad_aire <- calidad_aire %>% 
  select(
    fecha, 
    anyo:dia,
    estacion,
    so2:nmhc
  )

# GUARDADO DE DATOS -------------------------------------------------------

saveRDS(calidad_aire, "data/02_estructura.RDS")










