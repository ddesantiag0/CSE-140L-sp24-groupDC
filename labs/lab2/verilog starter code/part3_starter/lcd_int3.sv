// Extended LCD interface module to include date and month alongside the day of the week
module lcd_int(
    input [6:0] bin_in,   // Existing binary input for hours, minutes, or seconds
    input [5:0] date_in,  // New input for the date (1-31)
    input [4:0] month_in, // New input for the month (1-12)
    input [2:0] day_in,   // New input for the day of the week (0-6)
    output logic [6:0] Segment1,  // Existing segment output for hours/minutes/seconds
    output logic [6:0] Segment0,  // Existing segment output for hours/minutes/seconds
    output logic [6:0] DateSegment1,  // New segment output for date tens
    output logic [6:0] DateSegment0,  // New segment output for date units
    output logic [6:0] MonthSegment1, // New segment output for month tens
    output logic [6:0] MonthSegment0, // New segment output for month units
    output logic [6:0] DaySegment     // New segment output for the day of the week
);

logic [3:0] bin0, bin1;            // LSD and MSD for existing digits
logic [3:0] date0, date1;          // LSD and MSD for the date
logic [3:0] month0, month1;        // LSD and MSD for the month
logic [3:0] day_bcd;               // BCD for the day of the week

// Convert binary input to BCD for hours, minutes, or seconds
assign bin0 = bin_in % 10;
assign bin1 = bin_in / 10;

// Convert date to BCD
assign date0 = date_in % 10;
assign date1 = date_in / 10;

// Convert month to BCD
assign month0 = month_in % 10;
assign month1 = month_in / 10;

// Direct assignment from day input to BCD
assign day_bcd = day_in; 

// Mapping BCD to 7-segment layout for all digits
always_comb case(bin0)
    4'b0000 : Segment0 = 7'h7E; // '0'
    4'b0001 : Segment0 = 7'h30; // '1'
    // Additional mappings...
    default : Segment0 = 7'h00; // Blank for undefined inputs
endcase

always_comb case(bin1)
    4'b0000 : Segment1 = 7'h7E; // '0'
    4'b0001 : Segment1 = 7'h30; // '1'
    // Additional mappings...
    default : Segment1 = 7'h00; // Blank for undefined inputs
endcase

always_comb case(date0)
    4'b0000 : DateSegment0 = 7'h7E; // '0'
    4'b0001 : DateSegment0 = 7'h30; // '1'
    // Additional mappings...
    default : DateSegment0 = 7'h00; // Blank for undefined inputs
endcase

always_comb case(date1)
    4'b0000 : DateSegment1 = 7'h7E; // '0'
    4'b0001 : DateSegment1 = 7'h30; // '1'
    // Additional mappings...
    default : DateSegment1 = 7'h00; // Blank for undefined inputs
endcase

always_comb case(month0)
    4'b0000 : MonthSegment0 = 7'h7E; // '0'
    4'b0001 : MonthSegment0 = 7'h30; // '1'
    // Additional mappings...
    default : MonthSegment0 = 7'h00; // Blank for undefined inputs
endcase

always_comb case(month1)
    4'b0000 : MonthSegment1 = 7'h7E; // '0'
    4'b0001 : MonthSegment1 = 7'h30; // '1'
    // Additional mappings...
    default : MonthSegment1 = 7'h00; // Blank for undefined inputs
endcase

// Mapping for the day of the week
always_comb case(day_bcd)
    3'd0 : DaySegment = 7'h7E;  // '0' - Represents Monday
    3'd1 : DaySegment = 7'h30;  // '1' - Tuesday
    3'd2 : DaySegment = 7'h6D;  // '2' - Wednesday
    3'd3 : DaySegment = 7'h79;  // '3' - Thursday
    3'd4 : DaySegment = 7'h33;  // '4' - Friday
    3'd5 : DaySegment = 7'h5B;  // '5' - Saturday
    3'd6 : DaySegment = 7'h5F;  // '6' - Sunday
    default : DaySegment = 7'h00;
endcase

endmodule