`timescale 1ps/1ps

module register (
	input				clk,
	input				rst_n,

	input		[3:0]		opCode,
	input				start_rd,
	input				start_wr,
	input		[2:0]		sr1ID,
	input		[2:0]		sr2ID,
	input		[2:0]		drID,

	input		[15:0]		data_in,
	output	reg	[15:0]		sr1,
	output	reg	[15:0]		sr2,

	output	reg	[2:0]		result_nzp
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

localparam	NUM_REG			= 8;

reg	[15:0]		internal_reg[0:NUM_REG-1];
integer			i;

always @ (posedge clk) begin
	if (!rst_n) begin
		for (i=0;i<NUM_REG;i=i+1) begin
			internal_reg[i]		<= 0;
		end
		sr1				<= 0;
		sr2				<= 0;
		result_nzp			<= 0;
	end
	else begin
		if (!start_wr) begin
			if (start_rd) begin
				sr1		<= internal_reg[sr1ID];
				sr2		<= ((opCode == ST) | (opCode == STI) | (opCode == STR))? internal_reg[drID] : internal_reg[sr2ID];
			end
			else begin
                	        sr1             <= sr1;
                	        sr2             <= sr2;
			end
		end
		else begin
			sr1			<= 0;
			sr2			<= 0;
		end

		if (!start_rd) begin
			if (start_wr) begin
				internal_reg[drID]	<= data_in;
			end
			else begin
				for (i=0; i<NUM_REG; i=i+1) begin
	        	                internal_reg[i] <= internal_reg[i];
				end
			end
		end

		if (start_rd) begin
			result_nzp[2]           <= internal_reg[drID][15];
                        result_nzp[1]           <= !(|{internal_reg[drID]});  //(internal_reg[drID] == 0);
                        result_nzp[0]           <= ~internal_reg[drID][15] & (|internal_reg[drID][14:0]) ; // bit (+) is 0, so ~ [p] to kick signal 

		// vd: bit tra ve la 0010 (2)
		//	result => 001 
		//     bit tra ve la 1110 (-2)
		//	result => 100 
		end
		else if (start_wr) begin
			result_nzp[2]		<= data_in[15];
			result_nzp[1]		<= (data_in == 0);
			result_nzp[0]		<= ~data_in[15] & (|data_in[14:0]);
		end
		else begin
			result_nzp		<= result_nzp;
		end
	end
end

endmodule
