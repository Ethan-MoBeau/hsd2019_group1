`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2019 01:18:10 PM
// Design Name: 
// Module Name: test
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


module test;

reg [31:0] a;
reg [31:0] b;
wire [31:0] adder_out;
wire [63:0] mul_out;
wire [63:0] mac_out;
reg en;
reg clk = 0;
wire over;
reg [7:0] i;

my_add adder(.ain(a), .bin(b), .dout(adder_out), .overflow(over));
my_mul multiplier(.ain(a), .bin(b), .dout(mul_out));
my_mac mul_acu(.ain(a), .bin(b), .en(en), .clk(clk), .dout(mac_out));

always begin
    #10;
    clk <= ~clk;
end

initial begin
    a = 3;
    b = 1;
    en = 0;
    #20;
    
    a=4;
    b=2;
    en = 1;
    #20;
    
    a=3;
    b=21;
    #20;
    
    for(i=1; i<32; i = i+1) begin
        a = a + i;
        b = b + i;
        #20;
    end
    
    a = 32'hffffffff;
    b = 32'hffffffff;
    
   end

endmodule

