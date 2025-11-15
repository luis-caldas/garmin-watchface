
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Weather;
using Toybox.Position;
using Toybox.ActivityMonitor;

module Getters {

    /*************
     * Constants *
     *************/

    const MINUTES_PER_HOUR = 60;

    /*********
     * Cache *
     *********/

    // Vars
    var last_position = null;
    var last_time = null;

    // Cache
    var cache_sunset = null;
    var cache_sunrise = null;

    /***********
     * Methods *
     ***********/

    function getHeart(info) {

        // Nothing
        var no_heart = -1;

        // If in activity
        if (info != null) {
            var heart_rate = info.currentHeartRate;
            if (heart_rate == null) { return no_heart; }
            return heart_rate;
        }

        // Else History
        var heart_history = ActivityMonitor.getHeartRateHistory(null, false);
        var now = heart_history.next();

        // Catch Errors
        if (now == null) { return no_heart; }
        if (now.heartRate == ActivityMonitor.INVALID_HR_SAMPLE) { return no_heart; }

        // Return Rate
        return now.heartRate;

    }

    function getSunriseSunset(moment, short, conditions) {

        // Get Weather
        if (conditions != null && conditions.observationLocationPosition != null) {
            // Get Location
            var location = conditions.observationLocationPosition;
            // Convert it to cacheable string
            var position = location.toGeoString(Position.GEO_MGRS);

            // Time
            var time = (
                short.year.format("%04d") +
                short.month.format("%02d") +
                short.day.format("%02d")
            );

            // Cache
            if (time == last_time && position == last_position) {
                return [cache_sunrise, cache_sunset];
            }

            // Get Sunrise & Sunset
            var sunrise_moment = Weather.getSunrise(location, moment);
            var sunset_moment  = Weather.getSunset(location, moment);
            // Extract Information
            var sunrise_info = Gregorian.info(sunrise_moment, Time.FORMAT_SHORT);
            var sunset_info = Gregorian.info(sunset_moment, Time.FORMAT_SHORT);
            // Calculate Minutes
            var sunrise_minutes = sunrise_info.min + (sunrise_info.hour * MINUTES_PER_HOUR);
            var sunset_minutes = sunset_info.min + (sunrise_info.hour * MINUTES_PER_HOUR);

            // Set Cache
            last_time = time;
            last_position = position;
            cache_sunrise = sunrise_minutes;
            cache_sunset = sunset_minutes;

            return [sunrise_minutes, sunset_minutes];

        }

        return null;

    }

}
