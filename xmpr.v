module xmpr (
 // inputs for writing
 input clk,
 input rst,
 // inputs from execute
 input flush_dm,
 input halt_xm,
 input [15:0] read2data_xm,
 input [15:0] aluresult_xm,
 input memread_xm,
 input memwrite_xm,
 input regwrite_xm,
 input [2:0] writeregsel_xm,
 input writedatasel_xm,
 // outputs to memory
 output halt_xmpr,
 output [15:0] read2data_xmpr,
 output [15:0] aluresult_xmpr,
 output memread_xmpr,
 output memwrite_xmpr,
 output regwrite_xmpr,
 output [2:0] writeregsel_xmpr,
 output writedatasel_xmpr
);

wire halt;
wire [15:0] read2data;
wire [15:0] aluresult;
wire memread;
wire memwrite;
wire regwrite;
wire [2:0] writeregsel;
wire writedatasel;

assign halt = flush_dm ? 1'b0 : halt_xm;
assign read2data = flush_dm ? 16'h0000 : read2data_xm;
assign aluresult = flush_dm ? 16'h0000 : aluresult_xm;
assign memread = flush_dm ? 1'b0 : memread_xm;
assign memwrite = flush_dm ? 1'b0 : memwrite_xm;
assign regwrite = flush_dm ? 1'b0 : regwrite_xm;
assign writeregsel = flush_dm ? 3'b000 : writeregsel_xm;
assign writedatasel = flush_dm ? 1'b0 : writedatasel_xm;

dff halt_pr (.d(halt), .clk(clk), .rst(rst), .q(halt_xmpr));
dff read2data_pr [15:0] (.d(read2data), .clk(clk), .rst(rst), .q(read2data_xmpr));
dff aluresult_pr [15:0] (.d(aluresult), .clk(clk), .rst(rst), .q(aluresult_xmpr));
dff memread_pr (.d(memread), .clk(clk), .rst(rst), .q(memread_xmpr));
dff memwrite_pr (.d(memwrite), .clk(clk), .rst(rst), .q(memwrite_xmpr));
dff regwrite_pr (.d(regwrite), .clk(clk), .rst(rst), .q(regwrite_xmpr));
dff writeregsel_pr [2:0] (.d(writeregsel), .clk(clk), .rst(rst), .q(writeregsel_xmpr));
dff writedatsel_pr (.d(writedatasel), .clk(clk), .rst(rst), .q(writedatasel_xmpr));

endmodule
