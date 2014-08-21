Google_Flu_Trends_ARIMA
=======================

Based on a tutorial online

ARIMA(p,d,q): ARIMA models are, in theory, the most general class of models for forecasting a time series which can be stationarized by transformations such as differencing and logging. In fact, the easiest way to think of ARIMA models is as fine-tuned versions of random-walk and random-trend models: the fine-tuning consists of adding lags of the differenced series and/or lags of the forecast errors to the prediction equation, as needed to remove any last traces of autocorrelation from the forecast errors.

The acronym ARIMA stands for "Auto-Regressive Integrated Moving Average." Lags of the differenced series appearing in the forecasting equation are called "auto-regressive" terms, lags of the forecast errors are called "moving average" terms, and a time series which needs to be differenced to be made stationary is said to be an "integrated" version of a stationary series. Random-walk and random-trend models, autoregressive models, and exponential smoothing models (i.e., exponential weighted moving averages) are all special cases of ARIMA models.

A nonseasonal ARIMA model is classified as an "ARIMA(p,d,q)" model, where:

p is the number of autoregressive terms,
d is the number of nonseasonal differences, and
q is the number of lagged forecast errors in the prediction equation.
To identify the appropriate ARIMA model for a time series, you begin by identifying the order(s) of 
differencing needing to stationarize the series and remove the gross features of seasonality, 
perhaps in conjunction with a variance-stabilizing transformation such as logging or deflating. 
If you stop at this point and predict that the differenced series is constant, you have merely fitted a 
random walk or random trend model. (Recall that the random walk model predicts the first difference of the 
series to be constant, the seasonal random walk model predicts the seasonal difference to be constant, and the 
seasonal random trend model predicts the first difference of the seasonal difference to be constant--usually zero.) 
However, the best random walk or random trend model may 
still have autocorrelated errors, suggesting that additional factors of some kind are needed in the prediction equation.

- Using Google Flu Trends data, and exploring the various tests such as ACF, PACF, and Q-Statistics. 
