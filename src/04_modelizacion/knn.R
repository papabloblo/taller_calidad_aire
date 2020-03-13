library(FNN)
library(tidyverse)
library(rpart)

train <- readRDS("data/train.RDS")
test <- readRDS("data/test.RDS")

train <- train %>% 
  select(
    pm25_lag, 
    pm10_lag, 
    finde, 
    pm25_inc1_lag,
    pm25
    ) %>% 
  mutate_at(
    c("pm25_lag", 
      "pm10_lag", 
      "finde",
      "pm25_inc1_lag"),
    function(x)(x - mean(x, na.rm = TRUE))/sd(x, na.rm = TRUE))

test <- test %>% 
  select(
    pm25_lag, 
    pm10_lag, 
    finde, 
    pm25_inc1_lag,
    pm25
  ) %>% 
  mutate_at(
    c("pm25_lag", 
      "pm10_lag", 
      "finde",
      "pm25_inc1_lag"),
    function(x)(x - mean(x, na.rm = TRUE))/sd(x, na.rm = TRUE))



mod_knn <- knn.reg(
  k = 3,
  train = train %>% select(-pm25),
  y = train$pm25,
  test = test %>% select(-pm25),
  )


train <- train[2:nrow(train),]

train[is.na(train)] <- 0



mod_knn <- knn.reg(
  k = 3,
  train = train %>% select(-pm25),
  y = train$pm25,
  test = test %>% select(-pm25)
)

pred_knn <- mod_knn$pred
rmse(pred_knn, test$pm25)


K <- seq(1, 250, by = 10)
mods_knn <- c()
for (k in K){
  mod_knn <- knn.reg(
    k = k,
    train = train %>% select(-pm25),
    y = train$pm25,
    test = test %>% select(-pm25)
  )
  
  pred_knn <- mod_knn$pred
  mods_knn <- c(mods_knn, rmse(pred_knn, test$pm25))
}


mod_knn <- knn.reg(
  k = K[which.min(mods_knn)],
  train = train %>% select(-pm25),
  y = train$pm25,
  test = test %>% select(-pm25)
)

pred_knn <- mod_knn$pred

saveRDS(pred_knn, "data/pred_knn.RDS")


