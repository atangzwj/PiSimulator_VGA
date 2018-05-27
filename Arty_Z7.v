module Arty_Z7 (
   output wire [4:1] ja_p,
   output wire [4:1] ja_n,
   output wire [3:1] jb_p,
   output wire [3:1] jb_n,
   input  wire [0:0] btn,
   input  wire       clk
);

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

   wire vidSel;
   PiSimulator_VGA pisim_vga (
      .HS(HS),
      .VS(VS),
      .vidSel(vidSel),
      .clk100(clk),
      .reset(btn[0])
   );

   busMux2_1 #(.WIDTH(4)) r_mux (
      .out(r),
      .in0(4'hC),
      .in1(4'hF),
      .sel(vidSel)
   );
   busMux2_1 #(.WIDTH(4)) g_mux (
      .out(g),
      .in0(4'hA),
      .in1(4'h0),
      .sel(vidSel)
   );
   busMux2_1 #(.WIDTH(4)) b_mux (
      .out(b),
      .in0(4'h7),
      .in1(4'h0),
      .sel(vidSel)
   );
endmodule

module busMux2_1 #(parameter WIDTH = 64) (
   output wire [WIDTH - 1 : 0] out,
   input  wire [WIDTH - 1 : 0] in0,
   input  wire [WIDTH - 1 : 0] in1,
   input  wire                 sel
);

   genvar i;
   generate
      for (i = 0; i < WIDTH; i = i + 1) begin : muxes
         mux2_1 m (.out(out[i]), .in0(in0[i]), .in1(in1[i]), .sel);
      end
   endgenerate
endmodule

module mux2_1 (
   output wire out,
   input  wire in0,
   input  wire in1,
   input  wire sel
);

   wire seln;
   not n (seln, sel);

   wire out0, out1;
   and a0 (out0, in0, seln);
   and a1 (out1, in1, sel);

   or o (out, out0, out1);
endmodule
