module PiSimulator_VGA (
   output wire       HS,
   output wire       VS,
   output wire [9:0] px_x,
   output wire [9:0] px_y,
   output wire       vidSel,
   input  wire       clk25,
   input  wire       reset
);

   wire [9:0] hCount, vCount;
   wire       tc_h, tc_v;

   assign px_x = hCount - 10'd144;
   assign px_y = vCount - 10'd35;

   wire horizCountReset, vertCountReset;
   assign horizCountReset = reset | tc_h;
   assign vertCountReset = reset | (tc_h & tc_v);
   VGAcounter #(.TERMINAL_COUNT(799)) horizCount (
      .q(hCount),
      .tc(tc_h),
      .en(1'b1),
      .clk(clk25),
      .reset(horizCountReset)
   );
   VGAcounter #(.TERMINAL_COUNT(524)) vertCount (
      .q(vCount),
      .tc(tc_v),
      .en(tc_h),
      .clk(clk25),
      .reset(vertCountReset)
   );

   wire HSn, VSn;
   VGAcomparator horizComp (.lt(HSn), .a(hCount), .b(10'd96));
   VGAcomparator vertComp (.lt(VSn), .a(vCount), .b(10'd2));
   assign HS = ~HSn;
   assign VS = ~VSn;

   wire ltHorizLow, ltHorizHigh;
   VGAcomparator horizLowCheck (.lt(ltHorizLow), .a(hCount), .b(10'd144));
   VGAcomparator horizHighCheck (.lt(ltHorizHigh), .a(hCount), .b(10'd784));

   wire ltVertLow, ltVertHigh;
   VGAcomparator vertLowCheck (.lt(ltVertLow), .a(vCount), .b(10'd35));
   VGAcomparator vertHighCheck (.lt(ltVertHigh), .a(vCount), .b(10'd515));

   assign vidSel = ~ltHorizLow & ltHorizHigh & ~ltVertLow & ltVertHigh;
endmodule

module PiSimulator_VGA_testbench ();
   wire HS, VS, vidSel;
   reg  clk, reset;

   PiSimulator_VGA dut (
      .HS(HS),
      .VS(VS),
      .vidSel(vidSel),
      .clk25(clk),
      .reset(reset)
   );

   parameter CLK_PER = 40;
   initial begin
      clk <= 1;
      forever #(CLK_PER / 2) clk <= ~clk;
   end

   initial begin
      reset <= 1; @(posedge clk);
      reset <= 0; @(posedge clk);
      repeat (1680400) @(posedge clk);
      $stop;
   end
endmodule
