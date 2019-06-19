`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2017 09:43:59 PM
// Design Name: 
// Module Name: pe_my
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


module pe_my #(
        parameter L_RAM_SIZE = 3
    )
    (
        // clk/reset
        input aclk,
        input aresetn,
        
        // port A
        input signed [31:0] ain,
        
        // peram -> port B 
        input signed [31:0] din,
        input [L_RAM_SIZE-1:0]  addr,
        input we,
        
        // integrated valid signal
        input valid,
        
        // computation result
        output dvalid,
        output signed [31:0] dout
    );

    // peram: PE's local RAM -> Port B
    reg signed [31:0] bin;
    (* ram_style = "block" *) reg signed [31:0] peram [0:2**L_RAM_SIZE - 1];
    always @(posedge aclk)
        if (we)
            peram[addr] <= din;
        else
            bin <= peram[addr];
    
    int_mac my_int_mac_0 (
        .aresetn(aresetn),
        .clk(aclk),
        .ain(ain),
        .bin(bin),
        .valid(valid),
        .dout(dout),
        .dvalid(dvalid)
    );
   
endmodule