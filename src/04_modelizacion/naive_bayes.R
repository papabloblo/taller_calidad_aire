

train <- readRDS("data/train.RDS")
test <- readRDS("data/test.RDS")


train <- train[2:nrow(train),]

train[is.na(train)] <- 0
test[is.na(test)] <- 0

naiveBayes()

naive_mod <- naiveBayes( pm25 ~ pm25_lag + mes,
                data = train)


pred <- predict(naive_mod, test)
