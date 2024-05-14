// CSE140 lab 2 part 3
// Extended to include day of week, date, and month functionality.
// This module checks alarm conditions based on time, day, date, and potentially month.
module alarm(
    input[6:0]   tmin,  // current minute
                 amin,  // alarm minute
                 thrs,  // current hour
                 ahrs,  // alarm hour
                 tday,  // current day of week
                 aday,  // alarm day of week
    input[5:0]   tdate, // current date
                 adate, // alarm date
                 tmonth,// current month
                 amonth,// alarm month
    output logic buzz
);

always_comb begin
    // Enhanced alarm condition checks for time, day, date, and month.
    // Uses defaults to ignore date and month if not set (e.g., `6'd63`).
    buzz = (tmin == amin) && (thrs == ahrs) && 
           (tday != aday) && (tday != (aday + 1) % 7) &&
           ((adate == 6'd63) || (tdate == adate)) &&  // Checks if adate is set to a default ignore value
           ((amonth == 6'd63) || (tmonth == amonth)); // Checks if amonth is set to a default ignore value
end

endmodule