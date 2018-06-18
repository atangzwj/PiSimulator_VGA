module Arty_Z7 (
   output wire [4:1] ja_p,
   output wire [4:1] ja_n,
   output wire [3:1] jb_p,
   output wire [3:1] jb_n,
   input  wire [1:0] sw,
   input  wire [0:0] btn,
   input  wire       clk
);

   wire reset;
   assign reset = btn[0];

   // Generate 25MHz clock for VGA controller
   // Generate 10MHz clock to be divided for LFSRs
   wire clk25, clk10;
   clk_wiz_0 clk_wiz (
      .clk_out1(clk25),
      .clk_out2(clk10),
      .reset(reset),
      .locked(),
      .clk_in1(clk)
   );

   // Pmod Connections
   wire [3:0] r;
   wire [3:0] g;
   wire [3:0] b;
   wire       HS, VS;

   assign ja_p[1] = r[0];
   assign ja_n[1] = r[1];
   assign ja_p[2] = r[2];
   assign ja_n[2] = r[3];
   assign ja_p[3] = g[0];
   assign ja_n[3] = g[1];
   assign ja_p[4] = g[2];
   assign ja_n[4] = g[3];

   assign jb_p[1] = b[0];
   assign jb_n[1] = b[1];
   assign jb_p[2] = b[2];
   assign jb_n[2] = b[3];
   assign jb_p[3] = HS;
   assign jb_n[3] = VS;

   // VGA controller
   wire [9:0] px_x, px_y;
   wire vidSel;
   PiSimulator_VGA pisim_vga (
      .HS(HS),
      .VS(VS),
      .px_x(px_x),
      .px_y(px_y),
      .vidSel(vidSel),
      .clk25(clk25),
      .reset(reset)
   );

   // Divide 10MHz clock for slow clock for LFSRs
   reg [15:0] clk_div;
   reg  [3:0] en, en_delay;
   wire [3:0] en_wide;
   assign en_wide = en | en_delay; // en_wide is twice the width of en, which is
                                   // the length of clk_lfsr's period
   wire clk_lfsr;
   assign clk_lfsr = clk_div[0]; // 5 MHZ
   always @ (posedge clk10) begin
      if (reset) clk_div <= 21'b0;
      else       clk_div <= clk_div + 1'b1;

      if (clk_div == 16'h8000)       en[0] <= 1'b1; // 152.59 Hz
      else                           en[0] <= 1'b0;

      if (clk_div[13:0] == 14'h2000) en[1] <= 1'b1; // 610.35 Hz
      else                           en[1] <= 1'b0;

      if (clk_div[11:0] == 12'h800)  en[2] <= 1'b1; // 2.441 kHz
      else                           en[2] <= 1'b0;

      if (clk_div[9:0] == 10'h200)   en[3] <= 1'b1; // 9.765 kHz
      else                           en[3] <= 1'b0;

      en_delay <= en;
   end

   wire en_lfsr;
   mux4_1 enableSelector (.out(en_lfsr), .in(en_wide), .sel(sw));

   // 18-bit LFSR
   wire  [8:0] randX, randY;
   wire [17:0] seed, q;
   assign randX = q[17:9];
   assign randY = q[8:0];
   assign seed  = 18'h0_AACC;
   lfsr18 lfsr (
      .q(q),
      .seed(seed),
      .enable(en_lfsr),
      .clk(clk_lfsr),
      .reset(reset)
   );

   reg [9:0] px_y_inv; // Invert image across horizontal axis
   always @ (*) begin
      px_y_inv = 10'd480 - px_y;
   end

   // Pixel memory for image storage
   wire color;
   pixelMemory px_mem (
      .color(color),
      .readX(px_x),
      .readY(px_y_inv),
      .writeX(randX),
      .writeY(randY),
      .wrEnable(1'b1),
      .clk(clk25)
   );

   wire isInside;
   circleChecker cc (.isInside(isInside), .xCoord(px_x), .yCoord(px_y_inv));

   reg [3:0] rSel;
   reg [3:0] gSel;
   reg [3:0] bSel;
   always @ (*) begin
      if (isInside) begin
         if (color) begin
            rSel = 4'hF; // Points inside circle are set to red
            gSel = 4'h0;
            bSel = 4'h0;
         end else begin
            rSel = 4'hC; // Gray circle
            gSel = 4'hC;
            bSel = 4'hC;
         end
      end else begin
         if (color && px_x <= 480) begin
            rSel = 4'h0; // Points outside circle and within the circle's
            gSel = 4'hF; // enclosing square are set to green
            bSel = 4'h0;
         end else begin
            rSel = 4'h0; // All other points outside circle are black
            gSel = 4'h0;
            bSel = 4'h0;
         end
      end
   end

   busMux2_1 #(.WIDTH(4)) r_mux (
      .out(r),
      .in0(4'h0),
      .in1(rSel),
      .sel(vidSel)
   );
   busMux2_1 #(.WIDTH(4)) g_mux (
      .out(g),
      .in0(4'h0),
      .in1(gSel),
      .sel(vidSel)
   );
   busMux2_1 #(.WIDTH(4)) b_mux (
      .out(b),
      .in0(4'h0),
      .in1(bSel),
      .sel(vidSel)
   );
endmodule
