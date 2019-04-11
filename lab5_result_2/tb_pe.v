`timescale 1ns / 1ps

module tb_pe();

reg aclk, aresetn;
reg [31:0] ain, din;
reg [5:0] addr;
reg we, valid;
wire dvalid;
wire [31:0] dout;
integer i;

my_pe pe1(
    .aclk(aclk), .aresetn(aresetn),
    .ain(ain), .din(din), .addr(addr),
    .we(we), .valid(valid), .dvalid(dvalid),
    .dout(dout)
);

initial begin
    aclk = 0;
    aresetn = 0;
    valid = 0;
    #10;
    aresetn = 1;
    we = 1;
    
    for(i=0 ; i<=15 ; i=i+1) begin
        addr = i;
        din = 32'h3f800000 + i*(2**23);
        #64;
    end
    
    we = 0;
    valid = 1;
    addr = 0;
    ain = 32'h3f800000 + addr*(2**23);
    #5;
    valid = 0;
    
end

always @(negedge dvalid) begin
    addr = addr + 1;
    #5;
    valid = 1;
    ain = 32'h3f800000 + addr*(2**23);
    #5;
    valid = 0;
end

always #2 aclk = ~aclk;

endmodule
