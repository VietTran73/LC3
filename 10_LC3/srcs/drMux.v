`timescale 1ps/1ps

module drMux (
	input			clk,
	input			rst_n,

	input			drMux_start,
	input		[3:0]	opCode,
	input		[15:0]	ALU_in,
	input		[15:0]	Addr_in,
	input		[15:0]	mem_in,

	output	reg	[15:0]	data_out
);

localparam      ADD                     = 4'b0001,
                AND                     = 4'b0101,
                NOT                     = 4'b1001,
                LD                      = 4'b0010,
                LDR                     = 4'b0110,
                LDI                     = 4'b1010,
                LEA                     = 4'b1110,
                ST                      = 4'b0011,
                STR                     = 4'b0111,
                STI                     = 4'b1011,
                BR                      = 4'b0000,
                JMP                     = 4'b1100,
                HALT                    = 4'b1111;

always @ (posedge clk) begin
	if (!rst_n)
		data_out		<= 0;
	else begin
		if (drMux_start) begin
			case (opCode)
			ADD, AND, NOT:
				data_out	<= ALU_in;
			LEA:
				data_out	<= Addr_in;
			LD, LDR, LDI:
				data_out	<= mem_in;
			default:
				data_out	<= 0;
			endcase
		end
	end
end

endmodule
