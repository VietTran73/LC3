`timescale 1ps/1ps

module Address (
	input						clk,
	input						rst_n,

	input						addr_start,
	input						inst_fetch,
	input		[3:0]				opCode,
	input		[8:0]				offset,
	input		[15:0]				addr_in,
	input						wea_in,
	input		[15:0]				pc,
	input		[15:0]				mem_in,
	input		[15:0]				reg_in,

	output	reg	[15:0]				addr_out,
	output	reg					wea_out
);

localparam      ADD                     		= 4'b0001,
                AND                     		= 4'b0101,
                NOT                     		= 4'b1001,
                LD                      		= 4'b0010,
                LDR                     		= 4'b0110,
                LDI                     		= 4'b1010,
                LEA                     		= 4'b1110,
                ST                      		= 4'b0011,
                STR                     		= 4'b0111,
                STI                     		= 4'b1011,
                BR                      		= 4'b0000,
                JMP                     		= 4'b1100,
                HALT                    		= 4'b1111;

reg		indirect_step;
always @ (posedge clk) begin
	if (!rst_n) begin
		addr_out				<= 0;
		wea_out					<= 0;
		indirect_step				<= 0;
	end
	else begin
		if (addr_start) begin
			if (inst_fetch) begin
				addr_out		<= addr_in;
				wea_out			<= wea_in;
			end
			else begin
				case (opCode)
				LD, ST: addr_out	<= pc + (~{{7{offset[8]}}, offset} + 1);
				LDR, STR: addr_out	<= reg_in + (~{{7{offset[8]}}, offset} + 1);
				LDI, STI: begin
					if (indirect_step == 0) 
						addr_out<= pc + (~{{7{offset[8]}}, offset} + 1);
					else
						addr_out<= mem_in;
				end
				LEA: addr_out		<= pc + (~{{7{offset[8]}}, offset} + 1);
				default: addr_out	<= 0;
				endcase

				case (opCode)
				LD, LDR, LDI: wea_out	<= 0;
				ST, STR: wea_out	<= 1;
				STI: begin
					if (indirect_step == 0)
                                                wea_out	<= 0;
					else
                                                wea_out	<= 1;
				end
				default: wea_out	<= 0;
				endcase

				case (opCode)
				LDI, STI: indirect_step	<= ~indirect_step;
				default: indirect_step	<= 0;
				endcase
			end
		end
	end
end

endmodule
