module MUX_2x7(
    input logic[6:0] input0_a, // First input of the first pair
    input logic[6:0] input1_a, // Second input of the first pair
    input logic[6:0] input0_b, // First input of the second pair
    input logic[6:0] input1_b, // Second input of the second pair
    input logic select_a,      // Selector for the first pair
    input logic select_b,      // Selector for the second pair
    output logic[6:0] output_a, // Output for the first pair
    output logic[6:0] output_b  // Output for the second pair
);

    // Implementing selection for the first pair
    always_comb begin
        output_a = select_a ? input1_a : input0_a;
    end

    // Implementing selection for the second pair
    always_comb begin
        output_b = select_b ? input1_b : input0_b;
    end

endmodule