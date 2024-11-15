`timescale 1ns/1ps

module RISCV_PROCESSOR_TB;
	reg clk;
	reg reset;
	wire [31:0] res;
	
	SINGLE_CYLE_RISC_V riscv_dut(.clk(clk),.reset(reset),.res(res));
	
	always #5 clk = ~clk;
	
	initial begin
		$finish;
		clk = 1'b0;
		reset = 1'b0;
		#100
		reset = 1'b1;
		#1000
		$finish;
	end
	
	initial begin
		$monitor("Result = %d", res);
	end
endmodule