module pixelMemory (
   output reg        color,
   input  wire [9:0] readX,
   input  wire [9:0] readY,
   input  wire [8:0] writeX,
   input  wire [8:0] writeY,
   input  wire       wrEnable,
   input  wire       clk
);

   parameter
   FRAME_WIDTH  = 10'd640,
   FRAME_HEIGHT = 10'd480;

   reg px_color [FRAME_WIDTH * FRAME_HEIGHT - 1 : 0];

   wire [18:0] readAddr, writeAddr;
   assign readAddr = readY * FRAME_WIDTH + readX;
   assign writeAddr = writeY * FRAME_WIDTH + writeX;

   always @ (*) begin
      color = px_color[readAddr];
   end

   always @ (posedge clk) begin
      if (wrEnable)
         px_color[writeAddr] <= 1'b1;
   end
endmodule

module pixelMemory_testbench ();
   wire       color;
   reg  [9:0] readX, readY;
   reg  [8:0] writeX, writeY;
   reg        wrEnable;
   reg        clk;

   pixelMemory dut (
      .color(color),
      .readX(readX),
      .readY(readY),
      .writeX(writeX),
      .writeY(writeY),
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
            writeX <= i; writeY <= j; @(posedge clk);
         end
      end
      wrEnable <= 0; @ (posedge clk);

      for (i = 0; i < 12; i = i + 1) begin
         if (i == 6) begin
            writeX <= 12; writeY <= 12; wrEnable <= 1;
         end
         for (j = 0; j < 12; j = j + 1) begin
            readX <= i; readY <= j; @(posedge clk);
         end
         wrEnable <= 0;
      end
      readX <= 24; readY <= 24; @(posedge clk);
      readX <= 12; readY <= 12; @(posedge clk);
      $stop;
   end
endmodule
