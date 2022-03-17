module forwardingunit (
 input [15:0] instr_dx,
 input [15:0] read1data_dx,
 input [15:0] read2data_dx,
 input [15:0] EX_MEM_ForwardA,
 input [15:0] EX_MEM_ForwardB,
 input EX_MEM_RegWrite,
 input [2:0] EX_MEM_RegisterRd,
 input [15:0] MEM_WB_ForwardA,
 input [15:0] MEM_WB_ForwardB,
 input MEM_WB_RegWrite,
 input [2:0] MEM_WB_RegisterRd,
 input [1:0] alusrcsel_dx,
 input [15:0] imm1_dx,
 input [15:0] imm2_dx,
 output [15:0] afwd,
 output [15:0] bfwd,
 output [15:0] bsrc,
 output [1:0] forwardasel,
 output [1:0] forwardbsel
);

assign forwardasel = (EX_MEM_RegWrite & (EX_MEM_RegisterRd == instr_dx[10:8])) ? 2'b10 :
                     (MEM_WB_RegWrite & (MEM_WB_RegisterRd == instr_dx[10:8])) ? 2'b01 :
                     2'b00;

assign forwardbsel = (EX_MEM_RegWrite & (EX_MEM_RegisterRd == instr_dx[7:5])) ? 2'b10 :
                     (MEM_WB_RegWrite & (MEM_WB_RegisterRd == instr_dx[7:5])) ? 2'b01 :
                     2'b00;

assign afwd = (forwardasel == 2'b00) ? read1data_dx :
              (forwardasel == 2'b01) ? MEM_WB_ForwardA :
              (forwardasel == 2'b10) ? EX_MEM_ForwardA :
              read1data_dx;

assign bsrc = (alusrcsel_dx == 2'b00) ? imm2_dx :
              (alusrcsel_dx == 2'b01) ? bfwd :
              (alusrcsel_dx == 2'b10) ? 16'h0000 :
              imm1_dx;

assign bfwd = (forwardbsel == 2'b00) ? read2data_dx :
              (forwardbsel == 2'b01) ? MEM_WB_ForwardB :
              (forwardbsel == 2'b10) ? EX_MEM_ForwardB :
              read2data_dx;

endmodule
