// CSE140L  
// See Structural Diagram in Lab2 assignment writeup
// Lab 2 Part 2: Includes day of the week tracking and conditional alarm disabling
module Top_Level #(parameter NS=60, NH=24, ND=7)( // ND for number of days in a week
  input Reset,
        Timeset,       // Manual buttons for setting time
        Alarmset,      // Button for setting alarm
        Minadv,
        Hrsadv,
        Dayadv,        // Button to advance the day
        Alarmon,
        Pulse,         // Digital clock pulse, assume 1 cycle/sec
  output [6:0] S1disp, S0disp,     // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
               D0disp,            // Display for the day of the week
  output logic Buzz                // Alarm output
);

// Internal signals for tracking time and day
logic [6:0] TSec, TMin, THrs, TDay;  // Current time and day
logic [6:0] AMin, AHrs, ADay;       // Alarm settings for time and day
logic [6:0] Min, Hrs, Day;          // Display outputs for time and day
logic S_max, M_max, H_max, D_max;   // Flags for maximum count reached in counters
logic TMen, THen, AMen, AHen, DEn;  // Enable signals for manual setting

// Define counters for seconds, minutes, hours, and day of the week
ct_mod_N Sct(
    .clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(NS),
    .ct_out(TSec), .ct_max(S_max));

ct_mod_N Mct(
    .clk(Pulse), .rst(Reset), .en(TMen || S_max), .modulus(60),
    .ct_out(TMin), .ct_max(M_max));

ct_mod_N Hct(
    .clk(Pulse), .rst(Reset), .en(THen || M_max), .modulus(24),
    .ct_out(THrs), .ct_max(H_max));

ct_mod_N Dct(
    .clk(Pulse), .rst(Reset), .en(Dayadv || H_max), .modulus(ND),
    .ct_out(TDay), .ct_max(D_max));

// Define registers for alarm settings
ct_mod_N Mreg(
    .clk(Pulse), .rst(Reset), .en(AMen), .modulus(60),
    .ct_out(AMin));

ct_mod_N Hreg(
    .clk(Pulse), .rst(Reset), .en(AHen), .modulus(24),
    .ct_out(AHrs));

ct_mod_N Dreg(  // For setting the alarm day
    .clk(Pulse), .rst(Reset), .en(DEn), .modulus(ND),
    .ct_out(ADay));

// Multiplexers for selecting display values based on settings
MUX_2x7 hours_mux(
    .input0_time(THrs),
    .input1_alarm(AHrs),
    .select(Alarmset),
    .output_display(Hrs));

MUX_2x7 minutes_mux(
    .input0_time(TMin),
    .input1_alarm(AMin),
    .select(Alarmset),
    .output_display(Min));

// Display drivers for each segment
lcd_int Sdisp(
    .bin_in(TSec),
    .Segment1(S1disp),
    .Segment0(S0disp));

lcd_int Mdisp(
    .bin_in(TMin),
    .Segment1(M1disp),
    .Segment0(M0disp));

lcd_int Hdisp(
    .bin_in(THrs),
    .Segment1(H1disp),
    .Segment0(H0disp));

lcd_int Ddisp(  // Display driver for the day of the week
    .bin_in(TDay),
    .Segment0(D0disp));

// Alarm logic to handle buzzing based on day and time match conditions
alarm a1(
    .tmin(TMin), .amin(AMin),
    .thrs(THrs), .ahrs(AHrs),
    .tday(TDay), .aday(ADay),
    .buzz(Buzz));

endmodule