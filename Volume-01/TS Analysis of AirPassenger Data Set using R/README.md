# Applications of Linear Regression and Feature Engineering in Time Series Data

## By Sourish Das
#### Chennai Mathematical Institute

*Sourish is Associate Professor at Chennai Mathematical Institute (CMI). He did his PhD from the University of Connecticut and his postdoc at Duke University. Then he worked in SAS for three years before joining CMI. For the last ten years, he has been faculty at CMI.*

<p align = "center">
<img src="./images/air-passengers.jpeg" alt="drawing" width="800" height="275"/>
</p>

#### Summary
This article shows that we can do much better modeling using simple *linear regression* and *feature engineering*. However, we know there is autocorrelation in the data and we do not addressed about this autocorrelation in this article. The goal of this article is to show that we can develop simple, interpretable time series models with the basic concepts of linear regression, Fourier transform, and feature engineering. This article is incomplete because we did not apply *ARIMA* models and compare performance.


### Introduction

In this case study, we will present the time-series analysis of the `AirPassengers` Dataset using `R`. The data is classic Box & Jenkins (1976) airline data. The dataset consists of univariate time-series data about the number of passengers flying per month from 1949 to 1960 in the US. This time-series dataset addresses the issue of trend, seasonality, and exponential growth. Here we will present how we can model such time series data step-by-step. Note that the dataset is available in the `datasets` package of `R`.

### Data Set

First, we will look at the dataset itself as it is. The dataset is stored as `Time-Series` object and we present it as simple 

```R
> str(AirPassengers)
 Time-Series [1:144] from 1949 to 1961: 112 118 132 129 121 135 148 148 136 119 ...

> AirPassengers
     Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
1949 112 118 132 129 121 135 148 148 136 119 104 118
1950 115 126 141 135 125 149 170 170 158 133 114 140
1951 145 150 178 163 172 178 199 199 184 162 146 166
1952 171 180 193 181 183 218 230 242 209 191 172 194
1953 196 196 236 235 229 243 264 272 237 211 180 201
1954 204 188 235 227 234 264 302 293 259 229 203 229
1955 242 233 267 269 270 315 364 347 312 274 237 278
1956 284 277 317 313 318 374 413 405 355 306 271 306
1957 315 301 356 348 355 422 465 467 404 347 305 336
1958 340 318 362 348 363 435 491 505 404 359 310 337
1959 360 342 406 396 420 472 548 559 463 407 362 405
1960 417 391 419 461 472 535 622 606 508 461 390 432

> plot(AirPassengers,lwd=2)
```
<figure>
<p align = "center">
<img src="./images/Rplot_Fig1.jpeg" alt="drawing" width="600" height="450"/>
</p>
<p align = "center">Figure 1: Simple time series plot of AirPassengers data</p>
</figure>



In the following we present a simple time series modeling using the **statistical linear model** framework.

### Modeling Approach

There are two issues to consider. First, what model fits the data? Then the second issue is how to test if the model is doing a reasonable job or not. We will fit several models. However, we will compare each model on the same test dataset and train them with same dataset. So we split the dataset into train and test. Out of 12 years of data, we consider first eight years of the data as training data and latest four years of the data as test data. So first we split the data accordingly using the following `R` code.

