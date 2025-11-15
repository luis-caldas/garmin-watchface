using Toybox.Graphics;
using Toybox.Time;
using Toybox.WatchUi;
using Toybox.Application.Properties;

using Toybox.System;

module Drawing {

    /***********
     * Cache *
     ***********/

    // View Sizes
    var width = null;
    var halfWidth = null;
    var height = null;
    var halfHeight = null;

    var step_x = null;
    var step_y = null;

    // Fonts
    var font_writing = null;
    var font_timezone = null;
    var font_numbers = null;
    var font_watch = null;
    var font_watch_seconds = null;

    // Bitmaps
    var bitmap_pulse = null;
    var bitmap_pulse_size = null;
    var bitmap_message = null;
    var bitmap_message_size = null;
    var bitmap_week = null;
    var bitmap_week_size = null;

    function initialise(in_width, in_height) {

        // Populate
        width = in_width;
        halfWidth = width / 2.0;
        height = in_height;
        halfHeight = height / 2.0;

        // Populate Ratios
        step_x = width / Configuration.STEP;
        step_y = height / Configuration.STEP;

    }

    function initialiseStart() {

        // Fonts
        font_writing = Configuration.FONT_WRITING;
        font_timezone = Configuration.FONT_TIMEZONE;
        font_numbers = Configuration.FONT_NUMBERS;
        font_watch = Configuration.FONT_WATCH;
        font_watch_seconds = Configuration.FONT_WATCH_SECONDS;

        // Bitmaps
        bitmap_pulse = WatchUi.loadResource(Rez.Drawables.Pulse);
        bitmap_pulse_size = bitmap_pulse.getHeight();
        bitmap_message = WatchUi.loadResource(Rez.Drawables.Message);
        bitmap_message_size = bitmap_message.getHeight();
        bitmap_week = WatchUi.loadResource(Rez.Drawables.Week);
        bitmap_week_size = bitmap_week.getHeight();

    }

