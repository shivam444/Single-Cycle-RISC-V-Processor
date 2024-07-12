module PROGRAM_COUNTER#(parameter ADDRESS_SIZE = 6, N = 64)(input clk, input rst,input ins_write, input pc_src, input [11:0] offset_addr, output reg [(2**ADDRESS_SIZE)-1:0] instruction_ptr);

	reg [(2**ADDRESS_SIZE)-1:0] next_pc;
	
	always@*begin
		if(~pc_src)begin
			next_pc = instruction_ptr + 1'b1;
		end
		else if(pc_src)begin
			next_pc = instruction_ptr + (offset_addr<<1);
		end
		else begin
			next_pc = instruction_ptr;
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if((~rst) || ins_write)begin
			instruction_ptr <= 'b0;
		end
		else begin
			instruction_ptr <= next_pc;
		end
	end
endmodule