// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
// Lab 2 Part 2
// Includes day of the week tracking and conditional alarm disabling
module Top_Level #(parameter NS=60, NH=24, ND=7)( // Added ND for number of days
  input Reset,
        Timeset,       // manual buttons
        Alarmset,      // (five total)
        Minadv,
        Hrsadv,
        Dayadv,        // Advance the day
        Alarmon,
        Pulse,         // digital clock, assume 1 cycle/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp,     // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
               D0disp,            // Added day display for part 2
  output logic Buzz);             // alarm sounds
// internal connections (may need more)
  logic[6:0] TSec, TMin, THrs, TDay;  // Added TDay for current day tracking
  logic[6:0] AMin, AHrs, ADay;       // Added ADay for alarm day setting
  logic[6:0] Min, Hrs, Day;          // Added Day for display output
  logic S_max, M_max, H_max, D_max;  // Added D_max for day roll over
  logic TMen, THen, AMen, AHen, DEn; // Added DEn for enabling day setting

// (almost) free-running seconds counter
  ct_mod_N  Sct(
    .clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(NS),
    .ct_out(TSec), .ct_max(S_max));

// minutes counter -- runs at either 1/sec while being set or 1/60sec normally
  ct_mod_N Mct(
    .clk(Pulse), .rst(Reset), .en(TMen || S_max), .modulus(60),
    .ct_out(TMin), .ct_max(M_max));

// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N Hct(
    .clk(Pulse), .rst(Reset), .en(THen || M_max), .modulus(24),
    .ct_out(THrs), .ct_max(H_max));

// Day counter -- Added to track the day of the week
  ct_mod_N Dct(
    .clk(Pulse), .rst(Reset), .en(Dayadv || H_max), .modulus(ND),
    .ct_out(TDay), .ct_max(D_max));

// alarm set registers -- either hold or advance 1/sec while being set
  ct_mod_N Mreg(
    .clk(Pulse), .rst(Reset), .en(AMen), .modulus(60),
    .ct_out(AMin), .ct_max());

  ct_mod_N Hreg(
    .clk(Pulse), .rst(Reset), .en(AHen), .modulus(24),
    .ct_out(AHrs), .ct_max());

  ct_mod_N Dreg(  // Added for setting the alarm day
    .clk(Pulse), .rst(Reset), .en(DEn), .modulus(ND),
    .ct_out(ADay), .ct_max());

// MUX for selecting display hours: current or alarm
  MUX_2x7 hours_mux(
    .input0_time(THrs),
    .input1_alarm(AHrs),
    .select(Alarmset),
    .output_display(Hrs));

// MUX for selecting display minutes: current or alarm
  MUX_2x7 minutes_mux(
    .input0_time(TMin),
    .input1_alarm(AMin),
    .select(Alarmset),
    .output_display(Min));

// Display drivers (2 digits each, 6 digits total, plus 1 digit for day)
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

  lcd_int Ddisp(  // Added display for the day of the week
    .bin_in(TDay),
    .Segment0(D0disp));

// Alarm logic including day checking
  alarm a1(
    .tmin(TMin), .amin(AMin),
    .thrs(THrs), .ahrs(AHrs),
    .tday(TDay), .aday(ADay),
    .buzz(Buzz));

endmodule