```R
> AirP_data = data.frame(cbind(time = time(AirPassengers),AirPassengers=AirPassengers))
> n=nrow(AirP_data)
> n ## number all data points 
[1] 144
> m=12*8 ## number of data points for taining data
> m
[1] 96

## Create a column marking first 8 years of data as tain and last four years of data as test
> AirP_data$train_test=c(rep('train',length.out=m), rep('test',length.out=(n-m)))


> head(AirP_data)
      time AirPassengers train_test
1 1949.000           112      train
2 1949.083           118      train
3 1949.167           132      train
4 1949.250           129      train
5 1949.333           121      train
6 1949.417           135      train

> tail(AirP_data)
        time AirPassengers train_test
139 1960.500           622       test
140 1960.583           606       test
141 1960.667           508       test
142 1960.750           461       test
143 1960.833           390       test
144 1960.917           432       test

## split the data into train and test
> AirP_data_train = AirP_data[AirP_data$train_test=='train',]
> AirP_data_test = AirP_data[AirP_data$train_test=='test',]

> plot(NULL,xlim=c(min(AirP_data$time),max(AirP_data$time))
         ,ylim=c(min(AirP_data$AirPassengers),max(AirP_data$AirPassengers))
         ,xlab = ''
         ,ylab = 'AirPassengers')
> grid(col='skyblue',lty=1)
> lines(AirP_data_train$time, AirP_data_train$AirPassengers
     ,lwd=2,col='green')
> lines(AirP_data_test$time, AirP_data_test$AirPassengers
      ,col='orange',lwd=2)
> abline(v=1957,col='blue',lty=2,lwd=2)
```

<figure>
<p align = "center">
<img src="./images/Rplot_Fig2.jpeg" alt="drawing" width="600" height="450"/>
</p>
<p align = "center">Figure 2: From 1949 to 1956 (marked as green) used as training data and from 1957 to 1960 (marked as orange) is used for testing the model predictions.</p>
</figure>

**Model 1**: First model we try the simple linear regression over time. That is

$$
y(t) = \alpha + \beta t + \varepsilon(t),
$$

where $\varepsilon(t)\sim N(0,\sigma^2)$. We used `lm` in `R` to fit the model.

```R
> fit1 = lm(AirPassengers ~ time
+           ,data = AirP_data_train)
> summary(fit1)

Call:
lm(formula = AirPassengers ~ time, data = AirP_data_train)

Residuals:
    Min      1Q  Median      3Q     Max 
-63.239 -18.529  -2.838  17.138 100.066 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept) -54501.445   2663.697  -20.46   <2e-16 ***
time            28.017      1.364   20.54   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 30.86 on 94 degrees of freedom
Multiple R-squared:  0.8178,	Adjusted R-squared:  0.8159 
F-statistic: 421.9 on 1 and 94 DF,  p-value: < 2.2e-16
```

As we fit the **Model 1** with `lm`, the `summary` shows that 81.78\% of variability of training data is getting explained by the simple straight line which is explaining the trend in the data. However we should see its performance in test data.


```R
## Predict in test data
> AirP_data_test$pred = predict(fit1,newdata = AirP_data_test)
> lines(AirP_data_test$time,AirP_data_test$pred,col='red',lty=1,lwd=2)
> lines(AirP_data_train$time,fit1$fitted.values,col='blue',lty=1,lwd=2)

## Check the preformance of the prediction in test data.
## Out sample R-square
> cor(AirP_data_test$AirPassengers,AirP_data_test$pred)^2
[1] 0.3103215

## In sample R-square
> cor(AirP_data_train$AirPassengers,fit1$fitted.values)^2
[1] 0.8178068

## Out sample RMSE
> sqrt(mean((AirP_data_test$AirPassengers-AirP_data_test$pred)^2))
[1] 72.6894

## In sample RMSE
> sqrt(mean((AirP_data_train$AirPassengers-fit1$fitted.values)^2))
[1] 30.53734
```
We combine the prediction performance of **Model 1**, in train and test data, in the **Table 1**.

Models   | R-Sqr (In-sample) | R-Sqr (Out-sample) | RMSE (In-sample) | RMSE (Out-sample)
-------- | ----------------- | -------------------|------------------|------------------
Model 1  | 0.8178            | 0.3103             | 30.54            | 72.69

<p align = "left"><b>Table 1</b>: Performance of Model 1. We consider R-square and RMSE for both train and test data. Though Model 1 is perhaps the simplest. Is the model overfitting? Or underfitting?</p>

