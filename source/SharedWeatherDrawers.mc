
module SharedWeatherDrawers {
    function drawSun(dc, x, y, weatherPosition) {
        WeatherHelpers.drawSun(dc, x - 25, y, weatherPosition);
    }

    function drawMoon(dc, x, y, weatherPosition) {
        WeatherHelpers.drawMoon(dc, x - 25, y, weatherPosition);
    }

    function drawClouds(dc, x, y, weatherPosition) {
        WeatherHelpers.drawClouds(dc, x + 20, y, weatherPosition);
    }

    function drawRain(dc, x, y, weatherPosition) {
        WeatherHelpers.drawRain(dc, x + 18, y + 30, weatherPosition);
    }

    function drawSnow(dc, x, y, weatherPosition) {
        WeatherHelpers.drawSnow(dc, x + 18, y + 30, weatherPosition);
    }

    function drawStorm(dc, x, y, weatherPosition) {
        WeatherHelpers.drawStorm(dc, x + 20, y + 32, weatherPosition);
    }
}