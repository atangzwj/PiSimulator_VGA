module Arty_Z7 (
   output wire [4:1] ja_p,
   output wire [4:1] ja_n,
   output wire [4:1] jb_p,
   output wire [4:1] jb_n,
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
   assign jb_p[4] = 1'b0;
   assign jb_n[4] = 1'b0;
endmodule
