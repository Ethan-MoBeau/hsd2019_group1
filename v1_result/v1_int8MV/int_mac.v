`timescale 1ns / 1ps

module int_mac #(
        parameter BITWIDTH = 32,
        parameter PE_DELAY = 4
    )
    (
    input clk,
    input aresetn,
    input signed [BITWIDTH-1:0] ain,
    input signed [BITWIDTH-1:0] bin,
    input valid,
    output signed [BITWIDTH-1:0] dout,
    output dvalid
    );
    
reg signed [BITWIDTH-1:0] sum;

reg signed [BITWIDTH-1:0] ain_tmp;
reg signed [BITWIDTH-1:0] bin_tmp;
reg [31:0] cnt;
reg flag;

assign dout = sum;
assign dvalid = (flag && cnt == 0);

always @(posedge clk) begin
    if(!aresetn) begin
        sum = 0;
        ain_tmp = 0;
        bin_tmp = 0;
        cnt = 0;
        flag = 0;
    end
    if(valid) begin
        ain_tmp <= ain;
        bin_tmp <= bin;
        flag <= 1;
    end
    else begin
        ain_tmp <= 0;
        bin_tmp <= 0;
    end
end

always @(posedge clk) begin
    if(flag && cnt == 0) begin
        flag = 0;
    end
    sum <= sum + ain_tmp * bin_tmp;
end

always @(posedge clk) begin
    if(valid) cnt <= PE_DELAY - 1;
    else if(flag) cnt <= cnt - 1;
    else cnt <= 0;
end

endmodule