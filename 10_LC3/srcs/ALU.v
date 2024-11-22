`timescale 1ps/1ps

module ALU (
	input			clk,
	input			rst_n,

	input			ALU_start,
	input		[3:0]	opCode,
	input		[15:0]	sr1,
	input		[15:0]	sr2,
	input		[4:0]	imm,
	input			imm_op,

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
		if (ALU_start) begin
			case (opCode)
			ADD: data_out	<= imm_op? sr1 + {{11{imm[4]}}, imm} : sr1 + sr2;
			AND: data_out	<= imm_op? sr1 & {{11{imm[4]}}, imm} : sr1 & sr2;
			NOT: data_out	<= ~sr1;
			endcase
		end
		else
			data_out	<= data_out;
	end
end

endmodule
