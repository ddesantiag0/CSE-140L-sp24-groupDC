// Counter that decrements from WIDTH to 0 at every positive clock edge.
// CSE140L      lab 1
module counter_down	#(parameter dw=8, WIDTH=7)
(
  input                 clk,
  input                 reset,
  input                 ena,
  output logic [dw-1:0] result);

  always @(posedge clk)
    begin
      if (reset) begin
        result <= WIDTH; //set result to WIDTH if reset is 1
      end else if (ena) begin
        result <= result - 1; //decrement result by 1 if ena is 1
      end
    end

endmodule	