In Table 1, we presented the performance of Model 1. Though Model 1 is perhaps the simplest, the model is overfitting, as performance is inferior in the test data. Generally, this does not happen if train and test data are similar. However, the train and test data here are markedly different! We considered R-square and RMSE for both train and test data. Figure 3 visually represents the performance of **Model 1**. Clearly, the variability in the test dataset is higher due to the peak season in summer, particularly in the month of July. The **Model 1** fails to capture the highs of summer. Next we introduce the quadratic trend.

<figure>
<p align = "center">
<img src="./images/Rplot_Fig3.jpeg" alt="drawing" width="600" height="450"/>
</p>
<p align = "center">Figure 3: Fitted simple line over train data, described in Model 1.</p>
</figure>

**Model 2**: We consider the quadratice regression over time. That is

$$
y(t) = \alpha + \beta t + \gamma t^2 +\varepsilon(t),
$$

where $\varepsilon(t)\sim N(0,\sigma^2)$. We used `lm` in `R` to fit the model.

```R
> fit2 = lm(AirPassengers ~ time+I(time^2)
+           ,data = AirP_data_train)
> summary(fit2)

Call:
lm(formula = AirPassengers ~ time + I(time^2), data = AirP_data_train)


Coefficients:
              Estimate Std. Error t value Pr(>|t|)  
(Intercept)  5.978e+06  2.454e+06   2.436   0.0167 *
time        -6.150e+03  2.513e+03  -2.447   0.0163 *
I(time^2)    1.582e+00  6.434e-01   2.458   0.0158 *
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 30.06 on 93 degrees of freedom
Multiple R-squared:  0.8289,	Adjusted R-squared:  0.8252 
F-statistic: 225.3 on 2 and 93 DF,  p-value: < 2.2e-16

AirP_data_test$pred = predict(fit2,newdata = AirP_data_test)
lines(AirP_data_test$time,AirP_data_test$pred,col='red',lty=1,lwd=2)
lines(AirP_data_train$time,fit2$fitted.values,col='blue',lty=1,lwd=2)
```

<figure>
<p align = "center">
<img src="./images/Rplot_Fig4.jpeg" alt="drawing" width="600" height="450"/>
</p>
<p align = "center">Figure 4: Fitted quadratic regression (blue) over train data, described in Model 2. The red part of the quadratic curve is the prediction over test data.</p>
</figure>

We combine the prediction performance of **Model 2**, in train and test data, in the **Table 2**.

Models   | R-Sqr (In-sample) | R-Sqr (Out-sample) | RMSE (In-sample) | RMSE (Out-sample)
-------- | ----------------- | -------------------|------------------|------------------
Model 1  | 0.8178            | 0.3103             | 30.54            | 72.69
Model 2. | 0.8289            | 0.3128.            | 29.59.           | 67.99
<p align = "left"><b>Table 2</b>: Performance of Model 1-2. Both in-sample and out-sample R-square increases marginally for a quadratic trend compare to a linear trend. The RMSE decreases for quadratic trend compare to a linear trend.</p>


We can see that both in-sample and out-sample R-square increases marginally for a quadratic trend compare to a linear trend. On the otherhand, both in-sample and out-sample RMSE decreases for quadratic trend compare to a linear trend. The visualisation presents a significant seasonality in the data. We try to capture the seasonality with Fourier transforms. So the third model that we consider is as follows.

**Model 3**: We consider the Fourier trandorm for seasonality along with a quadratice trend over time. That is

$$
y(t) = \alpha + \beta_1 t + \beta_2 t^2 + \gamma_1 \sin(\omega t) + \delta_1 \cos(\omega t) + \varepsilon(t),
$$

where $\varepsilon(t)\sim N(0,\sigma^2)$. We used `lm` in `R` to fit the model.

