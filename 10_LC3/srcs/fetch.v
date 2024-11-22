`timescale 1ps/1ps

module fetch (
	input			clk,
	input			rst_n,

	input			fetch_start,
	input		[3:0]	opCode_in,
	input		[8:0]	offset_in,
	input		[15:0]	reg_in,
	input		[2:0]	br_nzp,
	input		[2:0]	result_nzp,

	output	reg 	[15:0]	addr_out,
	output	 		wea_out,
	output	reg	[15:0]	pc
);

localparam	ADD		= 4'b0001,
		AND		= 4'b0101,
		NOT		= 4'b1001,
		LD		= 4'b0010,
		LDR		= 4'b0110,
		LDI		= 4'b1010,
		LEA		= 4'b1110,
		ST		= 4'b0011,
		STR		= 4'b0111,
		STI		= 4'b1011,
		BR		= 4'b0000,
		JMP		= 4'b1100,
		HALT		= 4'b1111;

always @ (posedge clk) begin
	if (!rst_n) begin
		addr_out			<= 16'h0;
		pc				<= 16'h0;
	end
	else begin
		if (fetch_start) begin
			case (opCode_in)
			JMP: begin
				addr_out	<= reg_in;
				pc		<= reg_in + 1;
				
			//	addr_out 	<= pc;
			// 	pc 		<= reg_in
			end
			BR: begin
			    if (|(br_nzp & result_nzp)) begin// if ((br_nzp[2] == result_nzp[2]) | (br_nzp[1] == result_nzp[1]) | (br_nzp[0] == result_nzp[0]))
				if (offset_in[8]) begin
			            addr_out	<= pc - (~{{7{offset_in[8]}}, offset_in} + 1);//offset = -7 (9'd505)  => 505-512 = -7
				    pc		<= pc - (~{{7{offset_in[8]}}, offset_in}) + 1;
				end
				else begin
                                    addr_out    <= pc + offset_in;
                                    pc          <= pc + offset_in;
				end
			
			    end
			    else begin
				addr_out	<= pc;//addr_out + 1;
				pc		<= pc + 1;
			    end
			end
			default: begin
				addr_out 	<= pc;
				pc		<= pc + 1;
			end
			endcase
		end
		else begin
			pc			<= pc;
			addr_out		<= addr_out;
		end
	end
end

assign	wea_out					= 0;

endmodule
