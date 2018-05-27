module PiSimulator_VGA (
   output wire HS,
   output wire VS,
   output wire vidSel,
   input  wire clk100,
   input  wire reset
);

   // Clock divider
   reg [1:0] clk_div;
   always @ (posedge clk100) begin
      if (reset) clk_div <= 2'b0;
      else       clk_div <= clk_div + 1'b1;
   end

   wire clk25;
   assign clk25 = clk_div[1];

   wire [9:0] hCount, vCount;
   wire       tc_h, tc_v;

   wire horizCountReset, vertCountReset;
   assign horizCountReset = reset | tc_h;
   assign vertCountReset = reset | (tc_h & tc_v);
   VGAcounter #(.TERMINAL_COUNT(799)) horizCount (
      .q(hCount),
      .tc(tc_h),
      .en(clk25),
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

   VGAcomparator horizComp (.lt(HS), .a(hCount), .b(10'd96));
   VGAcomparator vertComp (.lt(VS), .a(vCount), .b(10'd2));

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
      .clk100(clk),
      .reset(reset)
   );

   parameter CLK_PER = 10;
   initial begin
      clk <= 1;
      forever #(CLK_PER / 2) clk <= ~clk;
   end

   initial begin
      reset <= 0; @(posedge clk);
      reset <= 1; @(posedge clk);
      reset <= 0; @(posedge clk);
      repeat (1680400) @(posedge clk);
      $stop;
   end
endmodule
