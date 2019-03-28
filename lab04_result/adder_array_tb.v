`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2019 10:24:10 AM
// Design Name: 
// Module Name: adder_array_tb
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

module adder_array_tb;
    reg [2:0] cmd;
    reg [31:0] ain0, ain1, ain2, ain3, bin0, bin1, bin2, bin3;
    wire [31:0] dout0, dout1, dout2, dout3;
    wire [3:0] overflow;
    
    
adder_array my_adder(
    .cmd(cmd), 
    .ain0(ain0), .ain1(ain1), .ain2(ain2), .ain3(ain3), 
    .bin0(bin0), .bin1(bin1), .bin2(bin2), .bin3(bin3), 
    .dout0(dout0), .dout1(dout1), .dout2(dout2), .dout3(dout3), 
    .overflow(overflow)
 );
   
integer i;
initial begin
    cmd <= 0;
    for(i=0; i<4; i=i+1) begin
        ain0 = $urandom%(2**31);
        bin0 = $urandom%(2**31);
        ain1 = $urandom%(2**31);
        bin1 = $urandom%(2**31);
        ain2 = $urandom%(2**31);
        bin2 = $urandom%(2**31);
        ain3 = $urandom%(2**31);
        bin3 = $urandom%(2**31);
        #20;
    end
    
    cmd <= 1;
    for(i=0; i<4; i=i+1) begin
        ain0 = $urandom%(2**31);
        bin0 = $urandom%(2**31);
        ain1 = $urandom%(2**31);
        bin1 = $urandom%(2**31);
        ain2 = $urandom%(2**31);
        bin2 = $urandom%(2**31);
        ain3 = $urandom%(2**31);
        bin3 = $urandom%(2**31);
        #20;
    end
    
    cmd <= 2;
    for(i=0; i<4; i=i+1) begin
        ain0 = $urandom%(2**31);
        bin0 = $urandom%(2**31);
        ain1 = $urandom%(2**31);
        bin1 = $urandom%(2**31);
        ain2 = $urandom%(2**31);
        bin2 = $urandom%(2**31);
        ain3 = $urandom%(2**31);
        bin3 = $urandom%(2**31);
        #20;
    end
    
    cmd <= 3;
    for(i=0; i<4; i=i+1) begin
        ain0 = $urandom%(2**31);
        bin0 = $urandom%(2**31);
        ain1 = $urandom%(2**31);
        bin1 = $urandom%(2**31);
        ain2 = $urandom%(2**31);
        bin2 = $urandom%(2**31);
        ain3 = $urandom%(2**31);
        bin3 = $urandom%(2**31);
        #20;
    end
    
    cmd <= 4;
    for(i=0; i<4; i=i+1) begin
        ain0 = $urandom%(2**31);
        bin0 = $urandom%(2**31);
        ain1 = $urandom%(2**31);
        bin1 = $urandom%(2**31);
        ain2 = $urandom%(2**31);
        bin2 = $urandom%(2**31);
        ain3 = $urandom%(2**31);
        bin3 = $urandom%(2**31);
        #20;
    end
    
    ain0 = 32'hf0000000;
    bin0 = 32'hf0000000;
    ain1 = 32'hf0000000;
    bin1 = 32'hf0000000;
    ain2 = 32'hf0000000;
    bin2 = 32'hf0000000;
    ain3 = 32'hf0000000;
    bin3 = 32'hf0000000;
    #20;
    
end

    
endmodule
