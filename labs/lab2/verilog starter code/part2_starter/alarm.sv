// CSE140 lab 2  
// Extended to include day of week functionality.
// How does this work? How long does the alarm stay on? 
// (buzz is the alarm itself)
module alarm(
    input[6:0]   tmin,  // current minute
                 amin,  // alarm minute
                 thrs,  // current hour
                 ahrs,  // alarm hour
                 tday,  // current day of week
                 aday,  // alarm day
    output logic buzz
);

always_comb begin
    // The alarm should not trigger on the alarm day or the day after (aday + 1) % 7.
    // Additionally, it checks the current time and alarm time match.
    if ((tmin == amin) && (thrs == ahrs) && (tday != aday) && (tday != (aday + 1) % 7))
        buzz = 1'b1;
    else
        buzz = 1'b0;
end

endmodule