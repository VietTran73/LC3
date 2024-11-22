`timescale 1ps/1ps

module tb_example ();

LC3 LC3_i (
	.clk(clk),
	.rst_n(rst_n),
	.start(start)
);

initial begin 
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin 
	rst_n = 0;
	start = 0;
	
	#50;
	@ (posedge clk);
	rst_n = 1;
	#20;
	@ (posedge clk);
	start = 1;
	@ (posedge clk);
	start = 0;
	
	#5000;
	$finish;
end

endmodule 