    /***********
     * Helpers *
     ***********/

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
        return Configuration.MILITARY_TIMEZONES[single];

    }

    function getColour() {
        return Configuration.COLOURS[Properties.getValue("BackgroundColour")];
    }

    /**********
     * Shapes *
     **********/

    function rectangleEdge(dc, left, black, size, beginning, end) {

        var start = null;
        var colour = getColour();

        // Which Edge
        if (left) {
            start = 0;
        } else {
            start = width - coordinator_x(size);
        }

        // If Black
        if (black) {
            colour = Configuration.COLOUR_DEFAULT_BACKGROUND;
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

    function rectangleBetweenSeparation(dc, start, end, location, thickness) {

        // Draw Separation Rectangle
        dc.setColor(Configuration.COLOUR_DEFAULT_BACKGROUND, Graphics.COLOR_TRANSPARENT);

        dc.fillRectangle(
            coordinator_x(location + (thickness / 2.0)),
            coordinator_y(start),
            coordinator_x(thickness),
            coordinator_y(end - start)
        );
    }

    function rectangleSeparation(dc, start, end) {

        // Draw Separation Rectangle
        dc.setColor(getColour(), Graphics.COLOR_TRANSPARENT);

        dc.fillRectangle(
            0,
            coordinator_y(start),
            width,
            coordinator_y(end - start)
        );
    }

    function lineSeparation(dc, index) {

        // Draw Separation Line
        dc.setColor(getColour(), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(Configuration.LINE_WIDTH);

        dc.drawLine(
            0,
            coordinator_y(index),
            width,
            coordinator_y(index)
        );

    }

    function lineBetweenSeparation(dc, index, next, offset) {

        // Draw
        dc.setColor(getColour(), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(Configuration.LINE_WIDTH);

        dc.drawLine(
            coordinator_x(offset),
            coordinator_y(index),
            coordinator_x(offset),
            coordinator_y(next)
        );

    }

    /***********
     * Drawers *
     ***********/

    function drawTime(dc, greg, lpm) {

        var colour = Configuration.COLOUR_DEFAULT_FOREGROUND;

        var seconds_offset = coordinator_x(Configuration.OFFSET_MAIN_TIME);

        // Low Power
        if (lpm) {
            colour = Configuration.COLOUR_DEFAULT_FOREGROUND_LPM;
        }

        // Hours and Minutes
        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            halfWidth - seconds_offset,
            halfHeight,
            font_watch,
            (
                greg.hour.format("%02d") +
                " " +
                greg.min.format("%02d")
            ),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    function drawSecondsTimezone(dc, greg, clock, lpm) {

        // Colour
        var colour = Configuration.COLOUR_DEFAULT_FOREGROUND;

        // Offsets
        var offset = Configuration.SPACE_SECONDS_VERTICAL;
        var fix = Configuration.SPACE_SECONDS_TIMEZONE;

        // Low Power
        if (lpm) {
            colour = Configuration.COLOUR_DEFAULT_FOREGROUND_LPM;
            offset = 0;
            fix = 0;
        }

        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);

        if (!lpm) {
            // Seconds
            dc.drawText(
                width - coordinator_x(Configuration.SPACE_SECONDS_EDGE),
                halfHeight - coordinator_y(offset),
                font_watch_seconds,
                greg.sec.format("%02d"),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

        // Timezone
        dc.drawText(
            width - coordinator_x(Configuration.SPACE_SECONDS_EDGE),
            halfHeight + coordinator_y(offset + fix),
            lpm ? font_writing : font_timezone,
            militaryTimezone(clock.timeZoneOffset),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawDate(dc, short, lpm) {

        var colour = Configuration.COLOUR_DEFAULT_FOREGROUND;
        var spacing = Configuration.SPACE_TOP_BOTTOM_ROW;

        // Low Power
        if (lpm) {
            colour = Configuration.COLOUR_DEFAULT_FOREGROUND_LPM;
            spacing = Configuration.LPM_TOP_ROW;
        }

        // Offset
        // var offset = 7.0;

        // Concatenate full date string
        var dateString = short.year.format("%4d")   + " " +
                         short.month.format("%02d") + " " +
                         short.day.format("%02d");

        // General
        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            halfWidth,
            coordinator_y(spacing),
            font_numbers,
            dateString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawWeek(dc, short, lpm) {

        var colour = Configuration.COLOUR_DEFAULT_FOREGROUND;
        var spacing = Configuration.SPACE_TOP_TOP_ROW;

        // Low Power
        if (lpm) {
            colour = Configuration.COLOUR_DEFAULT_FOREGROUND_LPM;
            spacing = Configuration.LPM_BOTTOM_ROW;
        }

        dc.setColor(colour, Graphics.COLOR_TRANSPARENT);

        // Icon
        if (!lpm) {
            dc.drawBitmap(
                halfWidth - (bitmap_week_size / 2),
                coordinator_y(spacing) - (bitmap_week_size / 2),
                bitmap_week
            );
        }

        // Plain Weekday
        dc.drawText(
            halfWidth + coordinator_x(Configuration.INTERSPACE_TOP_TOP_ROW),
            coordinator_y(spacing),
            font_writing,
            Configuration.WEEK_DAYS[short.day_of_week],
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Week of Year
        dc.drawText(
            halfWidth - coordinator_x(Configuration.INTERSPACE_TOP_TOP_ROW),
            coordinator_y(spacing),
            font_numbers,
            WeekNumber.weekNumber(short.year, short.month, short.day).format("%02d"),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawWord(dc, short) {

        // Start Word
        var word = Configuration.NORMAL_WORD;

        // Calculate Word
        if (short.hour >= Configuration.NIGHT_TIME) {
            word = Configuration.NIGHT_WORD;
        } else if (short.hour >= Configuration.EVENING_TIME) {
            word = Configuration.EVENING_WORD;
        } else if (short.hour >= Configuration.AFTERNOON_TIME) {
            word = Configuration.AFTERNOON_WORD;
        } else if (short.hour >= Configuration.MORNING_TIME) {
            word = Configuration.MORNING_WORD;
        } else {
            word = Configuration.NIGHT_WORD;
        }

        dc.setColor(Configuration.COLOUR_DEFAULT_FOREGROUND, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            width / 2,
            coordinator_y(Configuration.SPACE_BOTTOM_TOP_ROW),
            font_writing,
            word.toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawSimpleNotification(dc, device) {

        if (device.notificationCount >= 1) {
            // Icon Compensation
            var compensationY = 0.5;

            dc.setColor(Configuration.COLOUR_DEFAULT_FOREGROUND_LPM, Graphics.COLOR_TRANSPARENT);
            dc.drawBitmap(
                halfWidth,
                height - coordinator_y(Configuration.LPM_TOP_ROW - compensationY) - (bitmap_message_size / 2.0),
                bitmap_message
            );
        }

    }

    function drawNotifications(dc, device) {

        // Get Notifications
        var notifications = device.notificationCount;

        // Normalise Big Numbers
        if (notifications > 99) {
            notifications = 99;
        }

        dc.drawBitmap(
            halfWidth - bitmap_message_size - coordinator_x(Configuration.INTERSPACE_BOTTOM_BOTTOM_ROW + Configuration.INTERSPACE_BOTTOM_BOTTOM_SKEW),
            coordinator_y(Configuration.SPACE_BOTTOM_BOTTOM_ROW) - (bitmap_message_size / 2.0),
            bitmap_message
        );

        dc.setColor(Configuration.COLOUR_DEFAULT_FOREGROUND, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            halfWidth - bitmap_message_size - coordinator_x(Configuration.INTERSPACE_BOTTOM_BOTTOM_ROW + Configuration.INTERSPACE_BOTTOM_BOTTOM_ROW_MORE + Configuration.INTERSPACE_BOTTOM_BOTTOM_SKEW),
            coordinator_y(Configuration.SPACE_BOTTOM_BOTTOM_ROW),
            font_numbers,
            notifications.format("%2d"),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawHeart(dc, heart) {

        var beats = heart;

        // Default
        var shower = " -";

        // Normalise Big Numbers
        if (beats > 999) {
            beats = 999;
        }

        // Print it
        if (beats > 0) {
            shower = beats;
        }

        dc.drawBitmap(
            halfWidth + coordinator_x(Configuration.INTERSPACE_BOTTOM_BOTTOM_ROW - Configuration.INTERSPACE_BOTTOM_BOTTOM_SKEW),
            coordinator_y(Configuration.SPACE_BOTTOM_BOTTOM_ROW) - (bitmap_pulse_size / 2.0),
            bitmap_pulse
        );

        dc.setColor(Configuration.COLOUR_DEFAULT_FOREGROUND, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            halfWidth + bitmap_pulse_size + coordinator_x(Configuration.INTERSPACE_BOTTOM_BOTTOM_ROW + Configuration.INTERSPACE_BOTTOM_BOTTOM_ROW_MORE - Configuration.INTERSPACE_BOTTOM_BOTTOM_SKEW),
            coordinator_y(Configuration.SPACE_BOTTOM_BOTTOM_ROW),
            font_numbers,
            shower,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

    }

    function drawCriticalBattery(dc, stats) {

        if (stats.battery < Configuration.BATTERY_CRITICAL && !stats.charging) {
            dc.setColor(Configuration.COLOUR_DEFAULT_FOREGROUND_LPM, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                halfWidth,
                coordinator_y(Configuration.LPM_BATTERY),
                font_writing,
                "!",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

    }

    function drawBattery(dc, stats) {

        // Data
        var battery = stats.battery;
        var charging = stats.charging;

        // Colour of insides
        var hex = null;

        // Battery Float
        var floater = battery / 100;

        // Battery Ratio
        var ratio = (Configuration.BATTERY_WIDTH * 2) * floater;

        // Charing Colour
        if (charging) {
            hex = Configuration.COLOUR_BATTERY_CHARGING;

        // Dynamic Colour
        } else {

            // Shade of the battery depending on size
            var halfColourShade = (
                (Configuration.COLOUR_BATTERY_MAX_DARK * floater) +
                Configuration.COLOUR_BATTERY_MAX_DARK
            ).toNumber();

            hex = (halfColourShade << 16) | (halfColourShade << 8) | halfColourShade;

        }

        dc.setColor(hex, Graphics.COLOR_TRANSPARENT);

        // Battery Percentage
        dc.fillRectangle(
            halfWidth - coordinator_x(Configuration.BATTERY_WIDTH),
            height - coordinator_y(Configuration.BATTERY_HEIGHT + Configuration.SPACE_BATTERY),
            coordinator_x(ratio),
            coordinator_y(Configuration.BATTERY_HEIGHT)
        );

        // Battery Width
        dc.setPenWidth(3);

        if (battery < Configuration.BATTERY_CRITICAL) {
            dc.setColor(Configuration.COLOUR_BATTERY_CRITICAL, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        }

        // Draw Box
        dc.drawRectangle(
            halfWidth - coordinator_x(Configuration.BATTERY_WIDTH),
            height - coordinator_y(Configuration.BATTERY_HEIGHT + Configuration.SPACE_BATTERY),
            coordinator_x(Configuration.BATTERY_WIDTH * 2.0),
            coordinator_y(Configuration.BATTERY_HEIGHT)
        );
        // Draw Tip
        dc.drawLine(
            halfWidth + coordinator_x(Configuration.BATTERY_WIDTH + 1.0),
            height - coordinator_y((Configuration.BATTERY_HEIGHT / 2.0) + Configuration.SPACE_BATTERY - 1.0),
            halfWidth + coordinator_x(Configuration.BATTERY_WIDTH + 1.0),
            height - coordinator_y((Configuration.BATTERY_HEIGHT / 2.0) + Configuration.SPACE_BATTERY + 1.5)
        );

    }

}