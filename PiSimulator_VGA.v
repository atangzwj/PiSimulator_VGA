module PiSimulator_VGA (
   input wire clk100;
   input wire reset;
);

   // Clock divider
   reg [1:0] clk_div;
   always @ (posedge clk100) begin
      clk_div <= clk_div + 1'b1;
   end

   wire clk25;
   assign clk25 = clk_div[1];

   wire [9:0] hCount, vCount;
   wire       tc_h, tc_v;

   wire vertCountReset;
   assign vertCountReset = tc_h & tc_v;
   VGAcounter horizCount #(.TERMINAL_COUNT(799)) (
      .q(hCount),
      .tc(tc_h),
      .en(clk25),
      .clk(clk25),
      .reset(tc_h)
   );
   VGAcounter vertCount #(.TERMINAL_COUNT(524)) (
      .q(vCount),
      .tc(tc_v),
      .en(tc),
      .clk(clk25),
      .reset(vertCountReset)
   );

   wire HS, VS;
   VGAcomparator horizComp (.lt(HS), .a(hCount), .b(10'd96));
   VGAcomparator vertComp (.lt(VS), .a(vCount), .b(10'd2));

   wire ltHorizLow, ltHorizHigh;
   VGAcomparator horizLowCheck (.lt(ltHorizLow), .a(hCount), .b(10'd96));
   VGAcomparator horizHighCheck (.lt(ltHorizHigh), .a(hCount), .b(10'd784));

   wire ltVertLow, ltVertHigh;
   VGAcomparator vertLowCheck (.lt(ltVertLow), .a(vCount), .b(10'd2));
   VGAcomparator vertHighCheck (.lt(ltVertHigh), .a(vCount), .b(10'd515));

   wire vidSel;
   assign vidSel = ~ltHorizLow & ltHorizHigh & -ltVertLow & ltVertHigh;
endmodule
