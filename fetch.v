module fetch (
 // inputs for writing
 input clk,
 input rst,
 // halt from memory
 input halt_mf,
 // inputs from decode
 input pcwrite_df,
 input pcsel_df, 
 input [15:0] pcaddrsel_df,
 // outputs to decode
 output [15:0] instr_fd,
 output [15:0] pcinc_fd,
 output [15:0] pcout_fd
);

wire [15:0] pcsrc;
wire [15:0] pcinp;
wire [15:0] pcout;

assign pcsrc = pcsel_df ? pcaddrsel_df : pcinc_fd;
assign pcinp = pcwrite_df ? pcsrc : pcout;
assign pcout_fd = pcout;

r16 pc0 [15:0] (.Inp(pcinp), .clk(clk), .rst(rst), .Out(pcout));
fulladder16 fa0 (.A(16'h0002), .B(pcout), .S(pcinc_fd), .Cout());
memory2c im0 (.data_out(instr_fd), .data_in(16'h0000), .addr(pcout), .enable(~halt_mf), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));

endmodule
