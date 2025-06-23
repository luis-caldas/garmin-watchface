// Imports
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Weather;
using Toybox.Activity;
using Toybox.ActivityMonitor;

// Watch Face Class
class WatchView extends WatchUi.WatchFace {

    /************************
     * Constants & Settings *
     ************************/

    // Separation
    const STEP = 100.0;

    // Visual
    const COLOUR_LINE = 0x1A1A1A;
    const COLOUR_SECONDARY = 0x0A0A06;
    const COLOUR_BACKGROUND = Graphics.COLOR_BLACK;
    const COLOUR_DEFAULT = Graphics.COLOR_WHITE;
    const COLOUR_DEFAULT_LPM = 0xEAEAEA;
    const COLOUR_ACCENT = Graphics.COLOR_WHITE;

    const WIDTH_LINE = 3.0;

    const LINE_THICKNESS = 2.0;

    const ICON_SIZE = 28;

    const MIDDLE_ROW_VERTICAL = 28.0;

    const BOTTOM_ROW_ICON_SPACING = 3.0;
    const BOTTOM_ROW_INTERSPACE = 10.0;
    const BOTTOM_ROW_VERTICAL = 16.0;
    const BOTTOM_ROW_WEIGHT = 3.0;

    const DATE_VERTICAL = 26.0;
    const DATE_INTERSPACE = 12.0;

    const LPM_VERTICAL = 18.0;

    const WEEK_VERTICAL = 13.0;
    const WEEK_INTERSPACE = 7.0;

    // Data
    const MILITARY_TIMEZONES = {
        1   => "A",
        2   => "B",
        3   => "C",
        4   => "D",
        5   => "E",
        6   => "F",
        7   => "G",
        8   => "H",
        9   => "I",
        10  => "K",
        11  => "L",
        12  => "M",
        13  => "N",
        -1  => "N",
        -2  => "O",
        -3  => "P",
        -4  => "Q",
        -5  => "R",
        -6  => "S",
        -7  => "T",
        -8  => "U",
        -9  => "V",
        -10 => "W",
        -11 => "X",
        -12 => "Y",
        0   => "Z"
    };

    // Times
    const MORNING_TIME = 6;
    const AFTERNOON_TIME = 12;
    const EVENING_TIME = 18;
    const NIGHT_TIME = 22;
    const MORNING_WORD = "Morning";
    const AFTERNOON_WORD = "Afternoon";
    const EVENING_WORD = "Evening";
    const NIGHT_WORD = "Night";
    const NORMAL_WORD = "Day";

    // Generic
    const MINUTES_PER_HOUR = 60;

    // Info
    const BATTERY_CRITICAL = 10;

    /*************
     * Variables *
     *************/

    // Low Power Mode
    var lpm = false;

    // View Sizes
    var width = null;
    var height = null;
    var step_x = null;
    var step_y = null;

    // Cache
    var acquired = false;

    var last_position = null;
    var last_time = null;
    var cache_sunset = null;
    var cache_sunrise = null;

    /************************
     * Formatting Utilities *
     ************************/

    function extract(dc) {
        if (!acquired) {

            width = dc.getWidth();
            height = dc.getHeight();

            step_x = width / STEP;
            step_y = height / STEP;

            // Update flag
            acquired = true;
        }
    }

    function coordinator_x(size_x) {
        return step_x * size_x;
    }

    function coordinator_y(size_y) {
        return step_y * size_y;
    }

    function militaryTimezone(seconds_offset) {

        // Calculate Timezone
        var single = seconds_offset / Time.Gregorian.SECONDS_PER_HOUR;

        // Get Letter
        return MILITARY_TIMEZONES[single];

    }

