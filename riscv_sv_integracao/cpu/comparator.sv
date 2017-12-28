// +FHDR---------------------------------------------------
// 
// FILE NAME      : comparator
// AUTHOR         : vanessa ogg
// AUTHOR'S EMAIL : voo@cin.ufpe.br
// ------------------------------------------------------
// RELEASE HISTORY
// VERSION 	DATE         AUTHOR		DESCRIPTION
// 1.0		2016-08-24      	Initial version
// ------------------------------------------------------

module comparator (
	input logic [31:0] a,
	input logic [31:0] b,
	output logic [31:0] cmp
);
int a_signal;
int b_signal;

assign a_signal = a;
assign b_signal = b;

always_ff @(a_signal,b_signal ) begin
	if (a_signal < b_signal) begin
		cmp <= 32'd1;
	end
	else begin
		cmp <= 32'd0;
	end
end
endmodule 