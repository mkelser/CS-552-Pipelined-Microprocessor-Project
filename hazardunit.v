module hazardunit (
 // inputs
 input [15:0] instr_fd,
 input [2:0] ID_EX_RegisterRd,
 input ID_EX_MemRead,
 // outputs
 output nop_hu,
 output pcwrite_df,
 output write_df
);

assign nop_hu = (((ID_EX_RegisterRd == instr_fd[10:8]) | (ID_EX_RegisterRd == instr_fd[7:5])) & ID_EX_MemRead) ? 1'b1 : 1'b0;
assign pcwrite_df = (((ID_EX_RegisterRd == instr_fd[10:8]) | (ID_EX_RegisterRd == instr_fd[7:5])) & ID_EX_MemRead) ? 1'b0 : 1'b1;
assign write_df = (((ID_EX_RegisterRd == instr_fd[10:8]) | (ID_EX_RegisterRd == instr_fd[7:5])) & ID_EX_MemRead) ? 1'b0 : 1'b1;

endmodule
