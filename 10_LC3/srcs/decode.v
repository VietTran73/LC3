`timescale 1ps/1ps

module decode (
	input			clk,
	input			rst_n,

	input			decode_start,
	input		[15:0]	mem_in,

	output	reg	[3:0]	opCode,
	output	reg	[4:0]	imm,
	output	reg	[2:0]	sr1ID,
	output	reg	[2:0]	sr2ID,
	output	reg	[2:0]	drID,
	output	reg	[8:0]	offset,
	output	reg		imm_op,
	output	reg	[2:0]	br_nzp,
	output	reg		decode_done,
	output 	reg 		inst_fetch_done
);

localparam      ADD             	= 4'b0001,
                AND             	= 4'b0101,
                NOT             	= 4'b1001,
                LD              	= 4'b0010,
                LDR             	= 4'b0110,
                LDI             	= 4'b1010,
                LEA             	= 4'b1110,
                ST              	= 4'b0011,
                STR             	= 4'b0111,
                STI             	= 4'b1011,
                BR              	= 4'b0000,
                JMP             	= 4'b1100,
                HALT            	= 4'b1111,
		OTHERS			= 4'b0100;

reg		decode_start_d1;
always @ (posedge clk) begin
	decode_start_d1			<= decode_start;
end

always @ (posedge clk) begin
	if (!rst_n) begin
		opCode			<= OTHERS;
		imm			<= 0;
		sr1ID			<= 0;
		sr2ID			<= 0;
		drID			<= 0;
		offset			<= 0;
		imm_op			<= 0;
		br_nzp			<= 0;
		decode_done		<= 0;
	end
	else begin
		if (decode_start & ~decode_start_d1) begin
			opCode		<= mem_in[15:12];
			
			if ((mem_in[15:12] == JMP) | (mem_in[15:12] == BR) | (mem_in[15:12] == HALT))
				drID	<= 0;
			else
				drID	<= mem_in[11:9];

			case (mem_in[15:12])
			AND, ADD, NOT, LDR, STR, JMP:
				sr1ID	<= mem_in[8:6];
			default:
				sr1ID	<= 0;
			endcase

			if (((mem_in[15:12] == AND) | (mem_in[15:12] == ADD)) & (mem_in[5] == 0))
				sr2ID	<= mem_in[2:0];
			else
				sr2ID	<= 0;

			if ((mem_in[15:12] == AND) | (mem_in[15:12] == ADD))
				imm	<= mem_in[4:0];
			else
				imm	<= 0;

			case (mem_in[15:12])
			LDR, STR: 
				offset  <= {{3{mem_in[5]}}, mem_in[5:0]};
			AND, ADD, NOT, JMP, HALT:
				offset	<= 0;
			default:
				offset  <= mem_in[8:0];
			endcase

			if ((mem_in[15:12] == AND) | (mem_in[15:12] == ADD))
				imm_op	<= mem_in[5];
			else
			        imm_op  <= 0;

			if (mem_in[15:12] == BR)
				br_nzp	<= mem_in[11:9];
			else
				br_nzp	<= 0;
		end
		else begin
			opCode		<= opCode;
			drID		<= drID;
			sr1ID		<= sr1ID;
			sr2ID		<= sr2ID;
			imm		<= imm;
			offset		<= offset;
			imm_op		<= imm_op;
			br_nzp		<= br_nzp;
		end
		decode_done		<= decode_start & ~decode_start_d1;
	end
end

endmodule
