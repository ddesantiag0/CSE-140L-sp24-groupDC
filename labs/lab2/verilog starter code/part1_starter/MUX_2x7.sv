// MUX_2x7.sv
module MUX_2x7(
    input logic[6:0] input0_time,
    input logic[6:0] input1_alarm,
    input logic select,  // Selects between showing time or alarm
    output logic[6:0] output_display
);

    always_comb begin
        output_display = select ? input1_alarm : input0_time;
    end

endmodule
