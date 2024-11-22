/*`timescale 1ps/1ps

module tb_LC3_add ();

reg	clk, rst_n;
reg	start;

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin
	rst_n = 0;
	start = 0;

	#100;
	@ (posedge clk);
	rst_n = 1;

	#10;
	@ (posedge clk);
	start = 1;
	@ (posedge clk);
	start = 0;

	wait (tb_LC3_add.LC3_i.halt == 1);
	#50;
	$stop;
end

initial begin
	wait (rst_n == 1);
	#10000;
	$stop;
end

LC3 LC3_i (
	.clk(clk),
	.rst_n(rst_n),
	.start(start)
);

endmodule
*/
