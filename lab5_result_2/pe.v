`timescale 1ns / 1ps

module my_pe #(
    parameter L_RAM_SIZE = 6
    )(
    // clk/reset
    input aclk,
    input aresetn,
    // port A
    input [31:0] ain,
    // peram -> port B
    input [31:0] din,
    input [L_RAM_SIZE-1:0] addr,
    input we,
    // integrated valid signal
    input valid,
    // computation result
    output dvalid,
    output [31:0] dout
);

(* ram_style = "block" *) reg [31:0] peram [0:2**L_RAM_SIZE-1]; // local register
reg [31:0] res;

reg [31:0] bin;
integer i;

fp_mac my_fp_mac(
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_a_tvalid(valid), 
    .s_axis_b_tvalid(valid),
    .s_axis_c_tvalid(valid),
    .s_axis_a_tdata(ain),
    .s_axis_b_tdata(bin),
    .s_axis_c_tdata(res), // mac operation
    .m_axis_result_tvalid(dvalid),
    .m_axis_result_tdata(dout)
);

initial begin
    res = 0;
end

always @(posedge aclk) begin
    if(aresetn == 0) begin
        for(i=0; i<2**L_RAM_SIZE; i=i+1) peram[i] = 0;
    end
    else begin
        if(we == 1) peram[addr] = din;
        else bin = peram[addr];// one of input of MAC
    end
end

always @(negedge dvalid) begin
    res = dout;
end

endmodule
