using Toybox.Graphics;

module Configuration {

    /***********
     * Generic *
     ***********/

    // Battery Critical Level
    const BATTERY_CRITICAL = 10;

    /********
     * Data *
     ********/

    // Timezones
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

    // Weekdays
    const WEEK_DAYS = {
        1 => "SUN",
        2 => "MON",
        3 => "TUE",
        4 => "WED",
        5 => "THU",
        6 => "FRI",
        7 => "SAT"
    };

    // Times
    const MORNING_TIME = 6;
    const AFTERNOON_TIME = 12;
    const EVENING_TIME = 18;
    const NIGHT_TIME = 22;
    // Related Words
    const MORNING_WORD = "Morning";
    const AFTERNOON_WORD = "Afternoon";
    const EVENING_WORD = "Evening";
    const NIGHT_WORD = "Night";
    const NORMAL_WORD = "Day";

    // Colours
    const COLOURS = {
        0 => 0x1A1A1A,
        1 => 0x300000,
        2 => 0x301000,
        3 => 0x003000,
        4 => 0x000030,
        5 => 0x100030
    };

    /**********
     * Visual *
     **********/

    // === Meta === //

    // Steps in a screen, regardless of pixels
    const STEP = 100.0;

    // === Fonts === //

    const FONT_SCALABLE = ["RobotoCondensedRegular", "NotoSansSCMedium"];

    const FONT_WRITING = Graphics.FONT_SYSTEM_SMALL;
    const FONT_TIMEZONE = Graphics.FONT_SYSTEM_SMALL;
    const FONT_NUMBERS = Graphics.FONT_GLANCE_NUMBER;
    const FONT_WATCH = Graphics.FONT_SYSTEM_NUMBER_HOT;
    const FONT_WATCH_SECONDS = Graphics.FONT_GLANCE_NUMBER;

    // === Colours === //

    const COLOUR_DEFAULT_FOREGROUND = Graphics.COLOR_WHITE;  // 0xFFFFFF
    const COLOUR_DEFAULT_FOREGROUND_LPM = 0xEAEAEA;

    const COLOUR_DEFAULT_BACKGROUND = Graphics.COLOR_BLACK;  // 0x000000

    const COLOUR_BATTERY_CHARGING = 0x20B020;
    const COLOUR_BATTERY_CRITICAL = 0xB02020;
    const COLOUR_BATTERY_MAX_DARK = 0xFF / 2;

    // === Sizes === //

    // Reference
    const REFERENCE_SIZE = 416.0;

    // Battery
    const BATTERY_WIDTH = 10;
    const BATTERY_HEIGHT = 6;

    // Lines
    const LINE_WIDTH = 3.0;

    // Fonts
    var FONT_SIZE_WRITING = 36;
    var FONT_SIZE_TIMEZONE = 32;
    var FONT_SIZE_NUMBERS = 36;
    var FONT_SIZE_WATCH = 112;
    var FONT_SIZE_WATCH_SECONDS = 36;

    // === Spacing === //

    /*---- Normal -----*\
    |                   |
    |    TOP_TOP_ROW    |
    |  TOP_BOTTOM_ROW   |
    |                   |
    |  BOTTOM_TOP_ROW   |
    | BOTTOM_BOTTOM_ROW |
    |                   |
    |      BATTERY      |
    \*-----------------*/

    /*------ LPM ------*\
    |                   |
    |    LPM_TOP_ROW    |
    |                   |
    |  LPM_BOTTOM_ROW   |
    |                   |
    |      BATTERY      |
    \*-----------------*/

    // === Normal === //

    // Top Top
    const SPACE_TOP_TOP_ROW = 13.0;
    const INTERSPACE_TOP_TOP_ROW = 7.0;

    // Top Bottom
    const SPACE_TOP_BOTTOM_ROW = 28.0;

    // Bottom Top
    const SPACE_BOTTOM_TOP_ROW = 100 - 30.0;

    // Bottom Bottom
    const SPACE_BOTTOM_BOTTOM_ROW = 100 - 17.0;
    const INTERSPACE_BOTTOM_BOTTOM_ROW = 3.0 / 2;
    const INTERSPACE_BOTTOM_BOTTOM_ROW_MORE = 3.0;
    const INTERSPACE_BOTTOM_BOTTOM_SKEW = 4.0;

    // Battery
    const SPACE_BATTERY = 1.5;

    // === LPM === //

    const LPM_TOP_ROW = 23.0;
    const LPM_BOTTOM_ROW = 100.0 - LPM_TOP_ROW;

    const LPM_BATTERY = 100.0 - 5.0;

    // === Boxes === //

    // Battery Space
    const BOX_BATTERY_OFFSET = 100.0 - 10.0;

    // Reach of Boxes
    const BOX_REACH_TOP = 36.0;
    const BOX_REACH_BOTTOM = 100.0 - BOX_REACH_TOP;

    // Edge Box
    const BOX_EDGE_SIZE = 18.0;
    const BOX_EDGE_TOP = 51.0;
    const BOX_EDGE_BOTTOM = BOX_REACH_BOTTOM - 2.0;

    // === Seconds === //

    const SPACE_SECONDS_EDGE = 10.0;
    const SPACE_SECONDS_VERTICAL = 5.0;

    const SPACE_SECONDS_TIMEZONE = 1.0;

    // === Generic === //

    const OFFSET_MAIN_TIME = 10;



}