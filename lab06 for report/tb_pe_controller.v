`timescale 1ns / 1ps

module tb_pe_controller();

parameter L_RAM_SIZE = 4;
parameter VECTOR_SIZE = 32; 

reg start, aclk, aresetn;
wire done;
wire [L_RAM_SIZE-1:0] rdaddr;
reg [VECTOR_SIZE-1:0] rddata;
wire [VECTOR_SIZE-1:0] wrdata;

pe_con #(VECTOR_SIZE, L_RAM_SIZE) my_pe_con
(
    .start(start),
    .done(done),
    .aclk(aclk),
    .aresetn(aresetn),
    .rdaddr(rdaddr),
    .rddata(rddata),
    .wrdata(wrdata)
);

reg [VECTOR_SIZE-1:0] mem [2**L_RAM_SIZE-1:0];

initial begin
    $readmemh("din.txt", mem);
    aclk = 0;
    aresetn = 0;
    start = 0;
    #10;
    aresetn = 1;
    start = 1;
    #10;
    start = 0;
end

always @(posedge aclk) begin
    rddata = mem[rdaddr];
end

always #5 aclk = ~aclk;

endmodule
