`timescale 1ns / 1ps

module mv_test_bench();

parameter L_RAM_SIZE = 3;
parameter VECTOR_SIZE = 32;
parameter ROW_SIZE = 8;

reg start, aclk, aresetn;
wire bram_clk;
wire done;
wire [31:0] BRAM_ADDR;
reg [VECTOR_SIZE-1:0] BRAM_RDDATA;
wire [VECTOR_SIZE-1:0] BRAM_WRDATA; 
wire [3:0] BRAM_WE;

pearray_my #(
    .H_SIZE(3),
    .PE_DELAY(16)
) my_pe_con
(
    .start(start),
    .done(done),
    .S_AXI_ACLK(aclk),
    .S_AXI_ARESETN(aresetn),
    .BRAM_ADDR(BRAM_ADDR),
    .BRAM_WRDATA(BRAM_WRDATA),
    .BRAM_WE(BRAM_WE),
    .BRAM_CLK(bram_clk), // 180 degree shifted version of S_AXI_ACLK
    .BRAM_RDDATA(BRAM_RDDATA)
);

reg [VECTOR_SIZE-1:0] mem [(2**L_RAM_SIZE)*(ROW_SIZE+1)-1:0];

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

genvar i;

generate for(i=0; i<ROW_SIZE; i=i+1) begin
    always @(posedge aclk) begin
           BRAM_RDDATA <= mem[BRAM_ADDR>>2];
        end
    end
endgenerate

assign bram_clk = ~aclk;

always #5 aclk = ~aclk;

endmodule