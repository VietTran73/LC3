`timescale 1ps/1ps

module memory (
	input			clk,
	input			rst_n,

	input			mem_start,
	input		[15:0]	addr,
	input			wea,
	input		[15:0]	data_in,

	output	reg	[15:0]	data_out
);

localparam      ADD             = 4'b0001,
                AND             = 4'b0101,
                NOT             = 4'b1001,
                LD              = 4'b0010,
                LDR             = 4'b0110,
                LDI             = 4'b1010,
                LEA             = 4'b1110,
                ST              = 4'b0011,
                STR             = 4'b0111,
                STI             = 4'b1011,
                BR              = 4'b0000,
                JMP             = 4'b1100,
                HALT            = 4'b1111;

localparam	MEM_DEPTH	= 512;

reg	[15:0]	mem [0:MEM_DEPTH-1];

initial begin
	$readmemb ("BR_negav_app.mem", mem); 
end

always @ (posedge clk) begin
	if (!rst_n)
		data_out			<= 0;
	else begin
		if (mem_start) begin
			if (wea)
				mem[addr]	<= data_in;

			if (!wea)
				data_out	<= mem[addr];
			else
				data_out	<= data_out;
		end
	end
end

endmodule
