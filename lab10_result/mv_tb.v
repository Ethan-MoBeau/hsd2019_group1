`timescale 1ns / 1ps

module mv_test_bench();

parameter L_RAM_SIZE = 4;
parameter VECTOR_SIZE = 32;
parameter ROW_SIZE = 4;

reg start, aclk, aresetn;
wire done;
wire [(L_RAM_SIZE+1)*ROW_SIZE-1:0] rdaddr;
reg [VECTOR_SIZE*ROW_SIZE-1:0] rddata;
wire [VECTOR_SIZE*ROW_SIZE-1:0] wrdata;

pe_con #(ROW_SIZE, VECTOR_SIZE, L_RAM_SIZE) my_pe_con
(
    .start(start),
    .done(done),
    .aclk(aclk),
    .aresetn(aresetn),
    .rdaddr(rdaddr),
    .rddata(rddata),
    .wrdata(wrdata)
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
            if(rdaddr[(i+1)*(L_RAM_SIZE+1)-1:i*(L_RAM_SIZE+1)]<2**L_RAM_SIZE) begin
                rddata[(i+1)*VECTOR_SIZE-1:i*VECTOR_SIZE] = mem[(2**(L_RAM_SIZE))*i+rdaddr[(i+1)*(L_RAM_SIZE+1)-1:i*(L_RAM_SIZE+1)]];
            end
            else rddata[(i+1)*VECTOR_SIZE-1:i*VECTOR_SIZE] = mem[(2**(L_RAM_SIZE))*ROW_SIZE+rdaddr[3:0]];
        end
    end
endgenerate

always #5 aclk = ~aclk;

endmodule