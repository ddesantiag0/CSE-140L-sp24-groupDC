// ECE260C -- lab 5 alternative DUT
// applies done flag when cycle_ct = 255
module top_level_5b(
  input          clk, init, 
  output logic   done);

// memory interface
  logic          wr_en;                // data memory write enable
  logic    [7:0] raddr,                // read address pointer
                 waddr,                // write address pointer
                 data_in;              // to dat_mem
  logic    [7:0] data_out;             // from dat_mem

// program counter
  logic[15:0] cycle_ct = 0;

// LFSR interface
  logic load_LFSR,                     // copy taps and start into LFSR
        LFSR_en;                       // 1: advance LFSR; 0: hold
  logic[5:0] LFSR_ptrn[6];             // the 6 possible maximal length LFSR patterns
  assign LFSR_ptrn[0] = 6'h21;
  assign LFSR_ptrn[1] = 6'h2D;
  assign LFSR_ptrn[2] = 6'h30;
  assign LFSR_ptrn[3] = 6'h33;
  assign LFSR_ptrn[4] = 6'h36;
  assign LFSR_ptrn[5] = 6'h39;
  logic[5:0] start;                    // LFSR starting state
  logic[5:0] LFSR_state[6];
  logic[5:0] match;                    // got a match for LFSR (one hot)
  logic[2:0] foundit;                  // binary index equiv. of match
  int i;

  logic[7:0] last_underscore_position = 'd8;
  logic temp = 'd0;

// instantiate submodules
// data memory -- fill in the connections
  dat_mem dm1(
    .clk(clk), 
    .write_en(wr_en), 
    .raddr(raddr), 
    .waddr(waddr),
    .data_in(data_in), 
    .data_out(data_out)
  );

// instantiate LFSR submodules
  lfsr6b l0(
    .clk(clk), 
    .en(LFSR_en),                  // 1: advance LFSR on rising clk
    .init(load_LFSR),              // 1: initialize LFSR
    .taps(6'h21),                  // tap pattern 0
    .start(start),                 // starting state for LFSR
    .state(LFSR_state[0])
  );

  lfsr6b l1(
    .clk(clk), 
    .en(LFSR_en),                  // 1: advance LFSR on rising clk
    .init(load_LFSR),              // 1: initialize LFSR
    .taps(6'h2D),                  // tap pattern 1
    .start(start),                 // starting state for LFSR
    .state(LFSR_state[1])
  );

  lfsr6b l2(
    .clk(clk), 
    .en(LFSR_en),                  // 1: advance LFSR on rising clk
    .init(load_LFSR),              // 1: initialize LFSR
    .taps(6'h30),                  // tap pattern 2
    .start(start),                 // starting state for LFSR
    .state(LFSR_state[2])
  );

  lfsr6b l3(
    .clk(clk), 
    .en(LFSR_en),                  // 1: advance LFSR on rising clk
    .init(load_LFSR),              // 1: initialize LFSR
    .taps(6'h33),                  // tap pattern 3
    .start(start),                 // starting state for LFSR
    .state(LFSR_state[3])
  );

  lfsr6b l4(
    .clk(clk), 
    .en(LFSR_en),                  // 1: advance LFSR on rising clk
    .init(load_LFSR),              // 1: initialize LFSR
    .taps(6'h36),                  // tap pattern 4
    .start(start),                 // starting state for LFSR
    .state(LFSR_state[4])
  );

  lfsr6b l5(
    .clk(clk), 
    .en(LFSR_en),                  // 1: advance LFSR on rising clk
    .init(load_LFSR),              // 1: initialize LFSR
    .taps(6'h39),                  // tap pattern 5
    .start(start),                 // starting state for LFSR
    .state(LFSR_state[5])
  );

// priority encoder
  always_comb begin
    case(match)
      6'b10_0000: foundit = 'd5;         // because bit [5] was set
      6'b01_0000: foundit = 'd4;         // because bit [4] was set
      6'b00_1000: foundit = 'd3;         // because bit [3] was set
      6'b00_0100: foundit = 'd2;         // because bit [2] was set
      6'b00_0010: foundit = 'd1;         // because bit [1] was set
      default   : foundit =   0;         // covers bit[0] match and no match cases
    endcase
  end

// program counter and main logic
  always @(posedge clk) begin : clock_loop
    if(init) begin
      cycle_ct <= 'b0;
      match    <= 'b0;
    end else begin
      cycle_ct <= cycle_ct + 1;

      if (cycle_ct == 8) begin              // last symbol of preamble
        for (i = 0; i < 6; i++) begin
          match[i] <= ((data_out ^ 8'h5f) == {2'b00, LFSR_state[i]});   // which LFSR state conforms to our test bench LFSR? 
        end
      end
    end
  end  

// control logic
  always_comb begin 
    // defaults
    load_LFSR = 'b0; 
    LFSR_en   = 'b0;   
    wr_en     = 'b0;
    raddr     = 'b0;
    waddr     = 'b0;
    start     = 'b0;
    done      = 'b0;
    data_in   = 'b0;

    // Break down cycle_ct cases
    case(cycle_ct)
      0: begin 
        // Step 1: Initialize raddr and waddr
        raddr = 64;                // starting address for encrypted data to be loaded into device
        waddr = 'd0;               // starting address for storing decrypted results into data mem
      end
      1: begin 
        // Step 2: Load LFSR and set start
        load_LFSR = 'b1;           // initialize the 6 LFSRs
        raddr = 64;
        start = 8'h5f ^ data_out;
      end
      2: begin 
        // Step 3: Enable LFSR
        LFSR_en = 'b1;             // advance the 6 LFSRs     
        raddr = 64;
        waddr = 'd0;
      end
      3: begin 
        // Step 4: Training sequence
        LFSR_en = 'b1;
        raddr = 64 + cycle_ct - 2; // advance raddr
        waddr = 'd0;
      end
      72: begin
        // Step 5: Done
        done = 'b1;                // send acknowledge back to test bench to halt simulation
        raddr = 'd0;
        waddr = 'd0; 
      end
      default: begin
        // Covers cycle_ct 4-71
        if(cycle_ct <= 8) begin
          // Step 6: Turn on write enable if within first 8 cycles
          LFSR_en = 'b1;
          raddr = 64 + cycle_ct - 2;
          waddr = 'd0;
        end else begin
          // Step 7: Normal operation
          LFSR_en = 'b1;
          raddr = 64 + cycle_ct - 2;
          data_in = data_out ^ {2'b00, LFSR_state[foundit]};
          
          // Step 8: Check underscore position
          if (last_underscore_position == cycle_ct - 1) begin
            if (data_in == 8'h5f) begin
              temp = 'b1;
            end
          end

          // Step 9: Update write enable and address
          if (last_underscore_position != cycle_ct) begin
            wr_en = 'b1;
            waddr = cycle_ct - last_underscore_position - 1;
          end  
        end
      end
    endcase
  end
endmodule
