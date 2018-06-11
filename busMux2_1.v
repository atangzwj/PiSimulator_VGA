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