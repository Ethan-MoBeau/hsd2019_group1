`timescale 1ns / 1ps

module tb_bram();

reg clk, en1, rst1, done1;
reg en2, rst2, done2;
reg [14:0] addr;
wire [31:0] rddata1, rddata2;
reg [31:0] wrdata;
reg [3:0] we1, we2;
integer i;

my_bram b1(
    .BRAM_ADDR(addr), .BRAM_CLK(clk), .BRAM_WRDATA(wrdata),
    .BRAM_RDDATA(rddata1), .BRAM_EN(en1), .BRAM_RST(rst1), .BRAM_WE(we1),
    .done(done1)
);

my_bram #(15, "", "output.txt") b2(
    .BRAM_ADDR(addr), .BRAM_CLK(clk), .BRAM_WRDATA(rddata1),
    .BRAM_RDDATA(rddata2), .BRAM_EN(en2), .BRAM_RST(rst2), .BRAM_WE(we2),
    .done(done2)
);

initial begin
    en1 = 1;
    we1 = 0;
    rst1 = 0;
    done1 = 0;
    en2 = 0;
    we2 = 0;
    rst2 = 0;
    done2 = 0;
    clk = 0;
    
    for(i=0; i<32; i=i+1) begin
        addr = 4*i;
        #20;
    end
    
    en2 = 1;
    we2 = 4'b1111;
    #20;
    
    for(i=0; i<32; i=i+1) begin
        addr = 4*i;
        #20;
    end
    
end

always #5 clk = ~clk;

endmodule
