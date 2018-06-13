module lfsr (
   output reg  [8:0] q,
   input  wire [7:0] seed,
   input  wire       clk,
   input  wire       reset
);
   wire [7:0] rand8, seed8;
   wire [6:0] rand7, seed7;
   wire [5:0] rand6, seed6;
   wire [4:0] rand5, seed5;

   assign seed8 = seed;
   assign seed7 = seed[6:0];
   assign seed6 = seed[5:0];
   assign seed5 = seed[4:0];

   lfsr8 lfsr8_inst (.q(rand8), .seed(seed8), .clk(clk), .reset(reset));
   lfsr7 lfsr7_inst (.q(rand7), .seed(seed7), .clk(clk), .reset(reset));
   lfsr6 lfsr6_inst (.q(rand6), .seed(seed6), .clk(clk), .reset(reset));
   lfsr5 lfsr5_inst (.q(rand5), .seed(seed5), .clk(clk), .reset(reset));

   // Generate random numbers from 0 to 472
   always @ (posedge clk) begin
      q = rand8 + rand7 + rand6 + rand5;
   end
endmodule

module lfsr8 (
   output wire [7:0] q,
   input  wire [7:0] seed,
   input  wire       clk,
   input  wire       reset
);

   wire [7:0] d, muxIn0;
   xnor xn0 (muxIn0[0], q[3], q[4], q[5], q[7]); // LFSR taps
   assign muxIn0[7:1] = q[6:0];
   genvar i;
   generate
      for (i = 0; i < 8; i = i + 1) begin
         mux2_1 mux (.out(d[i]), .in0(muxIn0[i]), .in1(seed[i]), .sel(reset));
         d_ff dff (.q(q[i]), .d(d[i]), .clk(clk), .reset(reset));
      end
   endgenerate
endmodule

module lfsr7 (
   output wire [6:0] q,
   input  wire [6:0] seed,
   input  wire       clk,
   input  wire       reset
);

   wire [6:0] d, muxIn0;
   xnor xn0 (muxIn0[0], q[6], q[5]); // LFSR taps
   assign muxIn0[6:1] = q[5:0];
   genvar i;
   generate
      for (i = 0; i < 7; i = i + 1) begin
         mux2_1 mux (.out(d[i]), .in0(muxIn0[i]), .in1(seed[i]), .sel(reset));
         d_ff dff (.q(q[i]), .d(d[i]), .clk(clk), .reset(reset));
      end
   endgenerate
endmodule

module lfsr6 (
   output wire [5:0] q,
   input  wire [5:0] seed,
   input  wire       clk,
   input  wire       reset
);
   wire [5:0] d, muxIn0;
   xnor xn0 (muxIn0[0], q[5], q[4]); // LFSR taps
   assign muxIn0[5:1] = q[4:0];
   genvar i;
   generate
      for (i = 0; i < 6; i = i + 1) begin
         mux2_1 mux (.out(d[i]), .in0(muxIn0[i]), .in1(seed[i]), .sel(reset));
         d_ff dff (.q(q[i]), .d(d[i]), .clk(clk), .reset(reset));
      end
   endgenerate
endmodule

module lfsr5 (
   output wire [4:0] q,
   input  wire [4:0] seed,
   input  wire       clk,
   input  wire       reset
);

   wire [4:0] d, muxIn0;
   xnor xn0 (muxIn0[0], q[4], q[2]); // LFSR taps
   assign muxIn0[4:1] = q[3:0];
   genvar i;
   generate
      for (i = 0; i < 5; i = i + 1) begin
         mux2_1 mux (.out(d[i]), .in0(muxIn0[i]), .in1(seed[i]), .sel(reset));
         d_ff dff (.q(q[i]), .d(d[i]), .clk(clk), .reset(reset));
      end
   endgenerate
endmodule

module d_ff (
   output reg  q,
   input  wire d,
   input  wire clk,
   input  wire reset
);

   always @ (posedge clk) begin
      if (reset) q <= 0;
      else       q <= d;
   end
endmodule

module lfsr_testbench ();
   wire [8:0] q;
   reg        clk, reset;

   lfsr dut (.q(q), .clk(clk), .reset(reset));

   parameter CLK_PER = 10;
   initial begin
      clk <= 1;
      forever #(CLK_PER / 2) clk <= ~clk;
   end

   initial begin
      reset <= 1; @(posedge clk);
      reset <= 0; @(posedge clk);
      repeat(24)  @(posedge clk);
      $stop;
   end
endmodule
