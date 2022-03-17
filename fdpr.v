module fdpr (
 // inputs for pipelining
 input clk,
 input rst,
 // inputs from decode
 input flush_df,
 input write_df,
 // inputs from fetch
 input [15:0] instr_fd,
 input [15:0] pcinc_fd,
 input [15:0] pcout_fd,
 // pipelinied outputs to decode
 output [15:0] instr_fdpr,
 output [15:0] pcinc_fdpr,
 output [15:0] pcout_fdpr
);

wire [15:0] pcinc;
wire [15:0] instr;
wire [15:0] instrout;

// need to ensure that dffs reset to NOP
assign instr_fdpr = rst ? 16'b00001xxxxxxxxxxx : instrout;

// need to ensure that dffs reset to NOP otherwise based on flush and write 
assign instr = (~rst & ~flush_df & write_df) ? instr_fd :
               (~rst & flush_df & write_df) ? 16'b00001xxxxxxxxxxx :
               rst ? 16'b00001xxxxxxxxxxx :
               instr_fdpr;
               
// update the pcinc depending on if 
assign pcinc = write_df ? pcinc_fd : pcinc_fdpr;

dff pcinc_pr [15:0] (.d(pcinc), .q(pcinc_fdpr), .clk(clk), .rst(rst));
dff instr_pr [15:0] (.d(instr), .q(instrout), .clk(clk), .rst(1'b0));
dff pcout_pr [15:0] (.d(pcout_fd), .q(pcout_fdpr), .clk(clk), .rst(rst));

endmodule
