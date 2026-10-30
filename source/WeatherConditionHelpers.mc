using Toybox.Weather;

module WeatherConditionHelpers {
    var rainConditions = [
        Weather.CONDITION_RAIN,
        Weather.CONDITION_SCATTERED_SHOWERS,
        Weather.CONDITION_LIGHT_RAIN_SNOW,
        Weather.CONDITION_LIGHT_RAIN,
        Weather.CONDITION_UNKNOWN_PRECIPITATION,
        Weather.CONDITION_HEAVY_RAIN,
        Weather.CONDITION_LIGHT_SHOWERS,
        Weather.CONDITION_SHOWERS,
        Weather.CONDITION_HEAVY_SHOWERS,
        Weather.CONDITION_CHANCE_OF_SHOWERS,
        Weather.CONDITION_MIST,
        Weather.CONDITION_DRIZZLE,
        Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN,
        Weather.CONDITION_FREEZING_RAIN,
    ];

    var snowConditions = [
        Weather.CONDITION_SNOW,
        Weather.CONDITION_HAIL,
        Weather.CONDITION_CHANCE_OF_SNOW,
        Weather.CONDITION_FLURRIES,
    ];

    var cloudyConditions = [
        Weather.CONDITION_CLOUDY,
        Weather.CONDITION_PARTLY_CLOUDY,
        Weather.CONDITION_MOSTLY_CLOUDY
    ];

    var stormConditions = [
        Weather.CONDITION_THUNDERSTORMS,
        Weather.CONDITION_LIGHT_SNOW,
        Weather.CONDITION_HEAVY_SNOW,
        Weather.CONDITION_HEAVY_RAIN_SNOW,
        Weather.CONDITION_RAIN_SNOW,
        Weather.CONDITION_CHANCE_OF_THUNDERSTORMS,
    ];

    function isCloudy(condition) {
        if (cloudyConditions.indexOf(condition) >= 0) {
                return true;
        }
        return false;
    }

    function isRaining(condition) {
        if (rainConditions.indexOf(condition) >= 0) {
            return true;
        }
        return false;
    }

    function isSnowing(condition) {
        if (snowConditions.indexOf(condition) >= 0) {
            return true;
        }
        return false;
    }

    function isStorming(condition) {
        if (stormConditions.indexOf(condition) >= 0) {
            return true;
        }
        return false;
    }
}