```R
> omega = 2*pi
> AirP_data$S1 = sin(omega*AirP_data$time)
> AirP_data$C1 = cos(omega*AirP_data$time)


> head(AirP_data)
      time AirPassengers train_test            S1            C1
1 1949.000           112      train -4.134185e-13  1.000000e+00
2 1949.083           118      train  5.000000e-01  8.660254e-01
3 1949.167           132      train  8.660254e-01  5.000000e-01
4 1949.250           129      train  1.000000e+00  1.157773e-12
5 1949.333           121      train  8.660254e-01 -5.000000e-01
6 1949.417           135      train  5.000000e-01 -8.660254e-01


AirP_data_train = AirP_data[AirP_data$train_test=='train',]
AirP_data_test = AirP_data[AirP_data$train_test=='test',]


> fit3=lm(AirPassengers ~ time+I(time^2)+S1+C1
+              ,data = AirP_data_train)
> summary(fit3)
Call:
lm(formula = AirPassengers ~ time + I(time^2) + S1 + C1, data = AirP_data_train)

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)  6.237e+06  1.678e+06   3.716 0.000349 ***
time        -6.415e+03  1.719e+03  -3.733 0.000330 ***
I(time^2)    1.650e+00  4.400e-01   3.749 0.000312 ***
S1           6.851e+00  2.981e+00   2.298 0.023838 *  
C1          -3.005e+01  2.969e+00 -10.124  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 20.56 on 91 degrees of freedom
Multiple R-squared:  0.9217,	Adjusted R-squared:  0.9183 
F-statistic: 267.9 on 4 and 91 DF,  p-value: < 2.2e-16

> AirP_data_test$pred = predict(fit3,newdata = AirP_data_test)
> lines(AirP_data_train$time,fit3$fitted.values,col='blue',lty=1,lwd=2)
> lines(AirP_data_test$time,AirP_data_test$pred,col='red',lty=1,lwd=2)

```

<figure>
<p align = "center">
<img src="./images/Rplot_Fig5.jpeg" alt="drawing" width="600" height="450"/>
</p>
<p align = "center">Figure 5: Fitted the <em>model 3</em>, (blue) over train data. The red part of the curve is the prediction over test data.</p>
</figure>

We combine the prediction performance of **Model 1,2 & 3**, in train and test data, in the **Table 3**.

Models   | R-Sqr (In-sample) | R-Sqr (Out-sample) | RMSE (In-sample) | RMSE (Out-sample)
-------- | ----------------- | -------------------|------------------|------------------
Model 1  | 0.8178            | 0.3103             | 30.54            | 72.69
Model 2  | 0.8289            | 0.3128             | 29.59            | 67.99
Model 3  | 0.9217            | 0.5968             | 20.02            | 53.57 
<p align = "left"><b>Table 3</b>: Performance of Model 1-3. Both in-sample and out-sample R-square increases drastically for a Model 3 compare to a Model 1-2. The RMSE decreases for Model 3 compare to Model 1-2.</p>

From the Figure 5, and the Table 3, we see that the model 3 improves the model predictability, as we add Fourier transform feature in the model. But we can add higher order Fourier transforms to the model as well. Hence we decides to add higher order Fourier transforms. But not ncessarily all the transformed feature will be useful. So we can run the stepwise variable selection using the `step` function in `R`. We consider the next model as follows.

**Model 4**: We consider the higher order Fourier trandorm for seasonality along with a quadratice trend over time. That is

$$
y(t) = \alpha + \beta_1 t + \beta_2 t^2 + \sum_{i=1}^{5}\gamma_i \sin(i\omega t) + \delta_i \cos(i\omega t) + \varepsilon(t),
$$

where $\varepsilon(t)\sim N(0,\sigma^2)$, and $\omega=\frac{2\pi}{f}$, $f=1$. We used `lm` and `step` in `R` to fit the model.

