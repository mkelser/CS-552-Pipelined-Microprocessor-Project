module write (
 // inputs from memory
 input [15:0] aluresult_mw,
 input [15:0] memreaddata_mw,
 input regwrite_mw,
 input [2:0] writeregsel_mw,
 input writedatasel_mw,
 // outputs to decode for writing to register
 output [2:0] writeregsel_wd,
 output [15:0] writedata_wd,
 output regwrite_wd
);

assign writeregsel_wd = writeregsel_mw;
assign regwrite_wd = regwrite_mw;

assign writedata_wd = (writedatasel_mw == 1'b0) ? memreaddata_mw : aluresult_mw;

endmodule
