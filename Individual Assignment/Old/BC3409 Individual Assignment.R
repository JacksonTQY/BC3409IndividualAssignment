library(data.table)
library(corrplot)
library(ggplot2)
library(car)
library(caTools)

setwd("C:/Users/jacks/Documents/NTU/Year 3/BC3409 AI in Accounting and Finance/Individual Assignment")
dt = fread("credit card default.csv", stringsAsFactors = T)
#View(dt)
dim(dt) # 30k rows, 25 cols

########################################  
# DATA CLEANING & EXPLORATION
########################################
summary(dt)
# There are negative amounts eg in BILL_AMT
## It is apparently possible to have a negative bill amount by overpaying

sum(is.na(dt)) # No NA values
sum(duplicated(dt)) # No 2 rows are duplicates
sum(duplicated(dt$ID)) # No duplicates in ID which should be unique
str(dt) # All are int data types
# # Strictly speaking Sex, Education, Marriage, default payment next month should be categorical

names(dt)[names(dt) == "PAY_0"] <- "PAY_1"
# PAY BILL_AMT and PAY_AMT variables correspond to one another, and PAY_1 is missing,
# so PAY_0 is likely supposed to be PAY_1

####################################
# According to author of dataset:
# X6 - X11: History of past payment. 
# We tracked the past monthly payment records (from April to September, 2005) as follows: 
## X6 = the repayment status in September, 2005; 
## X7 = the repayment status in August, 2005; . . .;
## X11 = the repayment status in April, 2005. *(Reverse order)* 
#The measurement scale for the repayment status is:
## -2: No consumption; -1: Paid in full; 0: The use of revolving credit; 
## 1 = payment delay for one month; 2 = payment delay for two months; ...; 8 = payment delay for eight months; 9 = payment delay for nine months and above.
####################################

# Hence, PAY_ is a categorical variable
# This is supported by the fact that there are other columns called PAY_AMT 
# which represent the actual values

# Convert to categorical variables
dt$SEX <- as.factor(dt$SEX)
dt$EDUCATION <- as.factor(dt$EDUCATION)
dt$MARRIAGE <- as.factor(dt$MARRIAGE)
dt$PAY_1 <- as.factor(dt$PAY_1)
dt$PAY_2 <- as.factor(dt$PAY_2)
dt$PAY_3 <- as.factor(dt$PAY_3)
dt$PAY_4 <- as.factor(dt$PAY_4)
dt$PAY_5 <- as.factor(dt$PAY_5)
dt$PAY_6 <- as.factor(dt$PAY_6)
dt$`default payment next month` <- as.factor(dt$`default payment next month`)

str(dt)

########################################
# DATA MODELLING
########################################
# As there is a class imbalance noted earlier, should perform 
# *stratified* train-test split as well as consider oversampling.
# Due to the large differences in the order of magnitude 
# e.g. for PAY_AMT vs BILL_AMT, should perform scaling of X variables

### Pre-processing ###
dt[,ID:=NULL] # Drop ID as it is not a meaningful predictor

dt_cor <- dt[, lapply(dt, is.numeric) == TRUE, with = FALSE]
corr <- cor(dt_cor, use = "complete.obs", method = "pearson") # Correlation matrix
corrplot(corr)
# BILL_AMT are highly correlated to each other. This may create an issue later 
# e.g. logistic regression due to potential multicollinearity

set.seed(100) # Set seed

### Train-test split ###
train <- sample.split(Y = dt$`default payment next month`, SplitRatio = 0.75)
trainset <- subset(dt, train == T)
testset <- subset(dt, train == F)

########################################
# LOGISTIC REGRSSION
########################################
logreg <- glm(
  `default payment next month` ~ ., 
  family = binomial, 
  data = trainset
)
summary(logreg)


y.test.prob <- predict(
  logreg, 
  type = 'response', 
  newdata = testset,
  probability = TRUE
)
threshold <- 0.5
# If probability > threshold, then predict Y = 1, else predict Y = 0.
y.test.hat <- ifelse(y.test.prob > threshold, 1, 0)

# Confusion Matrix
table(observed=testset$`default payment next month`, predicted=y.test.hat)
mean(testset$`default payment next month` == y.test.hat)

# Select significant variables #
# Perform AIC
logreg_AIC <- step(logreg)
vif(logreg_AIC)
