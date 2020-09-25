
library(e1071)

train <- readRDS("data/train.RDS")
test <- readRDS("data/test.RDS")

svm_mod <- svm( pm25 ~ pm25_lag + mes,
                     data = train,
                     kernel = "linear",
                     cost = 10,
                     scale = FALSE)


pred <- predict(svm_mod, test)
