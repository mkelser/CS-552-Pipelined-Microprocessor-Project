module mwpr (
 // inputs for writing to registers
 input clk,
 input rst,
 // inputs from memory
 input [15:0] aluresult_mw,
 input [15:0] memreaddata_mw,
 input regwrite_mw,
 input [2:0] writeregsel_mw,
 input writedatasel_mw,
 // outputs to write
 output [15:0] aluresult_mwpr,
 output [15:0] memreaddata_mwpr,
 output regwrite_mwpr,
 output [2:0] writeregsel_mwpr,
 output writedatasel_mwpr
);

dff aluresult_pr [15:0] (.d(aluresult_mw), .clk(clk), .rst(rst), .q(aluresult_mwpr));
dff memreaddata_pr [15:0] (.d(memreaddata_mw), .clk(clk), .rst(rst), .q(memreaddata_mwpr));
dff regwrite_pr (.d(regwrite_mw), .clk(clk), .rst(rst), .q(regwrite_mwpr));
dff writeregsel_pr [2:0] (.d(writeregsel_mw), .clk(clk), .rst(rst), .q(writeregsel_mwpr));
dff writedatasel_pr (.d(writedatasel_mw), .clk(clk), .rst(rst), .q(writedatasel_mwpr));

endmodule
