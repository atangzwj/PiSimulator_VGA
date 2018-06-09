module pixelMemory (
   output reg  [3:0] color,
   input  wire [9:0] readX,
   input  wire [9:0] readY,
   input  wire [9:0] writeX,
   input  wire [9:0] writeY,
   input  wire [3:0] wrColor,
   input  wire       wrEnable,
   input  wire       clk
);

   parameter
   FRAME_WIDTH  = 640,
   FRAME_HEIGHT = 480;

   reg [3:0] px_color [FRAME_WIDTH * FRAME_HEIGHT - 1 : 0];

   wire [19:0] readAddr, writeAddr;
   assign readAddr = readY * FRAME_WIDTH + readX;
   assign writeAddr = writeY * FRAME_WIDTH + writeX;

   always @ (*) begin
      color = px_color[readAddr];
   end

   always @ (posedge clk) begin
      if (wrEnable)
         px_color[writeAddr] = wrColor;
   end
endmodule

module pixelMemory_testbench ();
   wire [3:0] color;
   reg  [9:0] readX, readY, writeX, writeY;
   reg  [3:0] wrColor;
   reg        wrEnable;
   reg        clk;

   pixelMemory dut (
      .color(color),
      .readX(readX),
      .readY(readY),
      .writeX(writeX),
      .writeY(writeY),
      .wrColor(wrColor),
      .wrEnable(wrEnable),
      .clk(clk)
   );

   parameter CLK_PER = 10;
   initial begin
      clk <= 1;
      forever #(CLK_PER / 2) clk <= ~clk;
   end

   integer i, j;
   initial begin
      wrEnable <= 1; @(posedge clk);
      for (i = 0; i < 12; i = i + 1) begin
         for (j = 0; j < 12; j = j + 1) begin
            writeX <= i; writeY <= j; wrColor <= ~(i & 4'hF); @(posedge clk);
         end
      end
      wrEnable <= 0; @ (posedge clk);

      for (i = 0; i < 12; i = i + 1) begin
         for (j = 0; j < 12; j = j + 1) begin
            readX <= i; readY <= j; @(posedge clk);
         end
      end
      $stop;
   end
endmodule
