// Garmin
using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application.Properties;

// Watch Face Class
class WatchView extends WatchUi.WatchFace {

    /**********
     * States *
     **********/

    // Cache
    var acquired = false;

    // Low Power Mode
    var lpm = false;

    /******************
     * Initialisation *
     ******************/

    // Constructor
    function initialize() {
        WatchFace.initialize();
        initialiseStart();
    }

    // Power Modes
    function onEnterSleep() { lpm = true;  }
    function onExitSleep()  { lpm = false; }

    // Updates
    function onPartialUpdate(dc) {
        onUpdate(dc);
    }
    function onUpdate(dc) {
        View.onUpdate(dc);
        initialiseOnce(dc);
        if (!lpm) { myUpdate(dc);    }
        else      { myLPMUpdate(dc); }
    }

    function initialiseStart() {
        Drawing.initialiseStart();
    }

    function initialiseOnce(dc) {
        // Only run once at the start
        if (!acquired) {
            // Cache sizes
            Drawing.initialise(dc.getWidth(), dc.getHeight());
            // Update flag
            acquired = true;
        }

    }

    /***********
     * Updates *
     ***********/

    function myLPMUpdate(dc) {

        // Needed
        var stats = System.getSystemStats();
        var device = System.getDeviceSettings();

        // Generally Used
        var moment = Time.now();
        var clock = System.getClockTime();
        var short = Gregorian.info(moment, Time.FORMAT_SHORT);

        // Time
        Drawing.drawTime(dc, short, true);
        Drawing.drawSecondsTimezone(dc, null, clock, true);
        // Date
        Drawing.drawDate(dc, short, true);
        // Week
        Drawing.drawWeek(dc, short, true);
        // Notifications
        Drawing.drawSimpleNotification(dc, device);
        // Battery
        Drawing.drawCriticalBattery(dc, stats);

    }

    function myUpdate(dc) {

        /*
         * Setup
         */

        // Time
        var moment = Time.now();
        var clock = System.getClockTime();
        var short = Gregorian.info(moment, Time.FORMAT_SHORT);

        // Weather
        // var conditions = Weather.getCurrentConditions();

        // Activity
        var info = Activity.getActivityInfo();

        // Device
        var stats = System.getSystemStats();
        var device = System.getDeviceSettings();

        // Own
        var heart = Getters.getHeart(info);

        /*
         * Draw
         */

        // Base Color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Separations
        if (!Properties.getValue("FlatBackground")) {
            Drawing.rectangleEdge(dc, false, false, Configuration.BOX_EDGE_SIZE, Configuration.BOX_EDGE_TOP, Configuration.BOX_EDGE_BOTTOM);
            Drawing.rectangleSeparation(dc, 0, Configuration.BOX_REACH_TOP);
            Drawing.rectangleSeparation(dc, Configuration.BOX_REACH_BOTTOM, Configuration.BOX_BATTERY_OFFSET);
        }

        // Time
        Drawing.drawTime(dc, short, false);
        Drawing.drawSecondsTimezone(dc, short, clock, false);

        // Date
        Drawing.drawDate(dc, short, false);

        // Week
        Drawing.drawWeek(dc, short, false);

        // Battery
        Drawing.drawBattery(dc, stats);

        // Word
        Drawing.drawWord(dc, short);

        // Notifications
        Drawing.drawNotifications(dc, device);

        // Heart
        Drawing.drawHeart(dc, heart);

    }

}
