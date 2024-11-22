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
