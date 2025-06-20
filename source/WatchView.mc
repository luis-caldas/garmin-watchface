/*
 * Imports
 */

using Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Sensor;
using Toybox.SensorLogging;
using Toybox.Activity;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Position;
using Toybox.Weather;
using Toybox.Activity;
using Toybox.ActivityMonitor;

/*
 * Main
 */

class WatchView extends WatchUi.WatchFace {

    /*
    * Constants
    */

    // Separation
    const STEP = 100.0;

    // Visual
    const COLOUR_LINE = 0x262020;
    const COLOUR_SECONDARY = 0x0A0A06;
    const COLOUR_BACKGROUND = Graphics.COLOR_BLACK;
    const COLOUR_DEFAULT = Graphics.COLOR_WHITE;
    const COLOUR_DEFAULT_LPM = 0xEAEAEA;
    const COLOUR_ACCENT = Graphics.COLOR_WHITE;

    const WIDTH_LINE = 3.0;

    const LINE_THICKNESS = 2.0;

    const ICON_SIZE = 28;

    const BOTTOM_ICON_SPACING = 3.0;
    const BOTTOM_ICON_EDGE = 20.0;
    const BOTTOM_ICON_OFFSET = 23.0;

    const MIDDLE_ICON_SPACING = BOTTOM_ICON_SPACING;
    const MIDDLE_ICON_EDGE = 17.0;
    const MIDDLE_ICON_OFFSET = 20.0;

    const DATE_SPACING = 26.0;
    const DATE_INTERSPACE = 12.0;

    const WEEK_SPACING = 13.0;
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

    /*
     * Variables
     */

    // Low Power Mode
    var lpm = false;

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
    var bitmap_progress = null;
    var bitmap_sun = null;
    var bitmap_bolt = null;
    var bitmap_calorie = null;
    var bitmap_step = null;

    // View Sizes
    var width = null;
    var height = null;
    var step_x = null;
    var step_y = null;
    var acquired = false;

    /*
     *  Utilities
     */

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

    function militaryTimezone(secondsOffset) {

        // Calculate Timezone
        var single = secondsOffset / Time.Gregorian.SECONDS_PER_HOUR;

        // Get Letter
        return MILITARY_TIMEZONES[single];

    }

    function formatMoment(time) {
        // Check null
        if (time == null) { return "-"; }
        // Get Info
        var now = Gregorian.info(time, Time.FORMAT_MEDIUM);
        // Return
        return Lang.format("$1$$2$", [ now.hour.format("%02d"), now.min.format("%02d") ]);
    }