```R

AirP_data$S2 = sin(2*omega*AirP_data$time)
AirP_data$C2 = cos(2*omega*AirP_data$time)


AirP_data$S3 = sin(3*omega*AirP_data$time)
AirP_data$C3 = cos(3*omega*AirP_data$time)

AirP_data$S4 = sin(4*omega*AirP_data$time)
AirP_data$C4 = cos(4*omega*AirP_data$time)

AirP_data$S5 = sin(5*omega*AirP_data$time)
AirP_data$C5 = cos(5*omega*AirP_data$time)

AirP_data_train = AirP_data[AirP_data$train_test=='train',]
AirP_data_test = AirP_data[AirP_data$train_test=='test',]

fit4=step(lm(AirPassengers ~ time+I(time^2)+S1+C1+S2+C2+S3+C3+S4+C4+S5+C5
         ,data = AirP_data_train),trace=0)
summary(fit4)


Call:
lm(formula = AirPassengers ~ time + I(time^2) + S1 + C1 + S2 + 
    C2 + S3 + S4 + S5, data = AirP_data_train)

Residuals:
    Min      1Q  Median      3Q     Max 
-32.553 -11.034  -1.005   8.733  44.985 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)  6.222e+06  1.185e+06   5.252 1.08e-06 ***
time        -6.400e+03  1.213e+03  -5.275 9.79e-07 ***
I(time^2)    1.646e+00  3.106e-01   5.298 8.90e-07 ***
S1           6.912e+00  2.104e+00   3.285  0.00148 ** 
C1          -3.004e+01  2.096e+00 -14.333  < 2e-16 ***
S2           1.322e+01  2.097e+00   6.303 1.21e-08 ***
C2           1.261e+01  2.095e+00   6.016 4.24e-08 ***
S3          -5.786e+00  2.095e+00  -2.761  0.00704 ** 
S4          -6.468e+00  2.095e+00  -3.087  0.00272 ** 
S5          -3.932e+00  2.095e+00  -1.877  0.06390 .  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 14.51 on 86 degrees of freedom
Multiple R-squared:  0.9631,	Adjusted R-squared:  0.9593 
F-statistic: 249.7 on 9 and 86 DF,  p-value: < 2.2e-16
```
The `step` function dropped the `C3`, `C4` and `C5` from the model, i.e., $\cos(3\omega t)$, $\cos(4\omega t)$ and $\cos(5\omega t)$ were dropped from the model.
```R
AirP_data_test$pred = predict(fit4,newdata = AirP_data_test)

plot(NULL,xlim=c(min(AirP_data$time),max(AirP_data$time))
     ,ylim=c(min(AirP_data$AirPassengers),max(AirP_data$AirPassengers))
     ,xlab = '',ylab = 'AirPassengers')
grid(col='skyblue',lty=1)
lines(AirP_data_train$time,AirP_data_train$AirPassengers,lwd=2,col='green')
lines(AirP_data_test$time,AirP_data_test$AirPassengers,col='orange',lwd=2)
abline(v=1957,col='blue',lty=2,lwd=3)

lines(AirP_data_test$time,AirP_data_test$pred,col='red',lty=1,lwd=2)
lines(AirP_data_train$time,fit4$fitted.values,col='blue',lty=1,lwd=2)

```
<figure>
<p align = "center">
<img src="./images/Rplot_Fig6.jpeg" alt="drawing" width="600" height="450"/>
</p>
<p align = "center">Figure 6: Fitted the <em>model 4</em>, (blue) over train data. The red part of the curve is the prediction over test data.</p>
</figure>

We combine the prediction performance of the Model 1-4 in the Table 4.

Models   | R-Sqr (In-sample) | R-Sqr (Out-sample) | RMSE (In-sample) | RMSE (Out-sample)
-------- | ----------------- | -------------------|------------------|------------------
Model 1  | 0.8178            | 0.3103             | 30.54            | 72.69
Model 2  | 0.8289            | 0.3128             | 29.59            | 67.99
Model 3  | 0.9217            | 0.5968             | 20.02            | 53.57 
Model 4  | 0.9632            | 0.7116             | 13.73            | 47.40
<p align = "left"><b>Table 4</b>: Performance of Model 1-4. Both in-sample and out-sample R-square increases drastically for a Model 4 compare to a Model 1-3. The RMSE decreases for Model 4 compare to Model 1-3.</p>

