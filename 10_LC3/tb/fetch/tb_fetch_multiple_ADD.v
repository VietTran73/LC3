`timescale 1ps/1ps 

module tb_fetch_multiple_ADD ();
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
	f_out = $fopen("output/tb_fetch_multiple_ADD.txt", "w");
	
	rst_n = 0;
	opCode_in = 4'b0001;
//	fetch_start = 0;
//	reg_in = 9'd5;
	repeat (5) @ (posedge clk);
	rst_n = 1;
	
//	1st check
	@ (posedge clk);
        fetch_start = 1;
        @ (posedge clk);
        fetch_start = 0;

	if ((addr_out == 0) & (wea_out == 0) & (pc == 1))
	begin
		$display ("run correctly\n");
		$fwrite (f_out, "1st check PASS\n");
	//	$fclose(f_out);
	//	$finish;
	end	
	else begin
		$display ("run incorrectly\n");
		$fwrite (f_out, "1st check FAIL\n");
	//	$fclose(f_out);
	//	$finish;
	end
	$fclose(f_out);
	$finish;

	// 2nd check 
	#50;

        @ (posedge clk);
        fetch_start = 1;
        @ (posedge clk);
        fetch_start = 0;

        if ((addr_out == 1) & (wea_out == 0) & (pc == 2))
        begin
                $display ("run correctly\n");
                $fwrite (f_out, "2nd check PASS\n");
        //      $fclose(f_out);
        //      $finish;
        end
        else begin
                $display ("run incorrectly\n");
                $fwrite (f_out, "2nd check FAIL\n");
        //      $fclose(f_out);
        //      $finish;
        end
        $fclose(f_out);
        $finish;

	
end	
endmodule 
