module execute (
 // inputs from decode buffered by pipeline register
 input halt_dx,
 input [15:0] instr_dx,
 input pcsel_dx,
 input [15:0] pcinc_dx,
 input [15:0] read1data_dx,
 input [15:0] read2data_dx,
 input [15:0] disp_dx,
 input [15:0] imm1_dx,
 input [15:0] imm2_dx,
 input [1:0] alusrcsel_dx,
 input [3:0] aluop_dx,
 input inva_dx,
 input cin_dx,
 input condsel_dx,
 input [2:0] setcondsel_dx,
 input memread_dx,
 input memwrite_dx,
 input regwrite_dx,
 input [1:0] regsrcsel_dx,
 input writedatasel_dx,
 // inputs for EX/MEM hazard detection and forwarding
 input [15:0] EX_MEM_ForwardA,
 input [15:0] EX_MEM_ForwardB,
 input EX_MEM_RegWrite,
 input [2:0] EX_MEM_RegisterRd,
 // inputs for MEM/WB hazard detection and forwarding
 input [15:0] MEM_WB_ForwardA,
 input [15:0] MEM_WB_ForwardB,
 input MEM_WB_RegWrite,
 input [2:0] MEM_WB_RegisterRd,
 // not pipelined
 output halt_xm,
 output [15:0] read2data_xm,
 output [15:0] aluresult_xm,
 output z_xm,
 output n_xm,
 output ofl_xm,
 output cout_xm,
 output memread_xm,
 output memwrite_xm,
 output regwrite_xm,
 output [2:0] writeregsel_xm,
 output writedatasel_xm,
 // error output
 output err_e
);

assign writedatasel_xm = writedatasel_dx;
assign memread_xm = memread_dx;
assign memwrite_xm = memwrite_dx;
assign regwrite_xm = regwrite_dx;
assign halt_xm = halt_dx;

wire [1:0] forwardasel;
wire [1:0] forwardbsel;

wire [15:0] afwd;
wire [15:0] bfwd;

wire [15:0] bsrc;

wire [15:0] result;

wire setbit;

wire greaterthan;
wire lessthan;
wire lessthanorequal;

wire err_alu;

assign greaterthan = n_xm | z_xm;
assign lessthan =  ofl_xm ^ (~n_xm & ~z_xm);
assign lessthanorequal = z_xm | lessthan;

assign setbit = (setcondsel_dx == 3'b000) ? z_xm :
                (setcondsel_dx == 3'b001) ? lessthan :
                (setcondsel_dx == 3'b010) ? lessthanorequal :
                (setcondsel_dx == 3'b011) ? ~z_xm :
                (setcondsel_dx == 3'b100) ? greaterthan :
                (setcondsel_dx == 3'b101) ? cout_xm : 
                (setcondsel_dx == 3'b110) ? 1'b0 :
                1'b0;

assign read2data_xm = bfwd;

assign aluresult_xm = condsel_dx ? setbit :
                      pcsel_dx ? pcinc_dx :
                      result;

assign writeregsel_xm = (regsrcsel_dx == 2'b00) ? instr_dx[7:5] :
                        (regsrcsel_dx == 2'b01) ? instr_dx[10:8] :
                        (regsrcsel_dx == 2'b10) ? instr_dx[4:2] :
                        3'b111;

assign err_e = err_alu;

forwardingunit fu0 (
 .instr_dx(instr_dx),
 .read1data_dx(read1data_dx),
 .read2data_dx(read2data_dx),
 .EX_MEM_ForwardA(EX_MEM_ForwardA),
 .EX_MEM_ForwardB(EX_MEM_ForwardB),
 .EX_MEM_RegWrite(EX_MEM_RegWrite),
 .EX_MEM_RegisterRd(EX_MEM_RegisterRd),
 .MEM_WB_ForwardA(MEM_WB_ForwardA),
 .MEM_WB_ForwardB(MEM_WB_ForwardB),
 .MEM_WB_RegWrite(MEM_WB_RegWrite),
 .MEM_WB_RegisterRd(MEM_WB_RegisterRd),
 .alusrcsel_dx(alusrcsel_dx),
 .imm1_dx(imm1_dx),
 .imm2_dx(imm2_dx),
 .afwd(afwd),
 .bfwd(bfwd),
 .bsrc(bsrc),
 .forwardasel(forwardasel),
 .forwardbsel(forwardbsel)
);

alu alu0 (
 .a(afwd), 
 .b(bsrc),
 .cin(cin_dx),
 .op(aluop_dx),
 .inva(inva_dx),
 .result(result),
 .ofl(ofl_xm),
 .z(z_xm),
 .n(n_xm),
 .cout(cout_xm), 
 .err(err_alu)
);

endmodule
