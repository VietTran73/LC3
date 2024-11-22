`timescale 1ps/1ps 

module tb_fetch_BRn_no_start ();
	reg              clk;
        reg              rst_n;

        reg              fetch_start;
        reg      [3:0]   opCode_in;
        reg      [8:0]   offset_in;
        reg      [15:0]  reg_in;
        reg      [2:0]   br_nzp;
        reg      [2:0]   result_nzp;

        wire     [15:0]  addr_out;
        wire             wea_out;
        wire     [15:0]  pc;

integer f_out;

fetch fetch_i (
	.clk(clk),
	.rst_n(rst_n),
	.fetch_start(fetch_start),
	.opCode_in(opCode_in),
	.offset_in(offset_in),
	.reg_in(reg_in),
	.br_nzp(br_nzp),
	.result_nzp(result_nzp),
	.addr_out(addr_out),
	.wea_out(wea_out),
	.pc(pc)
	
); 

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin 
	f_out = $fopen("output/tb_fetch_BRn_no_start.txt", "w");
	
	rst_n = 0;
	opCode_in = 4'b0000;
	fetch_start = 0;
	repeat (5) @ (posedge clk);
	rst_n = 1;

	if ((addr_out == 0) & (wea_out == 0) & (pc == 0))
	begin
		$display ("run correctly\n");
		$fwrite (f_out, "PASS\n");
	//	$fclose(f_out);
	//	$finish;
	end	
	else begin
		$display ("run incorrectly\n");
		$fwrite (f_out, "FAIL\n");
	//	$fclose(f_out);
	//	$finish;
	end
	$fclose(f_out);
	$finish;
end	
endmodule 