    function formatMomentSeconds(time) {
        // Check null
        if (time == null) { return "-"; }
        // Get Info
        var now = Gregorian.info(time, Time.FORMAT_MEDIUM);
        // Return
        return now.sec.format("%02d");
    }

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
        bitmap_progress = WatchUi.loadResource(Rez.Drawables.Progress);
        bitmap_sun = WatchUi.loadResource(Rez.Drawables.Sun);
        bitmap_bolt = WatchUi.loadResource(Rez.Drawables.Bolt);
        bitmap_calorie = WatchUi.loadResource(Rez.Drawables.Calorie);
        bitmap_step = WatchUi.loadResource(Rez.Drawables.Step);
    }

    /*
     * Needed
     */

    // Constructor
    function initialize() {
        // Initialize Parent
        WatchFace.initialize();
        // Initialise Fonts
        initialiseFonts();
        // Initialise Bitmaps
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

    function myLPMUpdate(dc) {

        // Redraw Layout
        View.onUpdate(dc);

        // Update Sizing
        extract(dc);

        // Generally Used
        var moment = Time.now();

        // Only Time
        drawTime(dc, moment, true);

    }

    function myUpdate(dc) {

        /*
         * Setup
         */

        // Redraw Layout
        View.onUpdate(dc);

        // Update Sizing
        extract(dc);

        // Generally Used
        var moment = Time.now();
        var monitor = ActivityMonitor.getInfo();

        // Device
        var device = System.getDeviceSettings();

        /*
         * Draw
         */

        // Base Color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Separations
        edgeRectangle(dc, false, false, 15, 50, 63);
        separationRectangle(dc, 0, 35);
        separationRectangle(dc, 67, 88);

        // edgeRectangle(dc, true, false, 16, 35, 65);
        // separationRectangle(dc, 20, 35);
        // separationRectangle(dc, 65, 76);
        // separationRectangle(dc, 84, 93);
        // inBetweenSeparationRectangle(dc, 65, 76, 49, LINE_THICKNESS);

        // Time
        drawTime(dc, moment, false);
        drawSecondsTimezone(dc, moment);

        // Date
        drawDate(dc, moment);

        // Week
        drawWeek(dc, moment);

        // Battery
        drawBattery(dc);

        // Notifications
        drawNotifications(dc, device);

        // Sunrise & Sunset
        // drawSunriseSunset(dc, moment);

        // Heart
        drawHeart(dc);

        // Body Battery
        drawBodyBattery(dc);

        // Calorie
        // drawCalorie(dc, monitor);

        // Stress
        // drawStress(dc, monitor);

        // Steps
        // drawSteps(dc, monitor);

    }

    /*
     * Custom
     */

    function drawTime(dc, time, lpm) {

        var colour = COLOUR_DEFAULT;

        var seconds_offset = coordinator_x(8);

        // Low Power
        if (lpm) {
            colour = COLOUR_DEFAULT_LPM;
            seconds_offset = 0;
        }

        // Hours and Minutes
        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (width / 2) - seconds_offset,
            height / 2,
            font_watch,
            formatMoment(time),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    function drawSecondsTimezone(dc, time) {

        // Offsets
        var offset = 7;
        var edge = 8;
        var fix = 0.5;

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        // Seconds
        dc.drawText(
            width - coordinator_x(edge),
            height / 2 - coordinator_y(offset),
            font_watch_seconds,
            formatMomentSeconds(time),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Timezone
        dc.drawText(
            width - coordinator_x(edge),
            height / 2 + coordinator_y(offset - fix),
            font_64,
            militaryTimezone(System.getClockTime().timeZoneOffset),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    function drawDate(dc, moment) {

        // Offset
        var offset = 7.0;

        // Get Format
        var today = Gregorian.info(moment, Time.FORMAT_SHORT);

        // General
        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (width / 2) - coordinator_x(DATE_INTERSPACE) + coordinator_x(offset),
            coordinator_y(DATE_SPACING),
            font_64,
            today.year,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            (width / 2) + coordinator_x(offset),
            coordinator_y(DATE_SPACING),
            font_64,
            today.month.format("%02d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            (width / 2) + coordinator_x(DATE_INTERSPACE) + coordinator_x(offset),
            coordinator_y(DATE_SPACING),
            font_64,
            today.day.format("%02d"),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

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

    function drawWeek(dc, moment) {

        // Week Data
        var week = Gregorian.info(moment, Time.FORMAT_MEDIUM);
        var week_year = Gregorian.info(moment, Time.FORMAT_SHORT);

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        // Icon
        dc.drawBitmap(
            (width / 2),
            coordinator_y(WEEK_SPACING) - (ICON_SIZE / 2),
            bitmap_week
        );

        // Plain Weekday
        dc.drawText(
            (width / 2) - coordinator_x(WEEK_INTERSPACE),
            coordinator_y(WEEK_SPACING),
            font_64,
            week.day_of_week,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Week of Year
        dc.drawText(
            (width / 2) + ICON_SIZE + coordinator_x(WEEK_INTERSPACE),
            coordinator_y(WEEK_SPACING),
            font_64,
            iso_week_number(week_year.year, week_year.month, week_year.day),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawSunriseSunset(dc, moment) {

        // Spacing
        var spacing = 8;
        var edge = 8;

        // Strings
        var sunrise = null;
        var sunset = null;

        // Get Weather
        var conditions = Weather.getCurrentConditions();
        if (conditions != null && conditions.observationLocationPosition != null) {
            var location = conditions.observationLocationPosition;
            // Get Sunrise & Sunset
            sunrise  = Weather.getSunrise(location, moment);
            sunset = Weather.getSunset(location, moment);
        }

        // Icon
        dc.drawBitmap(
            coordinator_x(edge) - (ICON_SIZE / 2),
            (height / 2) - (ICON_SIZE / 2),
            bitmap_sun
        );

        // Draw
        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            coordinator_x(edge),
            (height / 2) - coordinator_y(spacing),
            font_48,
            formatMoment(sunrise),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            coordinator_x(edge),
            (height / 2) + coordinator_y(spacing) - 1,
            font_48,
            formatMoment(sunset),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawSteps(dc, monitor) {

        var offset = 17;

        dc.drawBitmap(
            width - coordinator_x(MIDDLE_ICON_EDGE + offset + MIDDLE_ICON_SPACING) - (ICON_SIZE / 2),
            height - coordinator_y(MIDDLE_ICON_OFFSET) - (ICON_SIZE / 2.0),
            bitmap_step
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            width - coordinator_x(MIDDLE_ICON_EDGE + offset) + (ICON_SIZE / 2),
            height - coordinator_y(MIDDLE_ICON_OFFSET),
            font_32,
            monitor.steps,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawCalorie(dc, monitor) {

        var offset = 21;

        dc.drawBitmap(
            coordinator_x(MIDDLE_ICON_EDGE + offset) - (ICON_SIZE / 2),
            height - coordinator_y(MIDDLE_ICON_OFFSET) - (ICON_SIZE / 2.0),
            bitmap_calorie
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            coordinator_x(MIDDLE_ICON_EDGE + offset + MIDDLE_ICON_SPACING) + (ICON_SIZE / 2),
            height - coordinator_y(MIDDLE_ICON_OFFSET),
            font_32,
            monitor.calories,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawStress(dc, monitor) {

        dc.drawBitmap(
            coordinator_x(MIDDLE_ICON_EDGE) - (ICON_SIZE / 2),
            height - coordinator_y(MIDDLE_ICON_OFFSET) - (ICON_SIZE / 2.0),
            bitmap_bolt
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            coordinator_x(MIDDLE_ICON_EDGE + MIDDLE_ICON_SPACING) + (ICON_SIZE / 2),
            height - coordinator_y(MIDDLE_ICON_OFFSET),
            font_32,
            monitor.stressScore,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawNotifications(dc, device) {

        // Icon Compensation
        var compensationY = 0.5;

        dc.drawBitmap(
            coordinator_x(BOTTOM_ICON_EDGE) - (ICON_SIZE / 2),
            height - coordinator_y(BOTTOM_ICON_OFFSET - compensationY) - (ICON_SIZE / 2.0),
            bitmap_message
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            coordinator_x(BOTTOM_ICON_EDGE + BOTTOM_ICON_SPACING) + (ICON_SIZE / 2),
            height - coordinator_y(BOTTOM_ICON_OFFSET),
            font_32,
            device.notificationCount,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function getBodyBattery() {

        // Check Compatibility
        if (Toybox.SensorHistory has :getBodyBatteryHistory) {
            // Get the Latest Sample
            return Toybox.SensorHistory
                .getBodyBatteryHistory({})
                .next()
                .data
                .toNumber();
        }
        return null;

    }

    function drawBodyBattery(dc) {

        // Get Battery
        var battery = getBodyBattery();
        if (battery == null) {
            battery = "-";
        }

        // Icon Compensation
        var offset = 7.0;
        var compensationY = 0.5;

        dc.drawBitmap(
            width - coordinator_x(BOTTOM_ICON_EDGE + BOTTOM_ICON_SPACING + offset) - (ICON_SIZE / 2.0),
            height - coordinator_y(BOTTOM_ICON_OFFSET - compensationY) - (ICON_SIZE / 2.0),
            bitmap_progress
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            width - coordinator_x(BOTTOM_ICON_EDGE + offset) + (ICON_SIZE / 2.0) + coordinator_x(BOTTOM_ICON_SPACING),
            height - coordinator_y(BOTTOM_ICON_OFFSET),
            font_48,
            battery,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function getHeart() {

        // Nothing
        var no_heart = "-";

        // Activity
        var info = Activity.getActivityInfo();

        // If in activity
        if (info != null) {
            var heart_rate = info.currentHeartRate;
            if (heart_rate == null) {
                return no_heart;
            }
            return Lang.format("$1$", [heart_rate]);
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

    function drawHeart(dc) {

        var compensationY = 0.5;

        dc.drawBitmap(
            (width / 2) - ICON_SIZE - coordinator_x(BOTTOM_ICON_SPACING + BOTTOM_ICON_SPACING),
            height - coordinator_y(BOTTOM_ICON_OFFSET - compensationY) - (ICON_SIZE / 2.0),
            bitmap_pulse
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            (width / 2) + coordinator_x(BOTTOM_ICON_SPACING),
            height - coordinator_y(BOTTOM_ICON_OFFSET),
            font_48,
            getHeart(),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawBattery(dc) {
        // Get Battery
        var battery = System.getSystemStats().battery;

        // Battery size in steps
        var battery_x = 10;
        var battery_y = 6;

        // Offset from edge
        var edge = 1.5;

        // Battery Ratio
        var ratio = (battery_x * 2) * (battery / 100);

        // TODO ? Add Colour Information ?

        // Battery Colour
        var max = 0xFF / 2;
        var colour = ((max * (battery / 100)) + max).toNumber();

        var hex = (colour << 16) | (colour << 8) | colour;

        dc.setColor(hex, Graphics.COLOR_TRANSPARENT);

        // Battery Percentage
        dc.fillRectangle(
            (width / 2) - coordinator_x(battery_x),
            height - coordinator_y(battery_y + edge),
            coordinator_x(ratio),
            coordinator_y(battery_y)
        );

        // Battery Width
        dc.setPenWidth(2);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Draw Box
        dc.drawRectangle(
            (width / 2) - coordinator_x(battery_x),
            height - coordinator_y(battery_y + edge),
            coordinator_x(battery_x * 2),
            coordinator_y(battery_y)
        );
        // Draw Tip
        dc.drawLine(
            (width / 2) + coordinator_x(battery_x + 1),
            height - coordinator_y((battery_y / 2) + edge - 1),
            (width / 2) + coordinator_x(battery_x + 1),
            height - coordinator_y((battery_y / 2) + edge + 1)
        );

    }

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

}
