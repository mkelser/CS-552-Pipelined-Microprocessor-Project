module dxpr (
 // inputs for writing
 input clk,
 input rst,
 // inputs from decode
 input flush_dx,
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
 // outputs to execute
 output halt_dxpr,
 output [15:0] instr_dxpr,
 output pcsel_dxpr,
 output [15:0] pcinc_dxpr,
 output [15:0] read1data_dxpr,
 output [15:0] read2data_dxpr,
 output [15:0] disp_dxpr,
 output [15:0] imm1_dxpr,
 output [15:0] imm2_dxpr,
 output [1:0] alusrcsel_dxpr,
 output [3:0] aluop_dxpr,
 output inva_dxpr,
 output cin_dxpr,
 output condsel_dxpr,
 output [2:0] setcondsel_dxpr,
 output memread_dxpr,
 output memwrite_dxpr,
 output regwrite_dxpr,
 output [1:0] regsrcsel_dxpr,
 output writedatasel_dxpr
);

wire halt;
wire [15:0] instr;
wire pcsel;
wire [15:0] pcinc;
wire [15:0] read1data;
wire [15:0] read2data;
wire [15:0] disp;
wire [15:0] imm1;
wire [15:0] imm2;
wire [1:0] alusrcsel;
wire [3:0] aluop;
wire inva;
wire cin;
wire condsel;
wire [2:0] setcondsel;
wire memread;
wire memwrite;
wire regwrite;
wire [1:0] regsrcsel;
wire writedatasel;

assign halt = flush_dx ? 1'b0 : halt_dx;
assign instr = flush_dx ? 16'h0000 : instr_dx;
assign pcsel = flush_dx ? 1'b0 : pcsel_dx;
assign pcinc = flush_dx ? 16'h0000 : pcinc_dx;
assign read1data = flush_dx ? 16'h0000 : read1data_dx;
assign read2data = flush_dx ? 16'h0000 : read2data_dx;
assign disp = flush_dx ? 16'h0000 : disp_dx;
assign imm1 = flush_dx ? 16'h0000 : imm1_dx;
assign imm2 = flush_dx ? 16'h0000 : imm2_dx;
assign alusrcsel = flush_dx ? 2'b00 : alusrcsel_dx;
assign aluop = flush_dx ? 4'b0000 : aluop_dx;
assign inva = flush_dx ? 1'b0 : inva_dx;
assign cin = flush_dx ? 1'b0 : cin_dx;
assign condsel = flush_dx ? 1'b0 : condsel_dx;
assign setcondsel = flush_dx ? 3'b000 : setcondsel_dx;
assign memread = flush_dx ? 1'b0 : memread_dx;
assign memwrite = flush_dx ? 1'b0 : memwrite_dx;
assign regwrite = flush_dx ? 1'b0 : regwrite_dx;
assign regsrcsel = flush_dx ? 2'b00 : regsrcsel_dx;
assign writedatasel = flush_dx ? 1'b0 : writedatasel_dx;

dff halt_pr (.d(halt), .clk(clk), .rst(rst), .q(halt_dxpr));
dff instr_pr [15:0] (.d(instr), .clk(clk), .rst(rst), .q(instr_dxpr));
dff pcsel_pr (.d(pcsel), .clk(clk), .rst(rst), .q(pcsel_dxpr));
dff pcinc_pr [15:0] (.d(pcinc), .clk(clk), .rst(rst), .q(pcinc_dxpr));
dff read1data_pr [15:0] (.d(read1data), .clk(clk), .rst(rst), .q(read1data_dxpr));
dff read2data_pr [15:0] (.d(read2data), .clk(clk), .rst(rst), .q(read2data_dxpr));
dff disp_pr [15:0] (.d(disp), .clk(clk), .rst(rst), .q(disp_dxpr));
dff imm1_pr [15:0] (.d(imm1), .clk(clk), .rst(rst), .q(imm1_dxpr));
dff imm2_pr [15:0] (.d(imm2), .clk(clk), .rst(rst), .q(imm2_dxpr));
dff alusrcsel_pr [1:0] (.d(alusrcsel), .clk(clk), .rst(rst), .q(alusrcsel_dxpr));
dff aluop_pr [3:0] (.d(aluop), .clk(clk), .rst(rst), .q(aluop_dxpr));
dff inva_pr (.d(inva), .clk(clk), .rst(rst), .q(inva_dxpr));
dff cin_pr (.d(cin), .clk(clk), .rst(rst), .q(cin_dxpr));
dff condsel_pr (.d(condsel), .clk(clk), .rst(rst), .q(condsel_dxpr));
dff setcondsel_pr [2:0] (.d(setcondsel), .clk(clk), .rst(rst), .q(setcondsel_dxpr));
dff memread_pr (.d(memread), .clk(clk), .rst(rst), .q(memread_dxpr));
dff memwrite_pr (.d(memwrite), .clk(clk), .rst(rst), .q(memwrite_dxpr));
dff regwrite_pr (.d(regwrite), .clk(clk), .rst(rst), .q(regwrite_dxpr));
dff regsrcsel_pr [1:0] (.d(regsrcsel), .clk(clk), .rst(rst), .q(regsrcsel_dxpr));
dff writedatasel_pr (.d(writedatasel), .clk(clk), .rst(rst), .q(writedatasel_dxpr));

endmodule
