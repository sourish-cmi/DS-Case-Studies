## Visualisation with time series data

rm(list=ls())

time(AirPassengers)
AirP_data = data.frame(cbind(time = time(AirPassengers)
                            ,AirPassengers=AirPassengers))
n=nrow(AirP_data)
m=ceiling(n*0.7)

AirP_data$train_test=c(rep('train',length.out=m)
                  ,rep('test',length.out=(n-m)))

## Q1 Why split the data in such a way in line 14 and 15?
AirP_data_train = AirP_data[AirP_data$train_test=='train',]
AirP_data_test = AirP_data[AirP_data$train_test=='test',]

plot(NULL,xlim=c(min(AirP_data$time)
                  ,max(AirP_data$time))
     ,ylim=c(min(AirP_data$AirPassengers)
             ,max(AirP_data$AirPassengers))
     ,xlab = ''
     ,ylab = 'AirPassengers')
grid(col='black',lty=1)
lines(AirP_data_train$time,AirP_data_train$AirPassengers
     ,lwd=2
     ,col='blue')
lines(AirP_data_test$time
      ,AirP_data_test$AirPassengers
      ,col='purple',lwd=2)
abline(v=1957.333,col='red',lty=2)

## Q2: What is the mathematical model here in fit1?
## AirP = a + b*Time
fit1 = lm(AirPassengers ~ time
          ,data = AirP_data_train)
summary(fit1)
abline(fit1,lwd=2)

## Q3: What is the mathematical model here in fit2?
## AirP = a + b*Time + c *Time^2
fit2 = lm(AirPassengers ~ time+I(time^2)
          ,data = AirP_data_train)
summary(fit2)

AirP_data_test$pred = predict(fit2,newdata = AirP_data_test)
lines(AirP_data_test$time,AirP_data_test$pred,col='red',lty=1,lwd=2)
lines(AirP_data_train$time,fit2$fitted.values,col='blue',lty=1,lwd=2)



## Q4: Why am I creating these variables in lines 47,48 and 49?
## AirP = a + b Time + c Time^2 + d1 Sin(omega*Time) + e1 Cos(omega*Time)
## sin, cos transformations are known as enginered feature (ML)
## in stat literature it is known as transformed predictors

omega = 2*pi
AirP_data$S1 = sin(omega*AirP_data$time)
AirP_data$C1 = cos(omega*AirP_data$time)


head(AirP_data)

AirP_data_train = AirP_data[AirP_data$train_test=='train',]
AirP_data_test = AirP_data[AirP_data$train_test=='test',]

## Q5:What is the mathematical model we are trying to fit using lm?
##    Are you visually satisfied with the modeling effort

fit3=lm(AirPassengers ~ time+I(time^2)+S1+C1
              ,data = AirP_data_train)
summary(fit3)
AirP_data_test$pred = predict(fit3,newdata = AirP_data_test)

## draw new plot

plot(NULL,xlim=c(min(AirP_data$time)
                 ,max(AirP_data$time))
     ,ylim=c(min(AirP_data$AirPassengers)
             ,max(AirP_data$AirPassengers))
     ,xlab = ''
     ,ylab = 'AirPassengers')
grid(col='black',lty=1)
lines(AirP_data_train$time,AirP_data_train$AirPassengers
      ,lwd=2
      ,col='blue')
lines(AirP_data_test$time
      ,AirP_data_test$AirPassengers
      ,col='purple',lwd=2)
abline(v=1957.333,col='red',lty=2)
lines(AirP_data_train$time,fit3$fitted.values,col='blue',lty=1,lwd=2)
lines(AirP_data_test$time,AirP_data_test$pred,col='red',lty=1,lwd=2)


## Another model

AirP_data$S2 = sin(2*omega*AirP_data$time)
AirP_data$C2 = cos(2*omega*AirP_data$time)

AirP_data_train = AirP_data[AirP_data$train_test=='train',]
AirP_data_test = AirP_data[AirP_data$train_test=='test',]

