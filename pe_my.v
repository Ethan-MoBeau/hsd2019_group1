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
        input [7:0] ain,
        
        // peram -> port B 
        input [7:0] din,
        input [L_RAM_SIZE-1:0]  addr,
        input we,
        
        // integrated valid signal
        input valid,
        
        // computation result
        output reg dvalid,
        output [15:0] dout
    );

    wire avalid = valid;
    wire bvalid = valid;
    wire cvalid = valid;
    wire [47:0] pcout;
    
    // peram: PE's local RAM -> Port B
    reg [7:0] bin;
    (* ram_style = "block" *) reg [7:0] peram [0:2**L_RAM_SIZE - 1];
    always @(posedge aclk)
        if (we)
            peram[addr] <= din;
        else
            bin <= peram[addr];
    
    reg [15:0] dout_fb;
    always @(posedge aclk) begin
        if (dout != dout_fb)
            dvalid = 1'b1;
        if (!aresetn)
            dout_fb <= 'd0;
        else
            if (dvalid) begin
                dout_fb <= dout;
            end
            else
                dout_fb <= dout_fb; 
    end
    
    xbip_multadd_0 multi_add (
        .A(ain),
        .B(bin),
        .C(dout_fb),
        .SUBTRACT(1'b0),
        .P(dout),
        .PCOUT(pcout)
   );
   
endmodule
