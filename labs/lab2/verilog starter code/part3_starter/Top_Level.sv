// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
// Lab 2 Part 3
// Includes day of the week tracking, conditional alarm disabling, and month/date functionality
module Top_Level #(
    parameter NS=60, NH=24, ND=7, NM=12, NDM=31  // Constants for time, day, month, and date handling
)(
    input Reset,
    input Timeset,       // Manual buttons for setting time
    input Alarmset,      // Button for setting alarm
    input Minadv,
    input Hrsadv,
    input Dayadv,        // Button to advance day
    input MonthAdv,      // Button to advance month
    input DateAdv,       // Button to advance date
    input Alarmon,
    input Pulse,         // Clock pulse, assuming 1 cycle/sec

    output [6:0] S1disp, S0disp,     // 2-digit seconds display
    output [6:0] M1disp, M0disp, 
    output [6:0] H1disp, H0disp,
    output [6:0] D0disp,            // Display for day of the week
    output [6:0] MonthDisp,         // Month display (added)
    output [6:0] DateDisp,          // Date display (added)
    output logic Buzz               // Alarm output
);

// Internal signals for time, alarm, and displays
logic [6:0] TSec, TMin, THrs, TDay, TMonth, TDate;  
logic [6:0] AMin, AHrs, ADay, AMonth, ADate;       
logic [6:0] Min, Hrs, Day, Month, Date;           
logic S_max, M_max, H_max, D_max, Mo_max, Da_max; // Max signals for each counter
logic TMen, THen, AMen, AHen, DEn, MoEn, DaEn;    // Enable signals for manual setting

// Definitions for time counters (seconds, minutes, hours, and days)
ct_mod_N Sct(.clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(NS), .ct_out(TSec), .ct_max(S_max));
ct_mod_N Mct(.clk(Pulse), .rst(Reset), .en(TMen || S_max), .modulus(60), .ct_out(TMin), .ct_max(M_max));
ct_mod_N Hct(.clk(Pulse), .rst(Reset), .en(THen || M_max), .modulus(24), .ct_out(THrs), .ct_max(H_max));
ct_mod_N Dct(.clk(Pulse), .rst(Reset), .en(Dayadv || H_max), .modulus(ND), .ct_out(TDay), .ct_max(D_max));

// Alarm setting registers
ct_mod_N Mreg(.clk(Pulse), .rst(Reset), .en(AMen), .modulus(60), .ct_out(AMin));
ct_mod_N Hreg(.clk(Pulse), .rst(Reset), .en(AHen), .modulus(24), .ct_out(AHrs));

// New month and date counters for tracking and setting
ct_mod_N Moct(.clk(Pulse), .rst(Reset), .en(MonthAdv || Da_max), .modulus(NM), .ct_out(TMonth), .ct_max(Mo_max));
ct_mod_N Dact(.clk(Pulse), .rst(Reset), .en(DateAdv || Mo_max), .modulus(NDM), .ct_out(TDate), .ct_max(Da_max));

// Multiplexers for selecting display outputs
MUX_2x7 hours_mux(.input0_time(THrs), .input1_alarm(AHrs), .select(Alarmset), .output_display(Hrs));
MUX_2x7 minutes_mux(.input0_time(TMin), .input1_alarm(AMin), .select(Alarmset), .output_display(Min));

// Display drivers for time and new date features
lcd_int Sdisp(.bin_in(TSec), .Segment1(S1disp), .Segment0(S0disp));
lcd_int Mdisp(.bin_in(TMin), .Segment1(M1disp), .Segment0(M0disp));
lcd_int Hdisp(.bin_in(THrs), .Segment1(H1disp), .Segment0(H0disp));
lcd_int Ddisp(.bin_in(TDay), .Segment0(D0disp)); // Display for day of the week
lcd_int MonthDispModule(.bin_in(TMonth), .Segment0(MonthDisp)); // Display for month
lcd_int DateDispModule(.bin_in(TDate), .Segment0(DateDisp)); // Display for date

// Alarm logic with extended functionality
alarm a1(
    .tmin(TMin), .amin(AMin), 
    .thrs(THrs), .ahrs(AHrs), 
    .tday(TDay), .aday(ADay),
    .buzz(Buzz)
);

endmodule