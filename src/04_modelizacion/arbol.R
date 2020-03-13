library(tidyverse)
library(rpart)

train <- readRDS("data/train.RDS")
test <- readRDS("data/test.RDS")

arbol <- rpart(pm25 ~ pm25_lag + mes,
               data = train)

summary(arbol)
plot(arbol)
text(arbol)

rpart.plot::rpart.plot(arbol)

pred <- predict(arbol, newdata = test)


rmse <- function(pred, real){
  sqrt(mean((real - pred)**2))
}

rmse(pred, test$pm25)

arbol2 <- rpart(pm25 ~ .-fecha-anyo,
               data = train,
               control = rpart.control(minbucket = 25, 
                                       cp = 0.005,
                                       maxdepth = 10)
               )


rpart.plot::rpart.plot(arbol2)

pred2 <- predict(arbol2, newdata = test)

rmse(pred2, test$pm25)

saveRDS(pred2, "data/pred_arbol.RDS")
