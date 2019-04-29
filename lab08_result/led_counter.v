`timescale 1ns / 1ps

module LED_CNT(
        input res,
        input clk,
        output reg [7:0] LD
    );
    
    reg [27:0] counter;
    reg clk_1sec;
    
    initial begin
        counter = 5*10**7;
        LD = 0;
        clk_1sec = 0;
    end;
    
    always @(posedge clk) begin
        counter = counter - 1;
        if(counter == 0) begin
            counter = 5*10**7;
            clk_1sec = ~clk_1sec;
        end
    end
    
    always @(posedge clk_1sec) begin
        if(res) LD = 0;
        else begin
            if(LD == 2**8-1) LD = 0;
            LD = LD + 1;
        end
    end
endmodule