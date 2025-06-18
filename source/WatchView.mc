/*
 * Imports
 */

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

    const CUSTOM_FONT = false;

    // Separation
    const STEP = 100;

    // Visual
    const COLOUR_LINE = Graphics.COLOR_DK_GRAY;
    const COLOUR_DEFAULT = Graphics.COLOR_WHITE;
    const COLOUR_ACCENT = Graphics.COLOR_WHITE;

    const WIDTH_LINE = 2;

    /*
     * Variables
     */

    var font = null;

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

    function formatMoment(time) {
        // Check null
        if (time == null) { return "-- --"; }
        // Get Info
        var now = Gregorian.info(time, Time.FORMAT_MEDIUM);
        // Return
        return Lang.format("$1$ $2$", [ now.hour.format("%02d"), now.min.format("%02d") ]);
    }

    /*
     * Needed
     */

    // Constructor
    function initialize() {

        // Initialize Parent
        WatchFace.initialize();

        // Load Fonts
        if (Rez has :Fonts) {
            if (Rez.Fonts has :Courier) {
                font = Toybox.WatchUi.loadResource(Rez.Fonts.Courier);
            }
        }
    }

    // Updates

    function onPartialUpdate(dc) {
        myUpdate(dc, true);
    }

    function onUpdate(dc) {
        myUpdate(dc, false);
    }

    function myUpdate(dc, partial) {

        // Redraw Layout
        View.onUpdate(dc);

        // Update Sizing
        extract(dc);

        // Generally Used
        var moment = Time.now();
        var time = System.getClockTime();

        // Base Color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // ----- //
        separationLine(dc, 18);

        // ----- //
        separationLine(dc, 38);

        // Sunrise & Sunset
        drawSunriseSunset(dc, moment);

        // inBetweenSeparationLines(dc, 38, 65, 18.5);

        // Time
        drawDigitalTime(dc, time);

        // ----- //
        separationLine(dc, 65);

        // ----- //
        separationLine(dc, 84);

        // Heart
        drawHeart(dc);
        // Battery
        drawBattery(dc);

    }

    /*
     * Custom
     */

    function drawDigitalTime(dc, time) {

        // Sort Font
        var font = CUSTOM_FONT ? null : Graphics.FONT_NUMBER_HOT;

        // Draw
        dc.drawText(width / 2, height / 2, font, Lang.format(
            "$1$ $2$", [
                time.hour.format("%02d"),
                time.min.format("%02d"),
            ]
        ), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

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
        var spacing = 7;
        var edge = 9;

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

        // Draw
        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            coordinator_x(edge),
            width / 2 - coordinator_y(spacing),
            Graphics.FONT_XTINY,
            formatMoment(sunrise),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            coordinator_x(edge),
            width / 2 + coordinator_y(spacing) - 1,
            Graphics.FONT_XTINY,
            formatMoment(sunset),
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
        return Lang.format("$1$", [now.heartRate]);

    }

    function drawHeart(dc) {

        dc.setColor(COLOUR_DEFAULT, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            width / 2,
            height - coordinator_y(14),
            Graphics.FONT_TINY,
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
