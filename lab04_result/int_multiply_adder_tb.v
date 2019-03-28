`timescale 1ns / 1ps

module int_multiply_adder_tb();

reg [32-1:0] ain;
reg [32-1:0] bin;
reg [64-1:0] cin;
wire [64-1:0] res;
wire [47:0] pcout;

integer i;

initial begin
    for(i=0; i<32; i=i+1) begin
        ain = $urandom%(2**31);
        bin = $urandom%(2**31);
        cin = $urandom%(2**63);
        #20;
    end
end

int_multiply_adder my_int_mac(
    .A(ain),
    .B(bin),
    .C(cin),
    .SUBTRACT(1'b0),
    .P(res),
    .PCOUT(pcout)
);
    

endmodule
