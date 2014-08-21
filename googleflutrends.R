# My version of the Google Flu Trends data based on Team Leda online tutorial.
# MIT License 
# Peadar Coyle August 2014
rawFluData <- read.csv("Data/GOOGLEORG-FLUCOUNTRY.csv", header = TRUE, stringsAsFactors = FALSE)
names(rawFluData)
head(rawFluData)
# Counting number of Columns
ncol(rawFluData)
class(head(rawFluData$Date))
help(as.Date)
class(rawFluData$Date)
class(as.Date("2014-03-01"))
rawFluData$Date = as.Date(rawFluData$Date)
head(rawFluData$Date)
#Now we are ready to plot the data
par(mfrow=c(1,1))
rawFluData$Canada[is.na(rawFluData$Canada)] <- 0
plot(rawFluData$Canada ~ rawFluData$Date, main='Flu Trends Compared', xlab='Time',
     ylab='Cases / Week', type='l', col='blue') #what plotted?
lines(rawFluData$South.Africa ~ rawFluData$Date,
      xlab='Time', ylab='Cases / Week', col='green')
lines(rawFluData$Austria ~ rawFluData$Date,
      xlab='Time', ylab='Cases / Week', type='l',col='red')
# Let us add a legend
legend('topleft', c("Canada", "Austria", "South Africa")
       , lty=1, col=c("blue", "red", "green"), bty='l', cex=1.25, box.lwd= 1.2, box.col= "black")

missingCount = apply(rawFluData, MARGIN=1, function(x){return (sum(is.na(x)))})
plot(missingCount ~ rawFluData$Date, type='h',
     main='Missing Data in Flu Trends (28 Total)',
     xlab='Date', ylab='Missing Countries', col='red')
cleanedFluData = rawFluData[rawFluData$Date > as.Date('2005-12-31'),]
cleanedFluData$World = rowMeans(cleanedFluData[,
                                               -which(names(cleanedFluData) == "Date")], na.rm=TRUE)
# Let us plot the averaged "World" data
plot(cleanedFluData$World ~ cleanedFluData$Date, main
     ="Aggregated Flu Trends", xlab='Time', ylab='
     Cases / Week', type='l', col='blue')
help(diff)
diff(c(1,2,5,10))
help(acf)
par(mfrow=c(4, 2))
plot.new()
cleanedFluData$diff_52 = c(diff(cleanedFluData$World, lag=52), rep(0,52))
plot(cleanedFluData$diff_52 ~ cleanedFluData$Date,
     main = "Once Differenced Flu Data lag=52", xlab='Time', ylab='Cases / Week', type='l', col='brown')
acf(cleanedFluData$diff_52, lag.max = 160, main="ACF
    for lag=(52)", col="brown")
cleanedFluData$diff_52.1 = c(diff(diff(cleanedFluData$World, lag=52)), rep(0,53))
plot(cleanedFluData$diff_52.1 ~ cleanedFluData$Date, 
     main="Twice Differenced Flu Data lag=(52,1)",
     xlab='Time', ylab='Cases / Week', type='l', col='gray')
acf(cleanedFluData$diff_52.1, lag.max = 160, main="ACF for lag=(52,1)", col="gray")
# What about simply differencing once by the immediately previous observation?
cleanedFluData$diff_1 = c(diff(cleanedFluData$World), rep(0,1))
plot (cleanedFluData$diff_1 ~ cleanedFluData$Date, main="Once Differenced Flu Data lag=1", xlab='Time', ylab='Cases / Week', type='l', col='orange')
acf(cleanedFluData$diff_1, lag.max = 160, main="ACF for lag=(1)", col="orange")
# Lastly we'll try differencing twice again, but both times with a lag-1 (meaning immediately obvious from previous observations)
# From experience, this differencing method seems to always work the best.
cleanedFluData$diff_1.1 = c(diff(diff(cleanedFluData$World)), rep(0,2))
plot (cleanedFluData$diff_1.1 ~ cleanedFluData$Date, main="Twice Differenced Flu Data lag=(1,1)", xlab='Time', ylab='Cases / Week', type='l', col='purple')
acf(cleanedFluData$diff_1.1, lag.max = 160, main="ACF for lag=(1, 1)", col='purple')
#Let us reset the plotting area for a final ACF analysis
par(mfrow=c(1, 1))
plot.new()
par(mfrow=c(2,1)) #set to 2-by-1
acf(cleanedFluData$diff_1.1, lag.max = 160, main="ACF Lag=(1,1)")
pacf(cleanedFluData$diff_1.1, lag.max = 160, main="PACF (Partial ACF) Lag=(1,1)")
# Now the fun part
# We build an ARIMA model - Autoregressive Moving Average Model
par(mfrow=c(1, 1))
plot.new()
help(arima)
#Now the building a model part
flu_arima = arima(cleanedFluData$World,
            seasonal = list(order = c(0, 2, 2), period = 52),
            order = c(1,0,0), method="CSS-ML")

flu_arima
flu_arima$aic
#Now that the model is built, we ask it to predict the trend
#over the next 104 periods(2 years)
ahead=104
flu_fcast = predict(flu_arima, n.ahead = ahead)
class(flu_fcast) #Check what is returned
flu_fcast
# length.out=ahead means to generate up to ahead variable (which
# we set to be 104 ahead). by='1 week', we specify that we want to increment by one week at a time
newx = c(rev(seq(cleanedFluData$Date[1], length.out=ahead, by="1 week")), cleanedFluData$Date)
# We simply append the forecast data for the new y.
newy = c(flu_fcast$pred, cleanedFluData$World)
# Generate the raw plot
par(mfrow=c(1, 1))
plot.new()
plot(newx, newy, type="l", xlab = "weeks", ylab = "values", col="brown",
     main="World Flu Trends Plot including the 52-week forecast")

# Append to the old canvas with the new data point so it's easier to analyze
points(newx[1:ahead], flu_fcast$pred, col = "red", type ="l", lwd=5)
# Let us add in the standard error curve
points(newx[1:ahead], rev(flu_fcast$pred - 2*flu_fcast$se), col = "blue", type = "l", lwd=3)
points(newx[1:ahead], rev(flu_fcast$pred + 2*flu_fcast$se), col = "blue", type = "l", lwd=3)
# How does the prediction look?
# The blue lines represent the relatively possible outcomes (SE lines).
# You might have noticed that the SE lines expand rather rapidly.
# This tells us that the model loses a lot of predictive confidence relatively fast.
par(mfrow=c(2, 1))
# Let's look at the ACF/PACF of the RESIDUALS of the model
# remember we already looked at the ACF of the raw data
acf(flu_arima$resid, lag.max = 160, main = "ACF of fitted residuals")
pacf(flu_arima$resid, lag.max = 160, main = "PACF of fitted residuals")
# We'll also look at tsdiag(), which is essentially a diagnostic of the model:
help(tsdiag)

require(graphics)
tsdiag(flu_arima, gof.lag=400)
#The 1st plot is the residuals of the model.
# We want to make sure that the residuals look random and evenly distributed around y=0.
# The 2nd plot is the ACF of the residuals.
#Similar as before, we want to make sure that the ACF remains below the blue line.
# The 3rd plot is the Ljung-Box Statistic.
#We use Ljung-Box statistic to test whether a series of observations over time are random and independent.
# This time we want to confirm that the p-value remains ABOVE the blue line.