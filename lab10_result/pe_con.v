`timescale 1ns / 1ps

module pe_con #(
    parameter ROW_SIZE = 4, // row size
    parameter VECTOR_SIZE = 16, // vector size
    parameter L_RAM_SIZE = 4
)
(
    input start,
    output done,
    input aclk,
    input aresetn,
    output [ROW_SIZE-1:0][L_RAM_SIZE:0] rdaddr ,	//address from PE
    input [ROW_SIZE-1:0][VECTOR_SIZE-1:0] rddata ,
    output reg [ROW_SIZE-1:0][VECTOR_SIZE-1:0] wrdata
);

// PE
wire [VECTOR_SIZE-1:0] ain [ROW_SIZE-1:0];
wire [VECTOR_SIZE-1:0] din [ROW_SIZE-1:0];
wire [L_RAM_SIZE-1:0] addr [ROW_SIZE-1:0];
wire we_local;	                //we for local reg in PE
wire we_global;	                //we for global reg on the outside of PE
wire valid;		                //input valid
wire dvalid;
wire [VECTOR_SIZE-1:0] dout [ROW_SIZE-1:0];

// global block ram
reg [VECTOR_SIZE-1:0] gdout [ROW_SIZE-1:0];
(* ram_style = "block" *) reg [VECTOR_SIZE-1:0] globalmem [0:2**L_RAM_SIZE-1][ROW_SIZE-1:0];

integer m;

always @(posedge aclk)
    if (we_global)
        for(m=0; m<ROW_SIZE; m=m+1)
            globalmem[addr[m]][m] = rddata[m];
    else
        for(m=0; m<ROW_SIZE; m=m+1)
            gdout[m] = globalmem[addr[m]][m];

// down counter
reg [31:0] counter;
wire [31:0] ld_val = (load_flag_en ? CNTLOAD1 : (calc_flag_en? CNTCALC1 : (done_flag_en? CNTDONE : 'd0)));

wire counter_ld = load_flag_en || calc_flag_en || done_flag_en; 
wire counter_en = load_flag || (calc_flag && dvalid) || done_flag;
wire counter_reset = !aresetn;
always @(posedge aclk)
   if (counter_reset)
       counter <= 'd0;
   else
       if (counter_ld)
           counter <= ld_val;
       else if (counter_en)
           counter <= counter - 1;
   
// FSM
// transition triggering flags
wire load_done;
wire calc_done;
wire done_done;
    
// state register
reg [3:0] curr_state, next_state;
localparam S_IDLE = 4'd0;
localparam S_LOAD = 4'd1;
localparam S_CALC = 4'd2;
localparam S_DONE = 4'd3;

//part 1: state transition
always @(*)
    if (!aresetn)
        next_state <= S_IDLE;
    else
        case (curr_state)
            S_IDLE:
                if(start == 1) next_state <= S_LOAD;
                else next_state <= curr_state;
            S_LOAD: // LOAD PERAM
                if(load_done == 1) next_state <= S_CALC;
                else next_state <= curr_state;
            S_CALC: // CALCULATE RESULT
                if(calc_done == 1) next_state <= S_DONE;
                else next_state <= curr_state;
            S_DONE:
                if(done_done == 1) next_state <= S_IDLE;
                else next_state <= curr_state;
            default:
                next_state <= S_IDLE;
        endcase

always @(posedge aclk)
    if (!aresetn)
        curr_state <= S_IDLE;
    else
        curr_state <= next_state;

//part 2: determine state
// S_LOAD
reg load_flag;
wire load_flag_reset = !aresetn || load_done; 
wire load_flag_en = (curr_state == S_IDLE) && (next_state == S_LOAD);
localparam CNTLOAD1 = (2**L_RAM_SIZE)*2-1;
always @(posedge aclk)
   if (load_flag_reset)
       load_flag <= 'd0;
   else
       if (load_flag_en)
           load_flag <= 'd1;
       else
           load_flag <= load_flag;

// S_CALC
reg calc_flag;
wire calc_flag_reset = !aresetn || calc_done;
wire calc_flag_en = (curr_state == S_LOAD) && (next_state == S_CALC);
localparam CNTCALC1 = 2**L_RAM_SIZE-1; 
always @(posedge aclk)
   if (calc_flag_reset)
       calc_flag <= 'd0;
   else
       if (calc_flag_en)
           calc_flag <= 'd1;
       else
           calc_flag <= calc_flag;

// S_DONE
reg done_flag;
wire done_flag_reset = !aresetn || done_done;
wire done_flag_en = (curr_state == S_CALC) && (next_state == S_DONE);
localparam CNTDONE = 5;
always @(posedge aclk)
   if (done_flag_reset)
       done_flag <= 'd0;
   else
       if (done_flag_en)
           done_flag <= 'd1;
       else
           done_flag <= done_flag;

//part3: update output and internal register
//S_LOAD: we
assign we_local = (load_flag && counter < (CNTLOAD1+1)/2) ? 'd1 : 'd0; // may need change
assign we_global = (load_flag && counter >= (CNTLOAD1+1)/2) ? 'd1 : 'd0; // may need change

//S_CALC: wrdata 
always @(posedge aclk)
    if (!aresetn)
        for(m=0; m<ROW_SIZE; m=m+1) begin
            wrdata[m] <= 'd0;
        end
    else
        if (calc_done)
            for(m=0; m<ROW_SIZE; m=m+1) begin
                wrdata[m] <= dout[m];
            end
        else
            for(m=0; m<ROW_SIZE; m=m+1) begin
                wrdata[m] <= wrdata[m];
            end

//S_CALC: valid
reg valid_pre, valid_reg;
always @(posedge aclk)
    if (!aresetn)
        valid_pre <= 'd0;
    else
    if (calc_flag_en || dvalid) // may need change
        valid_pre <= 'd1;
    else
        valid_pre <= 'd0;

always @(posedge aclk)
    if (!aresetn)
        valid_reg <= 'd0;
    else if (calc_flag)
        valid_reg <= valid_pre; // why is valid 2 cycle?
 
assign valid = valid_reg; // may need change

genvar j;

generate for(j=0; j<ROW_SIZE; j=j+1) begin
        assign ain[j] = calc_flag ? gdout[j] : 'd0;
        assign addr[j] = counter+j*VECTOR_SIZE;
        assign din[j] = (we_local == 1) ? rddata[j] : 'd0;
        assign rdaddr[j] = (load_flag == 1) ? (we_local ? addr[j] : addr[j]+2**L_RAM_SIZE) : 'd0;
    end
endgenerate



//done signals
assign load_done = (load_flag) && (counter == 'd0);
assign calc_done = (calc_flag) && (counter == 'd0) && dvalid;
assign done_done = (done_flag) && (counter == 'd0);
assign done = (curr_state == S_DONE) && done_done;

// pe instantiate
genvar i;

generate for(i=0; i<ROW_SIZE; i=i+1) begin:pe
        my_pe #(
           .L_RAM_SIZE(L_RAM_SIZE),
           .VECTOR_SIZE(VECTOR_SIZE)
        ) u_pe (
           .aclk(aclk),
           .aresetn(aresetn && (next_state != S_DONE)),
           .ain(ain[i]),
           .din(din[i]),
           .addr(addr[i]),
           .we(we_local),
           .valid(valid),
           .dvalid(dvalid),
           .dout(dout[i])
        );
    end
endgenerate

endmodule