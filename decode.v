module decode (
 // inputs for writing
 input clk,
 input rst,
 // inputs from write
 input regwrite_wd,
 input [2:0] writeregsel_wd,
 input [15:0] writedata_wd,
 // inputs from fetch buffered by pipeline register
 input [15:0] instr_fd,
 input [15:0] pcinc_fd,
 input [15:0] pcout_fd,
 // inputs for ID/EX hazard detection and forwarding
 input [15:0] ID_EX_ForwardA,
 input ID_EX_RegWrite,
 input [2:0] ID_EX_RegisterRd,
 input ID_EX_MemRead,
 // inputs for EX/MEM hazard detection and forwarding
 input [15:0] EX_MEM_ForwardA,
 input EX_MEM_RegWrite,
 input [2:0] EX_MEM_RegisterRd,
 input EX_MEM_MemRead,
 // inputs for MEM/WB hazard detection and forwarding
 input [15:0] MEM_WB_ForwardA,
 input MEM_WB_RegWrite,
 input [2:0] MEM_WB_RegisterRd,
 input MEM_WB_MemRead,
 // outputs to fetch
 output pcwrite_df,
 output pcsel_df,
 output [15:0] pcaddrsel_df,
 // outputs to pipeline register buffered by pipeline register
 output flush_df,
 output write_df,
 // outputs to decode
 output flush_dx,
 output flush_dm,
 output halt_dx,
 output [15:0] instr_dx,
 output pcsel_dx,
 output [15:0] pcinc_dx,
 output [15:0] read1data_dx,
 output [15:0] read2data_dx,
 output [15:0] disp_dx,
 output [15:0] imm1_dx,
 output [15:0] imm2_dx,
 output [1:0] alusrcsel_dx,
 output [3:0] aluop_dx,
 output inva_dx,
 output cin_dx,
 output condsel_dx,
 output [2:0] setcondsel_dx,
 output memread_dx,
 output memwrite_dx,
 output regwrite_dx,
 output [1:0] regsrcsel_dx,
 output writedatasel_dx,
 output err_d
);

wire illegalop_cu;
wire returnepc_cu;

wire [15:0] epcinp;
wire [15:0] epcout;

wire nop_hu;

wire branchcond;
wire branch_cu;
wire jump_cu;

wire [15:0] pcaddrsel;
wire [15:0] pcaddrbranch;

wire immsrcsel_cu;
wire [15:0] immsrc;
wire immaddsel_cu;
wire [15:0] immadd;
wire regwrite_cu;

wire memread_cu;
wire memwrite_cu;

wire zeroextsel_cu;

wire err_rf, err_cu;

assign pcinc_dx = pcinc_fd;
assign instr_dx = instr_fd;

assign immsrc = immsrcsel_cu ? imm2_dx : disp_dx;
assign immadd = immaddsel_cu ? pcaddrbranch : pcinc_fd;

assign regwrite_dx = nop_hu ? 1'b0 : regwrite_cu;
assign memread_dx = nop_hu ? 1'b0 : memread_cu;
assign memwrite_dx = nop_hu ? 1'b0 : memwrite_cu;

// if jumping or branching select a new pc
assign pcsel_df = illegalop_cu | returnepc_cu | jump_cu | (branchcond & branch_cu);
// if jumping or branch assert flush to fetch
assign flush_df = pcsel_df;

assign pcaddrbranch = (~ID_EX_MemRead & ID_EX_RegWrite & (ID_EX_RegisterRd == instr_fd[10:8])) ? ID_EX_ForwardA  :
                      (~EX_MEM_MemRead & EX_MEM_RegWrite & (EX_MEM_RegisterRd == instr_fd[10:8])) ? EX_MEM_ForwardA :
                      (MEM_WB_RegWrite & (MEM_WB_RegisterRd == instr_fd[10:8])) ? MEM_WB_ForwardA :
                      read1data_dx;

assign branchcond = (setcondsel_dx == 3'b000) ? (pcaddrbranch == 16'h0000) :
                    (setcondsel_dx == 3'b001) ? (pcaddrbranch[15] != 1'b0) :
                    (setcondsel_dx == 3'b011) ? (pcaddrbranch != 16'h0000) :
                    (setcondsel_dx == 3'b100) ? ((pcaddrbranch[15] == 1'b0) | (pcaddrbranch == 16'h0000)) :
                    1'b0;

assign flush_dx = illegalop_cu;
assign flush_dm = 1'b0;

assign pcaddrsel_df = illegalop_cu ? 16'h0002 :
                      returnepc_cu ? epcout :
                      pcaddrsel;

assign epcinp = illegalop_cu ? pcinc_fd : epcout;
r16 epc0 [15:0] (.Inp(epcinp), .clk(clk), .rst(rst), .Out(epcout));

assign err_d = err_rf | err_cu;

// displacement extension
de de0 (
 .inp(instr_fd), 
 .disp(disp_dx)
);

// immediate extension
ie ie0 (
 .inp(instr_fd), 
 .zeroextsel(zeroextsel_cu), 
 .imm1(imm1_dx), 
 .imm2(imm2_dx)
);

// control unit
cu cu0 (
 // input of instruction to be decoded
 .instr_fd(instr_fd),
 // outputs back to decode
 .illegalop_cu(illegalop_cu),
 .returnepc_cu(returnepc_cu),
 .memread_cu(memread_cu),
 .memwrite_cu(memwrite_cu),
 .branch_cu(branch_cu),
 .jump_cu(jump_cu),
 .zeroextsel_cu(zeroextsel_cu),
 .regwrite_cu(regwrite_cu),
 .immsrcsel_cu(immsrcsel_cu),
 .immaddsel_cu(immaddsel_cu),
 .err_cu(err_cu),
 // outputs to execute
 .halt_dx(halt_dx),
 .pcsel_dx(pcsel_dx),
 .alusrcsel_dx(alusrcsel_dx),
 .aluop_dx(aluop_dx),
 .inva_dx(inva_dx),
 .cin_dx(cin_dx),
 .condsel_dx(condsel_dx),
 .setcondsel_dx(setcondsel_dx),
 .regsrcsel_dx(regsrcsel_dx),
 .writedatasel_dx(writedatasel_dx)
);

// hazard detection unit
hazardunit hu0 (
 // inputs
 .instr_fd(instr_fd),
 .ID_EX_RegisterRd(ID_EX_RegisterRd),
 .ID_EX_MemRead(ID_EX_MemRead),
 // outputs
 .nop_hu(nop_hu),
 .pcwrite_df(pcwrite_df),
 .write_df(write_df)
);

fulladder16 fa0 (
 .A(immsrc), 
 .B(immadd), 
 .S(pcaddrsel), 
 .Cout()
);

rfb rfb0 (
 .read1data(read1data_dx), 
 .read2data(read2data_dx),
 .err(err_rf),
 .clk(clk),
 .rst(rst),
 .read1regsel(instr_fd[10:8]),
 .read2regsel(instr_fd[7:5]),
 .writeregsel(writeregsel_wd),
 .writedata(writedata_wd),
 .write(regwrite_wd)
);

endmodule
