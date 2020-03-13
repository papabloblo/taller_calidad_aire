
library(tidyverse)


test <- readRDS("data/test.RDS")
test$pred_knn <- readRDS("data/pred_knn.RDS")
test$pred_arbol <- readRDS("data/pred_arbol.RDS")

ggplot(
  data = test,
  aes(
    x = fecha
  )
) + 
  geom_line(
    aes(y = pred_arbol),
    color = "steelblue"
  ) +
  geom_line(
    aes(y = pred_knn),
    color = "firebrick"
  ) +
  geom_line(
    aes(y = pm25)
  )



ggplot(
  data = test,
  aes(
    x = pm25,
    y = pm25-pred_arbol
  )
) + 
  geom_point()

ggplot(
  data = test,
  aes(
    x = pm25,
    y = pm25-pred_knn
  )
  ) + 
  geom_point()