From **Figure 6** and **Table 4**, we see that model 4 improves the model predictability as we add more Fourier transformed features and then run a step-wise feature selection method. However, it looks like the model still misses the highs of summer and the lows of the off-season. It looks like there is exponential behaviour. Hence we decide to consider $\log$-transformation on the target variable `AirPassengers`. We consider the next model as follows.

**Model 5**: We consider the Model 4, but with $\log$-transformation on target variable. That is

$$
\log\big(y(t)\big) = \alpha + \beta_1 t + \beta_2 t^2 + \sum_{i=1}^{5}\gamma_i \sin(i\omega t) + \delta_i \cos(i\omega t) + \varepsilon(t),
$$

where $\varepsilon(t)\sim N(0,\sigma^2)$, and $\omega=\frac{2\pi}{f}$, $f=1$. We used `lm` and `step` in `R` to fit the model.

```R
fit5=step(lm(log(AirPassengers) ~ time+I(time^2)+S1+C1+S2+C2+S3+C3+S4+C4+S5+C5
         ,data = AirP_data_train),trace=0)
summary(fit5)

Call:
lm(formula = log(AirPassengers) ~ time + S1 + C1 + S2 + C2 + 
    S3 + C3 + S4 + S5, data = AirP_data_train)

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept) -2.577e+02  4.059e+00 -63.484  < 2e-16 ***
time         1.347e-01  2.078e-03  64.792  < 2e-16 ***
S1           3.753e-02  6.772e-03   5.542 3.22e-07 ***
C1          -1.313e-01  6.743e-03 -19.470  < 2e-16 ***
S2           6.368e-02  6.747e-03   9.438 6.30e-15 ***
C2           5.045e-02  6.743e-03   7.481 5.85e-11 ***
S3          -2.554e-02  6.743e-03  -3.787 0.000281 ***
C3          -9.317e-03  6.743e-03  -1.382 0.170609    
S4          -3.586e-02  6.741e-03  -5.319 8.15e-07 ***
S5          -1.995e-02  6.741e-03  -2.960 0.003974 ** 
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.0467 on 86 degrees of freedom
Multiple R-squared:  0.9824,	Adjusted R-squared:  0.9806 
F-statistic: 534.7 on 9 and 86 DF,  p-value: < 2.2e-16


AirP_data_test$pred = exp(predict(fit5,newdata = AirP_data_test))

```
<figure>
<p align = "center">
<img src="./images/Rplot_Fig7.jpeg" alt="drawing" width="600" height="450"/>
</p>
<p align = "center">Figure 7: Fitted the <em>model 5</em>, (blue) over train data. The red part of the curve is the prediction over test data.</p>
</figure>

We combine the prediction performance of the Model 1-5 in the Table 5.
Models   | R-Sqr (In-sample) | R-Sqr (Out-sample) | RMSE (In-sample) | RMSE (Out-sample)
-------- | ----------------- | -------------------|------------------|------------------
Model 1  | 0.8178            | 0.3103             | 30.54            | 72.69
Model 2  | 0.8289            | 0.3128             | 29.59            | 67.99
Model 3  | 0.9217            | 0.5968             | 20.02            | 53.57 
Model 4  | 0.9632            | 0.7116             | 13.73            | 47.40
Model 5  | 0.9506            | 0.8600             |  9.12            | 59.25
<p align = "left"><b>Table 5</b>: Performance of Model 1-5. Based on out-sample R-Square Model 5 is best model. However, based on out-sample RMSE Model 4 is best. 
</p>

## Discussion

This article shows that we can do a lot of good modelling by using simple *linear regression* and *feature engineering*. However, we do know there is autocorrelation in the data, and we are not taking care of these autocorrelations in this simple model. This article aims to demonstrate that we can develop simple, explainable time series models with basic concepts of linear regression, Fourier transforms and feature engineering. This article is incomplete because we have not implemented *ARIMA* models and compared the performance.

## Referances:

[1] Box, G. E. P., Jenkins, G. M. and Reinsel, G. C. (1976) Time Series Analysis, Forecasting and Control. Third Edition. Holden-Day. Series G.