#### 
## Q6:What is the mathematical model we are 
##    tring to fit using lm in fit4?

fit4=lm(AirPassengers ~ time+I(time^2)+S1+C1+S2+C2
         ,data = AirP_data_train)
summary(fit4)
AirP_data_test$pred = predict(fit4,newdata = AirP_data_test)

plot(AirP_data_train$time,AirP_data_train$AirPassengers
     ,xlim=c(min(AirP_data$time)
             ,max(AirP_data$time))
     ,ylim=c(min(AirP_data$AirPassengers)
             ,max(AirP_data$AirPassengers))
     ,xlab = ''
     ,ylab = 'AirPassengers'
     ,type = 'l'
     ,lwd=2
     ,col='blue')

lines(AirP_data_test$time
      ,AirP_data_test$AirPassengers
      ,col='purple',lwd=2)
abline(v=1957.333,col='red',lty=2)

lines(AirP_data_test$time,AirP_data_test$pred,col='red',lty=1,lwd=2)
lines(AirP_data_train$time,fit4$fitted.values,col='blue',lty=1,lwd=2)

#### fifth model

AirP_data$S3 = sin(3*omega*AirP_data$time)
AirP_data$C3 = cos(3*omega*AirP_data$time)

AirP_data_train = AirP_data[AirP_data$train_test=='train',]
AirP_data_test = AirP_data[AirP_data$train_test=='test',]

#### 
## Q7:What is the mathematical model we are 
##    tring to fit using lm in fit5?
fit5=step(lm(AirPassengers ~ time+I(time^2)+S1+C1+S2+C2+S3+C3
         ,data = AirP_data_train))
summary(fit5)
AirP_data_test$pred = predict(fit5,newdata = AirP_data_test)

plot(AirP_data_train$time,AirP_data_train$AirPassengers
     ,xlim=c(min(AirP_data$time)
             ,max(AirP_data$time))
     ,ylim=c(min(AirP_data$AirPassengers)
             ,max(AirP_data$AirPassengers))
     ,xlab = ''
     ,ylab = 'AirPassengers'
     ,type = 'l'
     ,lwd=2
     ,col='blue')

lines(AirP_data_test$time
      ,AirP_data_test$AirPassengers
      ,col='purple',lwd=2)
abline(v=1957.333,col='red',lty=2)

lines(AirP_data_test$time,AirP_data_test$pred,col='red',lty=1,lwd=2)
lines(AirP_data_train$time,fit5$fitted.values,col='blue',lty=1,lwd=2)

#### sixth model
#### 
## Q8:What is the mathematical model we are 
##    tring to fit using lm in fit6?

fit6=step(lm(log(AirPassengers) ~ time+I(time^2)+S1+C1+S2+C2+S3+C3
         ,data = AirP_data_train))
summary(fit6)
AirP_data_test$pred = exp(predict(fit6,newdata = AirP_data_test))

plot(AirP_data_train$time,AirP_data_train$AirPassengers
     ,xlim=c(min(AirP_data$time)
             ,max(AirP_data$time))
     ,ylim=c(min(AirP_data$AirPassengers)
             ,max(AirP_data$AirPassengers))
     ,xlab = ''
     ,ylab = 'AirPassengers'
     ,type = 'l'
     ,lwd=2
     ,col='blue')

lines(AirP_data_test$time
      ,AirP_data_test$AirPassengers
      ,col='purple',lwd=2)
abline(v=1957.333,col='red',lty=2)
 
lines(AirP_data_test$time,AirP_data_test$pred,col='red',lty=1,lwd=2)
lines(AirP_data_train$time,exp(fit6$fitted.values),col='blue',lty=1,lwd=2)

####

plot(log(AirPassengers))
## dt = log(AirPass[t])-log(AirPass[t-1])

dt = diff(log(AirPassengers))

plot(dt)
abline(h=0,col='red')


