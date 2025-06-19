/*
 * Imports
 */

using Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Sensor;
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
    const COLOUR_LINE = Graphics.COLOR_DK_GRAY;
    const COLOUR_BACKGROUND = Graphics.COLOR_DK_GRAY;
    const COLOUR_DEFAULT = Graphics.COLOR_WHITE;
    const COLOUR_ACCENT = Graphics.COLOR_WHITE;

    const WIDTH_LINE = 2.0;

    const ICON_SIZE = 5.0;

    const BOTTOM_ICON_SPACING = 4.0;
    const BOTTOM_ICON_EDGE = 27.0;
    const BOTTOM_ICON_OFFSET = 13.5;

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

    // Fonts
    var font_10 = null;
    var font_11 = null;
    var font_12 = null;
    var font_14 = null;
    var font_16 = null;
    var font_24 = null;
    var font_32 = null;
    var font_40 = null;
    var font_48 = null;
    var font_56 = null;
    var font_64 = null;
    var font_96 = null;
    var font_128 = null;

    // Bitmaps
    var bitmap_pulse = null;
    var bitmap_sun = null;
    var bitmap_message = null;

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
        font_10 = WatchUi.loadResource(Rez.Fonts.Courier10);
        font_11 = WatchUi.loadResource(Rez.Fonts.Courier11);
        font_12 = WatchUi.loadResource(Rez.Fonts.Courier12);
        font_14 = WatchUi.loadResource(Rez.Fonts.Courier14);
        font_16 = WatchUi.loadResource(Rez.Fonts.Courier16);
        font_24 = WatchUi.loadResource(Rez.Fonts.Courier24);
        font_32 = WatchUi.loadResource(Rez.Fonts.Courier32);
        font_40 = WatchUi.loadResource(Rez.Fonts.Courier40);
        font_48 = WatchUi.loadResource(Rez.Fonts.Courier48);
        font_56 = WatchUi.loadResource(Rez.Fonts.Courier56);
        font_64 = WatchUi.loadResource(Rez.Fonts.Courier64);
        font_96 = WatchUi.loadResource(Rez.Fonts.Courier96);
        font_128 = WatchUi.loadResource(Rez.Fonts.Courier128);
    }

    function initialiseBitmaps() {
        bitmap_pulse = WatchUi.loadResource(Rez.Drawables.Pulse);
        bitmap_sun = WatchUi.loadResource(Rez.Drawables.Sun);
        bitmap_message = WatchUi.loadResource(Rez.Drawables.Message);
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

    // Updates

    function onPartialUpdate(dc) {
        myUpdate(dc, true);
    }

    function onUpdate(dc) {
        myUpdate(dc, false);
    }

    function myUpdate(dc, partial) {

        /*
         * Setup
         */

        // Redraw Layout
        View.onUpdate(dc);

        // Update Sizing
        extract(dc);

        // Generally Used
        var moment = Time.now();

        // Device
        var device = System.getDeviceSettings();

        /*
         * Draw
         */

        // Base Color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Separations
        separationLine(dc, 20);
        separationLine(dc, 38);
        separationLine(dc, 62);
        separationLine(dc, 71);
        separationLine(dc, 80);
        // inBetweenSeparationLines(dc, 38, 65, 18.5);

        // Sunrise & Sunset
        drawSunriseSunset(dc, moment);

        // Time
        drawDigitalTime(dc, moment);

        // Battery
        drawBattery(dc);

        // Notifications
        drawNotifications(dc, device);

        // Heart
        drawHeart(dc);

    }

    /*
     * Custom
     */

    function drawDigitalTime(dc, time) {

        // Hours and Minutes
        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2,
            font_128,
            formatMoment(time),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Offsets
        var offset = 4.5;
        var edge = 13;

        // Seconds
        dc.drawText(
            width - coordinator_x(edge),
            height / 2 - coordinator_y(offset),
            font_48,
            formatMomentSeconds(time),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Timezone
        dc.drawText(
            width - coordinator_x(edge),
            height / 2 + coordinator_y(offset),
            font_48,
            militaryTimezone(System.getClockTime().timeZoneOffset),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    function drawDateInfo(dc, moment, x, y) {
        // dc.setFont(Graphics.FONT_SMALL);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var today = Gregorian.info(moment, Time.FORMAT_MEDIUM);
        // var dayName = Time.getDayOfWeekName(now.dayOfWeek);
        // dc.drawText(x, y, G.FONT_SMALL, "Day: " + dayName);
        // dc.drawText(x, y + 15, G.FONT_SMALL, "Week: " + now.week + " | DoY: " + now.dayOfYear);
        dc.drawText(x, y + 30, Graphics.FONT_SMALL, "Date: " + today.day + "/" + today.month + "/" + today.year);
    }

    function drawSunriseSunset(dc, moment) {

        // Spacing
        var spacing = 6;
        var edge = 11;

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
        dc.drawScaledBitmap(
            coordinator_x(edge - ((ICON_SIZE - 1) / 2.0)),
            (height / 2) - coordinator_y((ICON_SIZE - 1) / 2.0),
            coordinator_x(ICON_SIZE - 1),
            coordinator_y(ICON_SIZE - 1),
            bitmap_sun
        );

        // Draw
        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            coordinator_x(edge),
            (height / 2) - coordinator_y(spacing),
            font_24,
            formatMoment(sunrise),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            coordinator_x(edge),
            (height / 2) + coordinator_y(spacing) - 1,
            font_24,
            formatMoment(sunset),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawNotifications(dc, device) {

        // Icon Compensation
        var compensationX = 5.0;
        var compensationY = 0.5;

        dc.setColor(COLOUR_BACKGROUND, Graphics.COLOR_TRANSPARENT);

        dc.drawScaledBitmap(
            coordinator_x(BOTTOM_ICON_EDGE) - coordinator_x(BOTTOM_ICON_SPACING + compensationX) + coordinator_x(ICON_SIZE / 2.0),
            height - coordinator_y(BOTTOM_ICON_OFFSET - compensationY) - coordinator_y(ICON_SIZE / 2.0),
            coordinator_x(ICON_SIZE),
            coordinator_y(ICON_SIZE),
            bitmap_message
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            coordinator_x(BOTTOM_ICON_EDGE) + coordinator_x(BOTTOM_ICON_SPACING),
            height - coordinator_y(BOTTOM_ICON_OFFSET),
            font_24,
            device.notificationCount,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
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

        dc.setColor(COLOUR_BACKGROUND, Graphics.COLOR_TRANSPARENT);

        dc.drawScaledBitmap(
            (width / 2) - coordinator_x(BOTTOM_ICON_SPACING) - coordinator_x(ICON_SIZE / 2.0),
            height - coordinator_y(BOTTOM_ICON_OFFSET) - coordinator_y(ICON_SIZE / 2.0),
            coordinator_x(ICON_SIZE),
            coordinator_y(ICON_SIZE),
            bitmap_pulse
        );

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            (width / 2) + coordinator_x(BOTTOM_ICON_SPACING),
            height - coordinator_y(BOTTOM_ICON_OFFSET),
            font_24,
            getHeart(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawBattery(dc) {
        // Get Battery
        var battery = System.getSystemStats().battery;

        // Battery size in steps
        var battery_x = 10;
        var battery_y = 4;

        // Offset from edge
        var edge = 3;

        // Battery Ratio
        var ratio = (battery_x * 2) * (battery / 100);

        // TODO ? Add Colour Information ?
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Battery Percentage
        dc.fillRectangle(
            (width / 2) - coordinator_x(battery_x),
            height - coordinator_y(battery_y + edge),
            coordinator_x(ratio),
            coordinator_y(battery_y)
        );

        // Battery Width
        dc.setPenWidth(2);

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
