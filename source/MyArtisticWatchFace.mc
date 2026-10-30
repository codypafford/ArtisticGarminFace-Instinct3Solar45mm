import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Activity;
using Toybox.UserProfile;
using Toybox.Time;
using Toybox.Math;
using Toybox.Weather;
using Toybox.System;

class MyProjectApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    // This is the "Ignition" that tells the watch to load your face
    function getInitialView() {
        return [ new MyArtisticWatchFace() ];
    }
}

class MyArtisticWatchFace extends WatchUi.WatchFace {
    var timer;

    // HR
    const HEART_RATE_PLACEHOLDER = "--";

    // Weather
    var lastWeatherFetchTime = 0;
    var cachedConditions = null;
    const WEATHER_UPDATE_INTERVAL = 15 * 60; // 15 minutes in seconds
    var currWeatherPosition = 0;
    const weatherPositions = [0, 1, 2];

    // Cached Activity
    var cachedSteps = 0;
    var cachedStepGoal = 7500; // Default if not found
    var cachedDistanceMiles = 0.0;
    var cachedCalories = 0;
    var cachedTimeToRecovery = 0;

    // Battery
    var lastSystemStatsFetchTime = 0;
    var cachedSystemStats= null;
    const SYSTEM_STATS_UPDATE_INTERVAL = 5 * 60; // 5 minutes in seconds

    // Called when the watch enters sleep mode (e.g., wrist down)
    function onEnterSleep() {

    }

    // Called when the watch exits sleep mode (e.g., wrist up)
    function onExitSleep() {
        updateActivityData();
        timer.start(method(:updateActivityData), 60000, true);
        WatchUi.requestUpdate(); // Force a redraw to show seconds
    }

    function onShow() {
        updateActivityData();
        // Start the timer when the watch face is active
        timer.start(method(:updateActivityData), 60000, true);
        WatchUi.requestUpdate(); // Initial call
    }

    function onHide() {
        // Stop the timer when the watch face is no longer visible
        timer.stop();
    }

    function initialize() {
        WatchFace.initialize();
        timer = new Timer.Timer();
    }

    function onPartialUpdate(dc) {
        partialUpdateHeartRate(dc);
    }

    function partialUpdateHeartRate(dc) {
        // Set clip around heart
        // Clear only that region
        dc.setClip(28, 120, 37, 43);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        // Draw Heart Rate
        // Fetch data here
        var info = Activity.getActivityInfo();
        var hr = (info != null && info.currentHeartRate != null) 
            ? info.currentHeartRate.toString() 
            : HEART_RATE_PLACEHOLDER;
        drawHeartRate(dc, hr);
        // Can't forget to clear clip
        dc.clearClip();
    }

    function drawHeartRate(dc, hr) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (hr == null) {
            var info = Activity.getActivityInfo();
            hr = HEART_RATE_PLACEHOLDER; // Default if not wearing the watch

            if (info != null && info.currentHeartRate != null) {
                hr = info.currentHeartRate.toString();
            }
        }

        var x = 46;
        var y = 123;
        dc.drawText(x, y, Graphics.FONT_TINY, hr, Graphics.TEXT_JUSTIFY_CENTER);

        x = x;
        y = y + 25;
        // Draw the two top "humps"
        var scale = 1.5;
        // --- Top humps ---
        dc.fillCircle(x - 2 * scale, y, 2 * scale); // Left hump
        dc.fillCircle(x + 2 * scale, y, 2 * scale); // Right hump

