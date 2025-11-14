module WeekNumber {

    // Cache
    var cache = null;
    var value = null;


    // Methods
    function weekNumber(year, month, day) {

        var comparator = [year, month, day];

        // Check cache
        if (cache != comparator) {
            value = isoWeekNumber(year, month, day);
            cache = comparator;
        }

        return value;
    }


    function julianDay(year, month, day) {
        var a = (14 - month) / 12;
        var y = (year + 4800 - a);
        var m = (month + 12 * a - 3);
        return day + ((153 * m + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045;
    }

    function isLeapYear(year) {
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

    function isoWeekNumber(year, month, day) {

        // Get Firsts
        var first_day_of_year = julianDay(year, 1, 1);
        var given_day_of_year = julianDay(year, month, day);

        var day_of_week = (first_day_of_year + 3) % 7;
        var week_of_year = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;

        // End or Beginning
        if (week_of_year == 53) {
            if (day_of_week == 6) {
                return week_of_year;
            }
            else if (day_of_week == 5 && isLeapYear(year)) {
                return week_of_year;
            }
            else {
                return 1;
            }
        }
        // Previous Year
        else if (week_of_year == 0) {
            first_day_of_year = julianDay(year - 1, 1, 1);
            day_of_week = (first_day_of_year + 3) % 7;
            return (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
        }
        // Old Week
        else {
            return week_of_year;
        }

    }

}