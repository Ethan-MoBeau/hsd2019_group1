module my_pe #(
        parameter VECTOR_SIZE = 32,
        parameter L_RAM_SIZE = 4
    )
    (
        // clk/reset
        input aclk,
        input aresetn,        
        // port A
        input [VECTOR_SIZE-1:0] ain,        
        // peram -> port B 
        input [VECTOR_SIZE-1:0] din,
        input [L_RAM_SIZE-1:0]  addr,
        input we,        
        // integrated valid signal
        input valid,        
        // computation result
        output dvalid,
        output [VECTOR_SIZE-1:0] dout  
    );

    wire avalid = valid;
    wire bvalid = valid;
    wire cvalid = valid;
    // peram: PE's local RAM -> Port B
    reg [VECTOR_SIZE-1:0] bin;
    (* ram_style = "block" *) reg [VECTOR_SIZE-1:0] peram [0:2**L_RAM_SIZE - 1];
        always @(posedge aclk)
            if (we)
                peram[addr] <= din;
            else
                bin <= peram[addr];
        
        reg [VECTOR_SIZE-1:0] dout_fb;
        always @(posedge aclk)
            if (!aresetn)
                dout_fb <= 'd0;
            else
                if (dvalid)
                    dout_fb <= dout;
                else
                    dout_fb <= dout_fb;
        
        floating_point_0 u_float_dsp (
            .aclk             (aclk),
            .aresetn          (aresetn),
            .s_axis_a_tvalid  (avalid),
            .s_axis_a_tdata   (ain),
            .s_axis_b_tvalid  (bvalid),
            .s_axis_b_tdata   (bin),
            .s_axis_c_tvalid  (cvalid),
            //.s_axis_c_tdata   (sreg[FLOATDELAY-1]),
            .s_axis_c_tdata   (dout_fb),
            .m_axis_result_tvalid (dvalid),
            .m_axis_result_tdata  (dout)
       );
       
    endmodule

 