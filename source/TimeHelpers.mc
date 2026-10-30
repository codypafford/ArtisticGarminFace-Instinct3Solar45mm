import Toybox.Lang;

module TimeHelpers {
       function getFormattedTime(clockTime) {
        // Calculate 12-hour format
        var hour12 = clockTime.hour;
        var isPm = false;
        if (hour12 > 12) {
            hour12 -= 12;
            isPm = true;
        } else if (hour12 == 0) {
            hour12 = 12;
        }
                
        // Format string (e.g., "3:05 PM")
        var timeString = Lang.format("$1$:$2$", [
            hour12,
            clockTime.min.format("%02d")
        ]);

        var amPm = isPm ? "PM" : "AM";
        
        return [timeString, amPm];
    }
}