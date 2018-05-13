module VGAcounter #(TERMINAL_COUNT = 799) (
   output wire [9:0] q,
   output wire       tc,
   input  wire       en,
   input  wire       clk,
   input  wire       reset
);

   assign tc = q == TERMINAL_COUNT;

   always @ (posedge clk) begin
      if (reset)   q <= 10'b0;
      else if (en) q <= q + 1'b1;
   end
endmodule

module VGAcounter_testbench ();
   wire [9:0] q_h, q_v;
   wire       tc;
   reg        clk;
   wire       reset;

   wire h_reset, v_reset;

   assign reset_h = reset | (q_h == 10'd799);
   assign reset_v = reset | (q_v == 10'524);

   VGAcounter count_h (
      .q(q_h), 
      .tc(tc), 
      .en(clk), 
      .clk(clk), 
      .reset(reset_h)
   );
   VGAcounter count_v (
      .q(q_v),
      .tc(),
      .en(tc),
      .clk(clk),
      .reset(reset_v)
   );

   parameter CLK_PER = 10;
   initial begin
      clk <= 1;
      forever #(CLK_PER / 2) clk <= ~clk;
   end
endmodule
