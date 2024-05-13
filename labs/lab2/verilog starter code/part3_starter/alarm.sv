// CSE140L lab 2 part 3
// Extended to include day of week, date, and month functionality.
// This module checks alarm conditions based on time, day, date, and potentially month.
module alarm(
    input [6:0] tmin,   // Current minute
                amin,   // Alarm minute
                thrs,   // Current hour
                ahrs,   // Alarm hour
                tday,   // Current day of the week
                aday,   // Alarm day of the week
    input [5:0] tdate,  // Current date
                adate,  // Alarm date
                tmonth, // Current month
                amonth, // Alarm month
    output logic buzz   // Alarm signal
);

// Enhanced alarm condition checks for time, day, date, and month.
// Uses defaults to ignore date and month if not set (e.g., `6'd63`).
always_comb begin
    // Check if the current time matches alarm time.
    // Check if the current day is not the alarm day nor the day after the alarm day.
    // Optionally check if the current date and month match the alarm settings,
    // unless those fields are set to a default ignore value (`6'd63`).
    buzz = (tmin == amin) && (thrs == ahrs) && 
           (tday != aday) && (tday != (aday + 1) % 7) &&
           ((adate == 6'd63) || (tdate == adate)) &&  // Ignore date if adate is 6'd63
           ((amonth == 6'd63) || (tmonth == amonth)); // Ignore month if amonth is 6'd63
end

endmodule