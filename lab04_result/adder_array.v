`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2019 10:08:31 AM
// Design Name: 
// Module Name: adder_array
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder_array(cmd, ain0, ain1, ain2, ain3, bin0, bin1, bin2, bin3, dout0, dout1, dout2, dout3, overflow);

input [2:0] cmd;
input [31:0] ain0, ain1, ain2, ain3;
input [31:0] bin0, bin1, bin2, bin3;
output [31:0] dout0, dout1, dout2, dout3;
output [3:0] overflow;

wire [31:0] ain[3:0], bin[3:0];
wire [31:0] dout[3:0];

assign {ain[3], ain[2], ain[1], ain[0]} = {ain3, ain2, ain1, ain0};
assign {bin[3], bin[2], bin[1], bin[0]} = {bin3, bin2, bin1, bin0};
assign dout3 = cmd == 3 || cmd == 4 ? dout[3] : 32'b0;
assign dout2 = cmd == 2 || cmd == 4 ? dout[2] : 32'b0;
assign dout1 = cmd == 1 || cmd == 4 ? dout[1] : 32'b0;
assign dout0 = cmd == 0 || cmd == 4 ? dout[0] : 32'b0;

genvar i;
generate for (i=0; i<4; i = i+1)
    begin
       assign {overflow[i], dout[i]} = ain[i] + bin[i];
       
end endgenerate



endmodule
