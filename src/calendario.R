
calendario <- readr::read_csv2("data/raw/calendario.csv", locale = readr::locale(encoding = "latin1"))

calendario <- calendario[, c(1, 3)]
names(calendario) <- c("fecha", "tipo_dia")

calendario$fecha <- as.Date(calendario$fecha, format = "%d/%m/%Y")

calendario$laborable <- as.integer(calendario$tipo_dia == "laborable")

calendario$tipo_dia <- NULL

saveRDS(calendario, "data/dias_laborables.RDS")

#' 
#' Preparar ejercicio:
#' Importar .csv
#' Convertir del día en formato fecha.
#' Quedarse con aquellos días cuya variable Festividad no empiecen
#' por "Traslado".

calendario$Dia <- as.Date(calendario$Dia, format = "%d/%m/%Y")
festivos <- calendario %>% 
  filter(`laborable / festivo / domingo festivo` == "festivo",
         !str_detect(tolower(Festividad), "traslado")) %>% 
  mutate(dia = lubridate::day(Dia), mes = lubridate::month(Dia)) %>% 
  group_by(Festividad, dia, mes) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  filter(n >= 6)