        // --- Bottom triangle point ---
        var points = [
            [x - 4 * scale, y + 1 * scale], // Left corner
            [x + 4 * scale, y + 1 * scale], // Right corner
            [x, y + 6 * scale]              // Bottom point
        ];
        dc.fillPolygon(points);
    }

    function onUpdate(dc) {
        // 1. Clear Screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw things here
        drawInfoCircle(dc);
        drawQuadrants(dc);

        drawTime(dc);
        drawWeather(dc);

        drawNextSunEvent(dc, 10, 89);

        drawActivityData(dc);

        drawHeartRate(dc, null); // Uses partial updates/clips

        drawBattery(dc);
    }

    function updateActivityData() {
        var info = ActivityMonitor.getInfo();

        if (info != null) {
            if (info.steps != null) { cachedSteps = info.steps; }
            if (info.stepGoal != null) { cachedStepGoal = info.stepGoal; }
            if (info.distance != null) { cachedDistanceMiles = info.distance / 160934.4; }
            if (info.calories != null) { cachedCalories = info.calories; }
            if (info.timeToRecovery != null) { cachedTimeToRecovery = info.timeToRecovery; }
        }
    }

    function drawActivityData(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var x = 80;
        var y = 138;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        ShapeHelpers.drawRunner(dc, x + 6, y + 15);
        dc.drawText(x + 8, y + 15, Graphics.FONT_XTINY, cachedSteps, Graphics.TEXT_JUSTIFY_LEFT);
        var distStr = cachedDistanceMiles.format("%.2f") + " mi";
        dc.drawText(x + 15, y, Graphics.FONT_XTINY, distStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawTime(dc) {
        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // Get Current Time
        var clockTime = System.getClockTime();
        var timeStrings = TimeHelpers.getFormattedTime(clockTime);

        var time = timeStrings[0];
        var amPm = timeStrings[1];

        var x = 112;
        var y = 120;
        // Draw Time
        if (time != null) {
            dc.drawText(
                x,
                y,
                Graphics.FONT_SYSTEM_LARGE,
                time,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

        x = x + 44;
        if (amPm != null) {
            dc.drawText(
                x,
                y,
                Graphics.FONT_XTINY,
                amPm,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    function drawInfoCircle(dc) {
        // 1. Set color to White for the ring
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // 2. Make the outline thicker
        dc.setPenWidth(4);                
        
        // 3. Draw an outline instead of a filled shape
        dc.drawCircle(45, 140, 30); 

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(7);                
        dc.drawLine(46, 99, 46, 175);
    }

    function drawQuadrants(dc) {
        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // --- Bottom Quadrant ---
        dc.drawLine(0, 103, 68, 103);
        dc.drawLine(68, 103, 87, 138);
        dc.drawLine(87, 138, 171, 138);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillCircle(142, 34, 34);
    }

    function getNextWeatherPosition() {
        // TODO: use the onsleep or enter sleep to somehow freeze the screen? would that even helper o not sinxe it proabbly redraws the whole screen ever ymin anyways
        if (weatherPositions.indexOf(weatherPositions[currWeatherPosition]) == weatherPositions.size() - 1) {
            currWeatherPosition = 0;
            return weatherPositions[currWeatherPosition];
        } 
        currWeatherPosition = currWeatherPosition + 1;
        return weatherPositions[currWeatherPosition];
    }

    function drawWeather(dc) {
        var currentTime = System.getTimer() / 1000;

        if (cachedConditions == null || (currentTime - lastWeatherFetchTime) > WEATHER_UPDATE_INTERVAL) {
            var newConditions = Weather.getCurrentConditions();
            if (newConditions != null) {
                cachedConditions = newConditions;
                lastWeatherFetchTime = currentTime;
            }
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        // 1. Is there any weather data at all? (Phone might be disconnected)
        if (cachedConditions != null) {
            
            var now = Time.now();
            var sunrise = Weather.getSunrise(cachedConditions.observationLocationPosition, now);
            var sunset = Weather.getSunset(cachedConditions.observationLocationPosition, now);

            // 2. Is it Day or Night?
            var isDay = now.greaterThan(sunrise) && now.lessThan(sunset);

            var startX = 59;
            var startY = 19;
            var weatherPosition = getNextWeatherPosition();
            if (isDay) {
                // DRAW A SUN
                SharedWeatherDrawers.drawSun(dc, startX, startY, weatherPosition);
            } else {
                // DRAW A MOON
                SharedWeatherDrawers.drawMoon(dc, startX, startY, weatherPosition);
            }
            if (WeatherConditionHelpers.isCloudy(cachedConditions.condition)) {
                // DRAW A CLOUD
                 SharedWeatherDrawers.drawClouds(dc, startX, startY, weatherPosition);
            }
            else if (WeatherConditionHelpers.isRaining(cachedConditions.condition)) {
                SharedWeatherDrawers.drawClouds(dc, startX, startY, weatherPosition);
                SharedWeatherDrawers.drawRain(dc, startX, startY, weatherPosition);
            }
            else if (WeatherConditionHelpers.isSnowing(cachedConditions.condition)) {
                SharedWeatherDrawers.drawClouds(dc, startX, startY, weatherPosition);
                SharedWeatherDrawers.drawSnow(dc, startX, startY, weatherPosition);
            }
            else if (WeatherConditionHelpers.isStorming(cachedConditions.condition)) {
                // Draw rain with lightning
                SharedWeatherDrawers.drawClouds(dc, startX, startY, weatherPosition);
                SharedWeatherDrawers.drawRain(dc, startX, startY, 0);  // dont animate rain here since we already animate lightning
                SharedWeatherDrawers.drawStorm(dc, startX, startY, weatherPosition);
            }

            // Draw temperature
            var x = 122;
            var y = 77;

            var settings = System.getDeviceSettings();
            var curTemp = WeatherHelpers.tempFormatter(cachedConditions.temperature, settings, System.UNIT_METRIC);
            var highTemp = WeatherHelpers.tempFormatter(cachedConditions.highTemperature, settings, System.UNIT_METRIC);
            var lowTemp = WeatherHelpers.tempFormatter(cachedConditions.lowTemperature, settings, System.UNIT_METRIC);

            // Convert and Format
            var tempStr = (curTemp != null) ? curTemp.toNumber().toString() : "--";

            var highStr = (highTemp != null && lowTemp != null) ? highTemp.toNumber().toString() : "--";
            var lowStr = (highTemp != null && lowTemp != null) ? lowTemp.toNumber().toString() : "--";


            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            
            // Draw Current Temp
            dc.drawText(x, y, Graphics.FONT_GLANCE_NUMBER, tempStr + "°", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Draw High/Low
            x = 153;
            y = 74;
            dc.drawText(x, y, Graphics.FONT_XTINY, highStr, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawLine(142, 94, 164, 94);
            y = y + 16;
            dc.drawText(x, y, Graphics.FONT_XTINY, lowStr, Graphics.TEXT_JUSTIFY_CENTER);

            // Draw Gauge Data
             var data = null;
            if (cachedConditions.precipitationChance != null && cachedConditions.precipitationChance > 15) {
                data = [(cachedConditions.precipitationChance).toNumber(), "% Prec."];
            }
            else if (cachedConditions.uvIndex != null && cachedConditions.uvIndex > 6) {
                // Show UV index
                data = [(cachedConditions.uvIndex).toNumber(), "UV IDX", null];
            }
            else {
                // Show wind speed
                data = [(cachedConditions.windSpeed).format("%.2f"), "Wind", null];
            }
            if (data != null) {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                dc.drawText(142, 5, Graphics.FONT_LARGE, data[0], Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(142, 28, Graphics.FONT_SMALL, data[1], Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
    }

    function drawNextSunEvent(dc, x, y) {
        var size = 10;

        if (cachedConditions != null) {
            var now = Time.now();
            var sunrise = Weather.getSunrise(cachedConditions.observationLocationPosition, now);
            var sunset = Weather.getSunset(cachedConditions.observationLocationPosition, now);

            if (sunrise == null || sunset == null) {
                return; // no data available
            }

            // Determine next event
            var nextEventTime = null;
            var isSunrise = true;

            if (sunrise.greaterThan(now)) {
                nextEventTime = sunrise;
                isSunrise = true;
            } else if (sunset.greaterThan(now)) {
                nextEventTime = sunset;
                isSunrise = false;
            } else {
                var oneDay = new Time.Duration(86400); 
                nextEventTime = sunrise.add(oneDay);
                isSunrise = true;
            }

            // Format HH:MM
            // 1. Get Gregorian Info from the Moment
            // FORMAT_SHORT gives you the numbers (hour, min) directly
            var tm = Gregorian.info(nextEventTime, Time.FORMAT_SHORT);
            var timeStr = TimeHelpers.getFormattedTime(tm);

            // --- Draw sun icon ---
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);

            var sunRadius = size * 0.5;
            var sunY = y + (isSunrise ? -sunRadius * 0.3 : sunRadius * 0.3);
            dc.fillCircle(x, sunY, sunRadius);

            // Rays
            var rayLength = sunRadius * 0.7;
            var rayCount = 8;
            for (var i = 0; i < rayCount; i++) {
                var angle = 180.0 * i / (rayCount - 1);
                var rad = Math.toRadians(angle);
                var x1 = x + Math.cos(rad) * sunRadius;
                var y1 = sunY - Math.sin(rad) * sunRadius;
                var x2 = x + Math.cos(rad) * (sunRadius + rayLength);
                var y2 = sunY - Math.sin(rad) * (sunRadius + rayLength);
                dc.drawLine(x1, y1, x2, y2);
            }

            // Horizon line
            var horizonY = y + sunRadius;
            dc.drawLine(x - size, horizonY, x + size, horizonY);

            // Glow
            var glowRadius = sunRadius * 0.8;
            var glowStart = isSunrise ? 180 : 0;
            var glowEnd = isSunrise ? 0 : 180;
            dc.drawArc(x, horizonY, glowRadius, glowStart, glowEnd, true);

            // --- Draw time next to icon ---
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + size + 2, y - 10, Graphics.FONT_SMALL, timeStr[0], Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

function drawBattery(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    
    var currentTime = System.getTimer() / 1000;
    if (cachedSystemStats == null || (currentTime - lastSystemStatsFetchTime) > SYSTEM_STATS_UPDATE_INTERVAL) {
        var newStats = System.getSystemStats();
        if (newStats != null) {
            cachedSystemStats = newStats;
            lastSystemStatsFetchTime = currentTime;
        }
    }

    if (cachedSystemStats != null) {
        var batteryLevel = cachedSystemStats.battery;
        var batteryStr = batteryLevel.toNumber().toString() + "%";

        // Coordinates for the text
        var textX = 25; // Shifted right to make room for icon
        var textY = 60;
        
        dc.drawText(textX, textY, Graphics.FONT_TINY, batteryStr, Graphics.TEXT_JUSTIFY_LEFT);

        // --- Draw Battery Icon beside the text ---
        var iconX = textX - 18; // Position to the left of text
        var iconY = textY + 8;   // Vertically centered with FONT_TINY
        var iconWidth = 14;
        var iconHeight = 8;

        // 1. Draw the main outline
        dc.setPenWidth(1);
        dc.drawRectangle(iconX, iconY, iconWidth, iconHeight);

        // 2. Draw the "nub" (positive terminal)
        dc.fillRectangle(iconX + iconWidth, iconY + 2, 2, 4);

        // 3. Draw the fill level
        if (batteryLevel > 0) {
            var fillWidth = ((iconWidth - 4) * (batteryLevel / 100.0)).toNumber();
            if (fillWidth < 1 && batteryLevel > 0) { fillWidth = 1; } // show at least 1px if > 0%
            dc.fillRectangle(iconX + 2, iconY + 2, fillWidth, iconHeight - 4);
        }
    }
}
}