    function julian_day(year, month, day) {
        var a = (14 - month) / 12;
        var y = (year + 4800 - a);
        var m = (month + 12 * a - 3);
        return day + ((153 * m + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045;
    }

    function is_leap_year(year) {
        if (year % 4 != 0) {
            return false;
        }
        else if (year % 100 != 0) {
            return true;
        }
        else if (year % 400 == 0) {
            return true;
        }
        return false;
    }

    function iso_week_number(year, month, day) {

        // Get Firsts
        var first_day_of_year = julian_day(year, 1, 1);
        var given_day_of_year = julian_day(year, month, day);

        var day_of_week = (first_day_of_year + 3) % 7;
        var week_of_year = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;

        // End or Beginning
        if (week_of_year == 53) {
            if (day_of_week == 6) {
                return week_of_year;
            }
            else if (day_of_week == 5 && is_leap_year(year)) {
                return week_of_year;
            }
            else {
                return 1;
            }
        }
        // Previous Year
        else if (week_of_year == 0) {
            first_day_of_year = julian_day(year - 1, 1, 1);
            day_of_week = (first_day_of_year + 3) % 7;
            return (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
        }
        // Old Week
        else {
            return week_of_year;
        }

    }

    /************
     * Printing *
     ************/

    function edgeRectangle(dc, left, black, size, beginning, end) {

        var start = null;
        var colour = COLOUR_LINE;

        // Which Edge
        if (left) {
            start = 0;
        } else {
            start = width - coordinator_x(size);
        }

        // If Black
        if (black) {
            colour = COLOUR_BACKGROUND;
        }

        // Draw Separation Rectangle
        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);

        dc.fillRectangle(
            start,
            coordinator_y(beginning),
            coordinator_x(size),
            coordinator_y(end - beginning)
        );

    }

    function inBetweenSeparationRectangle(dc, start, end, location, thickness) {

        // Draw Separation Rectangle
        dc.setColor(COLOUR_BACKGROUND, Graphics.COLOR_TRANSPARENT);

        dc.fillRectangle(
            coordinator_x(location + (thickness / 2.0)),
            coordinator_y(start),
            coordinator_x(thickness),
            coordinator_y(end - start)
        );
    }

    function separationRectangle(dc, start, end) {

        // Draw Separation Rectangle
        dc.setColor(COLOUR_LINE, Graphics.COLOR_TRANSPARENT);

        dc.fillRectangle(
            0,
            coordinator_y(start),
            width,
            coordinator_y(end - start)
        );
    }

    function separationLine(dc, index) {

        // Draw Separation Line
        dc.setColor(COLOUR_LINE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(WIDTH_LINE);

        dc.drawLine(
            0,
            coordinator_y(index),
            width,
            coordinator_y(index)
        );

    }

    function inBetweenSeparationLines(dc, index, next, offset) {

        // Draw
        dc.setColor(COLOUR_LINE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(WIDTH_LINE);

        dc.drawLine(
            coordinator_x(offset),
            coordinator_y(index),
            coordinator_x(offset),
            coordinator_y(next)
        );

    }

    /***********
     * Getters *
     ***********/

    function getSunriseSunset(moment, short, conditions) {

        // Get Weather
        if (conditions != null && conditions.observationLocationPosition != null) {
            // Get Location
            var location = conditions.observationLocationPosition;
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

    function getHeart(info) {

        // Nothing
        var no_heart = "-";

        // If in activity
        if (info != null) {
            var heart_rate = info.currentHeartRate;
            if (heart_rate == null) {
                return no_heart;
            }
            return heart_rate;
        }

        // Else History
        var heart_history = ActivityMonitor.getHeartRateHistory(null, false);
        var now = heart_history.next();

        // Catch Errors
        if (now == null) {
            return no_heart;
        }
        if (now.heartRate == ActivityMonitor.INVALID_HR_SAMPLE) {
            return no_heart;
        }

        // Return Rate
        return now.heartRate;

    }

    /******************
     * Initialisation *
     ******************/

    // Fonts
    var font_32 = null;
    var font_48 = null;
    var font_64 = null;
    var font_watch = null;
    var font_watch_seconds = null;

    // Bitmaps
    var bitmap_pulse = null;
    var bitmap_message = null;
    var bitmap_week = null;

    function initialiseFonts() {
        // All of them
        font_32 = WatchUi.loadResource(Rez.Fonts.Courier32);
        font_48 = WatchUi.loadResource(Rez.Fonts.Courier48);
        font_64 = WatchUi.loadResource(Rez.Fonts.Courier64);
        font_watch = WatchUi.loadResource(Rez.Fonts.CourierWatch);
        font_watch_seconds = WatchUi.loadResource(Rez.Fonts.CourierWatchSeconds);
    }

    function initialiseBitmaps() {
        bitmap_pulse = WatchUi.loadResource(Rez.Drawables.Pulse);
        bitmap_message = WatchUi.loadResource(Rez.Drawables.Message);
        bitmap_week = WatchUi.loadResource(Rez.Drawables.Week);
    }

    /********
     * Meta *
     ********/

    // Constructor
    function initialize() {
        WatchFace.initialize();
        initialiseFonts();
        initialiseBitmaps();
    }

    // Power Modes
    function onEnterSleep() {
        lpm = true;
    }

    function onExitSleep() {
        lpm = false;
    }

    // Updates
    function onUpdate(dc) {
        if (!lpm) {
            myUpdate(dc);
        } else {
            myLPMUpdate(dc);
        }
    }
    function onPartialUpdate(dc) {
        onUpdate(dc);
    }

    /***********
     * Updates *
     ***********/

    function myLPMUpdate(dc) {

        // Redraw Layout
        View.onUpdate(dc);

        // Update Sizing
        extract(dc);

        // Needed
        var stats = System.getSystemStats();
        var device = System.getDeviceSettings();

        // Generally Used
        var moment = Time.now();
        var clock = System.getClockTime();
        var short = Gregorian.info(moment, Time.FORMAT_SHORT);
        var medium = Gregorian.info(moment, Time.FORMAT_MEDIUM);

        // Time
        drawTime(dc, short, true);
        drawSecondsTimezone(dc, null, clock, true);
        // Date
        drawDate(dc, short, true);
        // Week
        drawWeek(dc, short, medium, true);
        // Notifications
        drawSimpleNotification(dc, device);
        // Battery
        drawCriticalBattery(dc, stats);

    }

    function myUpdate(dc) {

        /*
         * Setup
         */

        // Redraw Layout
        View.onUpdate(dc);

        // Update Sizing
        extract(dc);

        // Time
        var moment = Time.now();
        var clock = System.getClockTime();
        var medium = Gregorian.info(moment, Time.FORMAT_MEDIUM);
        var short = Gregorian.info(moment, Time.FORMAT_SHORT);

        // Weather
        // var conditions = Weather.getCurrentConditions();

        // Activity
        var info = Activity.getActivityInfo();

        // Device
        var stats = System.getSystemStats();
        var device = System.getDeviceSettings();

        // Own
        var heart = getHeart(info);

        /*
         * Draw
         */

        // Base Color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Separations
        edgeRectangle(dc, false, false, 15, 50, 63);
        separationRectangle(dc, 0, 35);
        separationRectangle(dc, 65, 90);

        // Time
        drawTime(dc, short, false);
        drawSecondsTimezone(dc, short, clock, false);

        // Date
        drawDate(dc, short, false);

        // Week
        drawWeek(dc, short, medium, false);

        // Battery
        drawBattery(dc, stats);

        // Word
        drawWord(dc, short);

        // Notifications
        drawNotifications(dc, device);

        // Heart
        drawHeart(dc, heart);

    }

    /******************
     * Draw Functions *
     ******************/

    function drawTime(dc, greg, lpm) {

        var colour = COLOUR_DEFAULT;

        var seconds_offset = coordinator_x(8);

        // Low Power
        if (lpm) {
            colour = COLOUR_DEFAULT_LPM;
        }

        // Hours and Minutes
        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (width / 2) - seconds_offset,
            height / 2,
            font_watch,
            (
                greg.hour.format("%02d") +
                greg.min.format("%02d")
            ),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    function drawSecondsTimezone(dc, greg, clock, lpm) {

        // Colour
        var colour = COLOUR_DEFAULT;

        // Offsets
        var offset = 7;
        var edge = 8;
        var fix = 0.5;

        // Low Power
        if (lpm) {
            colour = COLOUR_DEFAULT_LPM;
            offset = 0;
            fix = 0;
        }

        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);

        if (!lpm) {
            // Seconds
            dc.drawText(
                width - coordinator_x(edge),
                height / 2 - coordinator_y(offset),
                font_watch_seconds,
                greg.sec.format("%02d"),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
        // Timezone
        dc.drawText(
            width - coordinator_x(edge),
            height / 2 + coordinator_y(offset - fix),
            font_64,
            militaryTimezone(clock.timeZoneOffset),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawDate(dc, short, lpm) {

        var colour = COLOUR_DEFAULT;
        var spacing = DATE_VERTICAL;

        // Low Power
        if (lpm) {
            colour = COLOUR_DEFAULT_LPM;
            spacing = LPM_VERTICAL;
        }

        // Offset
        var offset = 7.0;

        // General
        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (width / 2) - coordinator_x(DATE_INTERSPACE) + coordinator_x(offset),
            coordinator_y(spacing),
            font_64,
            short.year,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            (width / 2) + coordinator_x(offset),
            coordinator_y(spacing),
            font_64,
            short.month.format("%02d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            (width / 2) + coordinator_x(DATE_INTERSPACE) + coordinator_x(offset),
            coordinator_y(spacing),
            font_64,
            short.day.format("%02d"),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawWeek(dc, short, medium, lpm) {

        var colour = COLOUR_DEFAULT;
        var spacing = WEEK_VERTICAL;

        // Low Power
        if (lpm) {
            colour = COLOUR_DEFAULT_LPM;
            spacing = 100 - LPM_VERTICAL;
        }

        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);

        // Icon
        if (!lpm) {
            dc.drawBitmap(
                (width / 2),
                coordinator_y(spacing) - (ICON_SIZE / 2),
                bitmap_week
            );
        }

        // Plain Weekday
        dc.drawText(
            (width / 2) - coordinator_x(WEEK_INTERSPACE),
            coordinator_y(spacing),
            font_64,
            medium.day_of_week.toUpper(),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Week of Year
        dc.drawText(
            (width / 2) + ICON_SIZE + coordinator_x(WEEK_INTERSPACE),
            coordinator_y(spacing),
            font_64,
            iso_week_number(short.year, short.month, short.day),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawWord(dc, short) {

        // Start Word
        var word = NORMAL_WORD;

        // Calculate Word
        if (short.hour >= NIGHT_TIME) {
            word = NIGHT_WORD;
        } else if (short.hour >= EVENING_TIME) {
            word = EVENING_WORD;
        } else if (short.hour >= AFTERNOON_TIME) {
            word = AFTERNOON_WORD;
        } else if (short.hour >= MORNING_TIME) {
            word = MORNING_WORD;
        } else {
            word = NIGHT_WORD;
        }

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        // Plain Weekday
        dc.drawText(
            width / 2,
            height - coordinator_y(MIDDLE_ROW_VERTICAL),
            font_64,
            word.toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawSimpleNotification(dc, device) {

        if (device.notificationCount >= 1) {
            // Icon Compensation
            var compensationY = 0.5;

            dc.setColor(COLOUR_DEFAULT_LPM, Graphics.COLOR_TRANSPARENT);
            dc.drawBitmap(
                (width / 2),
                height - coordinator_y(LPM_VERTICAL - compensationY) - (ICON_SIZE / 2.0),
                bitmap_message
            );
        }

    }

    function drawNotifications(dc, device) {

        // Icon Compensation
        var compensationY = 0.5;

        dc.drawBitmap(
            (width / 2) - coordinator_x(BOTTOM_ROW_INTERSPACE / 2.0) - ICON_SIZE - coordinator_x(BOTTOM_ROW_WEIGHT),
            height - coordinator_y(BOTTOM_ROW_VERTICAL - compensationY) - (ICON_SIZE / 2.0),
            bitmap_message
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            (width / 2) - coordinator_x(BOTTOM_ROW_INTERSPACE / 2.0) - ICON_SIZE - coordinator_x(BOTTOM_ROW_ICON_SPACING) - coordinator_x(BOTTOM_ROW_WEIGHT),
            height - coordinator_y(BOTTOM_ROW_VERTICAL),
            font_48,
            device.notificationCount,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawHeart(dc, heart) {

        var compensationY = 0.5;

        dc.drawBitmap(
            (width / 2) + coordinator_x(BOTTOM_ROW_INTERSPACE / 2.0) - coordinator_x(BOTTOM_ROW_WEIGHT),
            height - coordinator_y(BOTTOM_ROW_VERTICAL - compensationY) - (ICON_SIZE / 2.0),
            bitmap_pulse
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            (width / 2) + coordinator_x(BOTTOM_ROW_INTERSPACE / 2.0) + ICON_SIZE + coordinator_x(BOTTOM_ROW_ICON_SPACING) - coordinator_x(BOTTOM_ROW_WEIGHT),
            height - coordinator_y(BOTTOM_ROW_VERTICAL),
            font_48,
            heart,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawCriticalBattery(dc, stats) {

        if (stats.battery < BATTERY_CRITICAL && !stats.charging) {
            dc.setColor(COLOUR_DEFAULT_LPM, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                (width / 2),
                height - coordinator_y(2),
                font_32,
                "!",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

    }

    function drawBattery(dc, stats) {
        // Battery
        var battery = stats.battery;
        var charging = stats.charging;

        // Battery size in steps
        var battery_x = 10;
        var battery_y = 6;

        // Offset from edge
        var edge = 1.5;

        // Battery Ratio
        var ratio = (battery_x * 2) * (battery / 100);

        // Battery Colour
        var max = 0xFF / 2;
        var colour = ((max * (battery / 100)) + max).toNumber();

        var hex = 0x20B020;

        if (!charging) {
            hex = (colour << 16) | (colour << 8) | colour;
        }

        dc.setColor(hex, Graphics.COLOR_TRANSPARENT);

        // Battery Percentage
        dc.fillRectangle(
            (width / 2) - coordinator_x(battery_x),
            height - coordinator_y(battery_y + edge),
            coordinator_x(ratio),
            coordinator_y(battery_y)
        );

        // Battery Width
        dc.setPenWidth(3);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Draw Box
        dc.drawRectangle(
            (width / 2) - coordinator_x(battery_x),
            height - coordinator_y(battery_y + edge),
            coordinator_x(battery_x * 2.0),
            coordinator_y(battery_y)
        );
        // Draw Tip
        dc.drawLine(
            (width / 2) + coordinator_x(battery_x + 1.0),
            height - coordinator_y((battery_y / 2.0) + edge - 1.0),
            (width / 2) + coordinator_x(battery_x + 1.0),
            height - coordinator_y((battery_y / 2.0) + edge + 1.5)
        );

    }

}
