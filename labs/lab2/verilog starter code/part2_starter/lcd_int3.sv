// Extended LCD interface module to include day of the week
module lcd_int(
  input [6:0] bin_in,  // Existing binary input for hours, minutes, or seconds
  input [2:0] day_in,  // New input for the day of the week (0-6)
  output logic [6:0] Segment1,  // Existing segment output
  output logic [6:0] Segment0,  // Existing segment output
  output logic [6:0] DaySegment // New segment output for the day of the week
);

logic [3:0] bin0; // LSD for existing digits
logic [3:0] bin1; // MSD for existing digits
logic [3:0] day_bcd; // BCD for the day of the week

// Convert binary input to BCD (existing functionality)
assign bin0 = bin_in % 10;  // mod10 for LSD
assign bin1 = bin_in / 10;  // divide by 10 for MSD

// Map day of the week directly to BCD
assign day_bcd = day_in; // Direct assignment as day_in should already be 0-6

// Mapping BCD to 7-segment layout for existing digits
always_comb case(bin0) 
    4'b0000 : Segment0 = 7'h7E;
    4'b0001 : Segment0 = 7'h30;
    4'b0010 : Segment0 = 7'h6D;                  
    4'b0011 : Segment0 = 7'h79;                  
    4'b0100 : Segment0 = 7'h33;                    
    4'b0101 : Segment0 = 7'h5B;
    4'b0110 : Segment0 = 7'h5F;
    4'b0111 : Segment0 = 7'h70;
    4'b1000 : Segment0 = 7'h7F;
    4'b1001 : Segment0 = 7'h7B;
    default : Segment0 = 7'h00;
endcase

always_comb case(bin1)
    4'b0000 : Segment1 = 7'h7E;
    4'b0001 : Segment1 = 7'h30;
    4'b0010 : Segment1 = 7'h6D;
    4'b0011 : Segment1 = 7'h79;
    4'b0100 : Segment1 = 7'h33;
    4'b0101 : Segment1 = 7'h5B;
    4'b0110 : Segment1 = 7'h5F;
    4'b0111 : Segment1 = 7'h70;
    4'b1000 : Segment1 = 7'h7F;
    4'b1001 : Segment1 = 7'h7B;
    default : Segment1 = 7'h00;
endcase

// New segment mapping for the day of the week
always_comb case(day_bcd)
    3'd0 : DaySegment = 7'h7E;  // Represents '0' - Monday
    3'd1 : DaySegment = 7'h30;  // '1' - Tuesday
    3'd2 : DaySegment = 7'h6D;  // '2' - Wednesday
    3'd3 : DaySegment = 7'h79;  // '3' - Thursday
    3'd4 : DaySegment = 7'h33;  // '4' - Friday
    3'd5 : DaySegment = 7'h5B;  // '5' - Saturday
    3'd6 : DaySegment = 7'h5F;  // '6' - Sunday
    default : DaySegment = 7'h00;
endcase

endmodule
