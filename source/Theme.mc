using Toybox.Graphics;
using Toybox.Application.Properties;

// For checking the theming

module Theme {

    // Check for the dark mode
    function isDarkModeEnabled() {
        var darkMode = Properties.getValue("DarkMode");
        return darkMode == null ? true : darkMode;
    }

    // --- Getters --- //

    function getForegroundColour(lpm) {
        if (isDarkModeEnabled()) {
            return lpm ? Configuration.COLOUR_DEFAULT_FOREGROUND_LPM : Configuration.COLOUR_DEFAULT_FOREGROUND;
        }

        return lpm ? Configuration.COLOUR_INVERTED_FOREGROUND_LPM : Configuration.COLOUR_INVERTED_FOREGROUND;
    }

    function getBackgroundColour() {
        return isDarkModeEnabled() ? Configuration.COLOUR_DEFAULT_BACKGROUND : Configuration.COLOUR_INVERTED_BACKGROUND;
    }

    // --- Helpers --- //

    function getBatteryFillColour(battery, charging) {

        // Charing Colour
        if (charging) {
            return Configuration.COLOUR_BATTERY_CHARGING;
        }

        // Battery Float
        var floater = battery / 100;

        // Dynamic Colour
        if (Theme.isDarkModeEnabled()) {

            // Shade of the battery depending on size
            var halfColourShade = (
                (Configuration.COLOUR_BATTERY_MAX_DARK * floater) +
                Configuration.COLOUR_BATTERY_MAX_DARK
            ).toNumber();

            return (halfColourShade << 16) | (halfColourShade << 8) | halfColourShade;
        }

        // Shade of the battery depending on size
        var halfColourShade = (
            Configuration.COLOUR_BATTERY_MAX_DARK * (1.0 - floater)
        ).toNumber();

        return (halfColourShade << 16) | (halfColourShade << 8) | halfColourShade;
    }

}
