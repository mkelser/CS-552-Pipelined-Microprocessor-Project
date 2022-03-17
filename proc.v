module proc (clk, rst, err);

   input clk;
   input rst;
   output err;
   
   // instruction
   wire [15:0] instr_fd, instr_fdpr, instr_dx, instr_dxpr, instr_xm, instr_mw;
   
   // signal to indicate write new pc address to pc
   wire pcwrite_df;
   // pc select for pc incremented or pc address
   wire pcsel_dx, pcsel_dxpr, pcsel_wm, pcsel_mx, pcsel_xd, pcsel_df; 
   // pc incremented
   wire [15:0] pcinc_fd, pcinc_fdpr, pcinc_dx, pcinc_dxpr, pcinc_xm, pcinc_mw;
   wire [15:0] pcout_fd, pcout_fdpr;
   // pc address for jump and branch
   wire [15:0] pcaddrsel_xm, pcaddrsel_df, pcaddrsel_xd, pcaddrsel_mx;
   
   // write for fetch
   wire write_df;
   // flush for fetch
   wire flush_df, flush_dx, flush_dm;
   // halt signal
   wire halt_mf, halt_dx, halt_dxpr, halt_xm, halt_xmpr, halt_mw;
   
   // signal to indicate register write
   wire regwrite_dx, regwrite_dxpr, regwrite_xm, regwrite_xmpr, regwrite_mw, regwrite_mwpr, regwrite_wd;
   // select for register
   wire [1:0] regsrcsel_fd, regsrcsel_dx, regsrcsel_dxpr, regsrcsel_xm, regsrcsel_mw;
   // register to be written to
   wire [2:0] writeregsel_xm, writeregsel_xmpr, writeregsel_mw, writeregsel_mwpr, writeregsel_wm, writeregsel_mx, writeregsel_xd, writeregsel_wd;
   // data to be written in write register
   wire [15:0] writedata_wm, writedata_mx, writedata_xd, writedata_fd, writedata_wd;
   // data read from first register
   wire [15:0] read1data_dx, read1data_dxpr, read1data_xm;
   // data read from second register
   wire [15:0] read2data_dx, read2data_dxpr, read2data_xm, read2data_xmpr;
   
   // displacement value
   wire [15:0] disp_dx, disp_dxpr, disp_xm;
   // first immediate value
   wire [15:0] imm1_dx, imm1_dxpr, imm1_xm;
   // second immediate value
   wire [15:0] imm2_dx, imm2_dxpr, imm2_xm;
 
   // opcode for alu
   wire [3:0] aluop_dx, aluop_dxpr;
   // source for b for alu
   wire [1:0] alusrcsel_dx, alusrcsel_dxpr;
   // carry-in value for alu
   wire cin_dx, cin_dxpr, cin_xm;
   // invert signal for a
   wire inva_dx, inva_dxpr, inva_xm;
   // result form alu
   wire [15:0] aluresult_xm, aluresult_xmpr, aluresult_mw, aluresult_mwpr;
   // overflow signal from alu
   wire ofl_xm, ofl_xmpr, ofl_mw;
   // zero signal from alu
   wire z_xm, z_xmpr, z_mw;
   // negative signal from alu
   wire n_xm, n_xmpr, n_mw;
   // carry-out signal from alu
   wire cout_xm, cout_xmpr, cout_mw;
   
   // memory read enable
   wire memread_dx, memread_dxpr, memread_xm, memread_xmpr;
   // memory write enable
   wire memwrite_dx, memwrite_dxpr, memwrite_xm, memwrite_xmpr;
   // data read for memory
   wire [15:0] memreaddata_mw, memreaddata_mwpr;
   
   // branch signal
   wire branch_dx, branch_xm;
   // jump singal
   wire jump_dx, jump_xm;
   
   // select flag from alu
   wire [2:0] setcondsel_dx, setcondsel_dxpr, setcondsel_xm;
   // condition
   wire setbit_mw;
   // condition select
   wire condsel_dx, condsel_dxpr;

   // selcect to add pc and immediate
   wire immsrcsel_dx;
   // select to add pc and displacement
   wire immaddsel_dx;
   
   // data select for data to be written
   wire writedatasel_dx, writedatasel_dxpr, writedatasel_xm, writedatasel_xmpr, writedatasel_mw, writedatasel_mwpr, writedatasel_wd;
   
   // error indication for each stage
   wire err_d, err_e;
   
   assign err = err_d;
      
   fetch f0 (
    // inputs for writing to memory and registers
    .clk(clk), 
    .rst(rst),
    // halt from memory
    .halt_mf(halt_mf),
    // inputs from decode
    .pcwrite_df(pcwrite_df),
    .pcsel_df(pcsel_df),
    .pcaddrsel_df(pcaddrsel_df),
    // outputs to decode
    .instr_fd(instr_fd),
    .pcinc_fd(pcinc_fd),
    .pcout_fd(pcout_fd)
   );
   
   fdpr fd0 (
    // inputs for writing to registers
    .clk(clk),
    .rst(rst),
    // inputs from decode
    .flush_df(flush_df),
    .write_df(write_df),
    // inputs from fetch
    .instr_fd(instr_fd),
    .pcinc_fd(pcinc_fd),
    .pcout_fd(pcout_fd),
    // outputs to decode buffered by pipeline register
    .instr_fdpr(instr_fdpr),
    .pcinc_fdpr(pcinc_fdpr),
    .pcout_fdpr(pcout_fdpr)
   );
   
   decode d0 (
    // inputs for writing to registers
    .clk(clk),
    .rst(rst),
    // inputs from write
    .regwrite_wd(regwrite_wd),
    .writeregsel_wd(writeregsel_wd),
    .writedata_wd(writedata_wd),
    // inputs from fetch buffered by pipeline register
    .instr_fd(instr_fdpr),
    .pcinc_fd(pcinc_fdpr),
    .pcout_fd(pcout_fdpr),
    // inputs for ID/EX hazard detection and forwarding
    .ID_EX_ForwardA(aluresult_xm),
    .ID_EX_RegWrite(regwrite_dxpr),
    .ID_EX_RegisterRd(writeregsel_xm),
    .ID_EX_MemRead(memread_dxpr),
    // inputs for EX/MEM hazard detection and forwarding
    .EX_MEM_ForwardA(aluresult_xmpr),
    .EX_MEM_RegWrite(regwrite_xmpr),
    .EX_MEM_RegisterRd(writeregsel_xmpr),
    .EX_MEM_MemRead(memread_xmpr),
    // inputs for MEM/WB hazard detection and forwarding
    .MEM_WB_ForwardA(writedata_wd),
    .MEM_WB_RegWrite(regwrite_mwpr),
    .MEM_WB_RegisterRd(writeregsel_mwpr),
    .MEM_WB_MemRead(memread_xmpr),
    // outputs to fetch
    .pcwrite_df(pcwrite_df),
    .pcsel_df(pcsel_df),
    .pcaddrsel_df(pcaddrsel_df),
    // outputs to fetch buffered by pipeline register
    .flush_df(flush_df),
    .write_df(write_df),
    // outputs to execute
    .flush_dx(flush_dx),
    .flush_dm(flush_dm),
    .halt_dx(halt_dx),
    .instr_dx(instr_dx),
    .pcsel_dx(pcsel_dx),
    .pcinc_dx(pcinc_dx),
    .read1data_dx(read1data_dx),
    .read2data_dx(read2data_dx),
    .disp_dx(disp_dx),
    .imm1_dx(imm1_dx),
    .imm2_dx(imm2_dx),
    .alusrcsel_dx(alusrcsel_dx),
    .aluop_dx(aluop_dx),
    .inva_dx(inva_dx),
    .cin_dx(cin_dx),
    .condsel_dx(condsel_dx),
    .setcondsel_dx(setcondsel_dx),
    .memread_dx(memread_dx),
    .memwrite_dx(memwrite_dx),
    .regwrite_dx(regwrite_dx),
    .regsrcsel_dx(regsrcsel_dx),
    .writedatasel_dx(writedatasel_dx),
    // error output
    .err_d(err_d)
   );
   
   dxpr dx0 (
    // inputs for writing to registers
    .clk(clk),
    .rst(rst),
    // inputs from fetch
    .flush_dx(flush_dx),
    .halt_dx(halt_dx),
    .instr_dx(instr_dx),
    .pcsel_dx(pcsel_dx),
    .pcinc_dx(pcinc_dx),
    .read1data_dx(read1data_dx),
    .read2data_dx(read2data_dx),
    .disp_dx(disp_dx),
    .imm1_dx(imm1_dx),
    .imm2_dx(imm2_dx),
    .alusrcsel_dx(alusrcsel_dx),
    .aluop_dx(aluop_dx),
    .inva_dx(inva_dx),
    .cin_dx(cin_dx),
    .condsel_dx(condsel_dx),
    .setcondsel_dx(setcondsel_dx),
    .memread_dx(memread_dx),
    .memwrite_dx(memwrite_dx),
    .regwrite_dx(regwrite_dx),
    .regsrcsel_dx(regsrcsel_dx),
    .writedatasel_dx(writedatasel_dx),
    // outputs to execute buffered by pipeline register
    .halt_dxpr(halt_dxpr),
    .instr_dxpr(instr_dxpr),
    .pcsel_dxpr(pcsel_dxpr),
    .pcinc_dxpr(pcinc_dxpr),
    .read1data_dxpr(read1data_dxpr),
    .read2data_dxpr(read2data_dxpr),
    .disp_dxpr(disp_dxpr),
    .imm1_dxpr(imm1_dxpr),
    .imm2_dxpr(imm2_dxpr),
    .alusrcsel_dxpr(alusrcsel_dxpr),
    .aluop_dxpr(aluop_dxpr),
    .inva_dxpr(inva_dxpr),
    .cin_dxpr(cin_dxpr),
    .condsel_dxpr(condsel_dxpr),
    .setcondsel_dxpr(setcondsel_dxpr),
    .memread_dxpr(memread_dxpr),
    .memwrite_dxpr(memwrite_dxpr),
    .regwrite_dxpr(regwrite_dxpr),
    .regsrcsel_dxpr(regsrcsel_dxpr),
    .writedatasel_dxpr(writedatasel_dxpr)
   );
   
   execute e0 (
    // inputs from decode buffered by pipeline register
    .halt_dx(halt_dxpr),
    .instr_dx(instr_dxpr),
    .pcsel_dx(pcsel_dxpr),
    .pcinc_dx(pcinc_dxpr),
    .read1data_dx(read1data_dxpr),
    .read2data_dx(read2data_dxpr),
    .disp_dx(disp_dxpr),
    .imm1_dx(imm1_dxpr),
    .imm2_dx(imm2_dxpr),
    .alusrcsel_dx(alusrcsel_dxpr),
    .aluop_dx(aluop_dxpr),
    .inva_dx(inva_dxpr),
    .cin_dx(cin_dxpr),
    .condsel_dx(condsel_dxpr),
    .setcondsel_dx(setcondsel_dxpr),
    .memread_dx(memread_dxpr),
    .memwrite_dx(memwrite_dxpr),
    .regwrite_dx(regwrite_dxpr),
    .regsrcsel_dx(regsrcsel_dxpr),
    .writedatasel_dx(writedatasel_dxpr),
    // inputs for EX/MEM hazard detection and forwarding
    .EX_MEM_ForwardA(aluresult_xmpr),
    .EX_MEM_ForwardB(aluresult_xmpr),
    .EX_MEM_RegWrite(regwrite_xmpr),
    .EX_MEM_RegisterRd(writeregsel_xmpr),
    // inputs for MEM/WB hazard detection and forwarding
    .MEM_WB_ForwardA(writedata_wd),
    .MEM_WB_ForwardB(writedata_wd),
    .MEM_WB_RegWrite(regwrite_mwpr),
    .MEM_WB_RegisterRd(writeregsel_mwpr),
    // not pipelined
    .halt_xm(halt_xm),
    .read2data_xm(read2data_xm),
    .aluresult_xm(aluresult_xm),
    .z_xm(z_xm),
    .n_xm(n_xm),
    .ofl_xm(ofl_xm),
    .cout_xm(cout_xm),
    .memread_xm(memread_xm),
    .memwrite_xm(memwrite_xm),
    .regwrite_xm(regwrite_xm),
    .writeregsel_xm(writeregsel_xm),
    .writedatasel_xm(writedatasel_xm),
    // error output
    .err_e(err_e)
   );
   
   xmpr xm0 (
    // inputs for writing to registers
    .clk(clk),
    .rst(rst),
    // inputs from execute
    .flush_dm(flush_dm),
    .halt_xm(halt_xm),   
    .read2data_xm(read2data_xm),
    .aluresult_xm(aluresult_xm),
    .memread_xm(memread_xm),
    .memwrite_xm(memwrite_xm),
    .regwrite_xm(regwrite_xm),
    .writeregsel_xm(writeregsel_xm),
    .writedatasel_xm(writedatasel_xm),
    // outputs to memory buffered by pipeline register
    .halt_xmpr(halt_xmpr),
    .read2data_xmpr(read2data_xmpr),
    .aluresult_xmpr(aluresult_xmpr),
    .memread_xmpr(memread_xmpr),
    .memwrite_xmpr(memwrite_xmpr),
    .regwrite_xmpr(regwrite_xmpr),
    .writeregsel_xmpr(writeregsel_xmpr),
    .writedatasel_xmpr(writedatasel_xmpr)
   );
   
   memory m0 (
    // inputs for writing to memory
    .clk(clk),
    .rst(rst),
    // inputs from execute buffered by pipeline register
    .halt_xm(halt_xmpr),
    .memread_xm(memread_xmpr),
    .memwrite_xm(memwrite_xmpr),
    .read2data_xm(read2data_xmpr),
    .aluresult_xm(aluresult_xmpr),
    .regwrite_xm(regwrite_xmpr),
    .writeregsel_xm(writeregsel_xmpr),
    .writedatasel_xm(writedatasel_xmpr),
    // halt to fetch
    .halt_mf(halt_mf),
    // outputs to write
    .aluresult_mw(aluresult_mw),
    .memreaddata_mw(memreaddata_mw),
    .regwrite_mw(regwrite_mw),
    .writeregsel_mw(writeregsel_mw),
    .writedatasel_mw(writedatasel_mw)
   );
   
   mwpr mw0 (
    // inputs for writing to registers
    .clk(clk),
    .rst(rst),
    // inputs from memory
    .aluresult_mw(aluresult_mw),
    .memreaddata_mw(memreaddata_mw),
    .regwrite_mw(regwrite_mw),
    .writeregsel_mw(writeregsel_mw),
    .writedatasel_mw(writedatasel_mw),
    // outputs to write buffered by pipeline register
    .aluresult_mwpr(aluresult_mwpr),
    .memreaddata_mwpr(memreaddata_mwpr),
    .regwrite_mwpr(regwrite_mwpr),
    .writeregsel_mwpr(writeregsel_mwpr),
    .writedatasel_mwpr(writedatasel_mwpr)
   );
   
   write w0 (
    // inputs from pipeline register
    .aluresult_mw(aluresult_mwpr),
    .memreaddata_mw(memreaddata_mwpr),
    .regwrite_mw(regwrite_mwpr),
    .writeregsel_mw(writeregsel_mwpr),
    .writedatasel_mw(writedatasel_mwpr),
    // outputs to decode for writing to registers
    .regwrite_wd(regwrite_wd),
    .writeregsel_wd(writeregsel_wd),
    .writedata_wd(writedata_wd)
   );
    
endmodule