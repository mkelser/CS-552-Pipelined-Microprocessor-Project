module memory (
 // inputs for writing to memory
 input clk,
 input rst,
 // inputs from execute buffered by pipeline register
 input halt_xm,
 input memread_xm,
 input memwrite_xm,
 input [15:0] read2data_xm,
 input [15:0] aluresult_xm,
 input regwrite_xm,
 input [2:0] writeregsel_xm,
 input writedatasel_xm,
 // halt to fetch
 output halt_mf,
 // outputs to write
 output [15:0] aluresult_mw,
 output [15:0] memreaddata_mw,
 output regwrite_mw,
 output [2:0] writeregsel_mw, 
 output writedatasel_mw
);

wire enable;

assign halt_mf = halt_xm;
assign aluresult_mw = aluresult_xm;
assign regwrite_mw = regwrite_xm;
assign writeregsel_mw = writeregsel_xm;
assign writedatasel_mw = writedatasel_xm;

assign enable = ~halt_mf & (memwrite_xm | memread_xm);

memory2c dm0 (
 .data_out(memreaddata_mw),
 .data_in(read2data_xm),
 .addr(aluresult_xm),
 .enable(enable),
 .wr(memwrite_xm),
 .createdump(halt_mf),
 .clk(clk), 
 .rst(rst)
);

endmodule
