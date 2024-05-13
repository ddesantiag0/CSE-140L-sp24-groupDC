// CSE140L  
// Enhanced counter module for varying number of days per month.
// This module can handle different lengths of months by adjusting the modulus.
// It is designed to count days within each month and reset based on the number of days specified by modulus.
module ct_mod_N (
  input             clk,
  input             rst,      // Synchronous reset of ct_out to 0
  input             en,       // Enables ct_out increment; else hold
  input       [6:0] modulus,  // Counter runs 0 to modulus-1      
  output logic[6:0] ct_out,   // Counter accumulator and output 
  output logic      ct_max    // Goes high when ct_out = modulus-1
);

  // Main counter process
  always_ff @(posedge clk) begin
    if (rst) begin
      ct_out <= 'b0;  // Reset counter to zero on reset signal
    end else if (en) begin
      if (ct_out == modulus - 1) begin
        ct_out <= 'b0;  // Reset counter when reaching the maximum value (modulus-1)
      end else begin
        ct_out <= ct_out + 'b1;  // Increment counter if enabled and not at maximum
      end
    }
    // Maintain current count if not enabled and not resetting
  end

  // Output signal to indicate maximum count reached
  always_comb begin
    ct_max = (ct_out == modulus - 1);  // Set high when current count equals modulus-1
  end

endmodule