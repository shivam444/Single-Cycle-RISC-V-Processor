module PROGRAM_COUNTER#(parameter ADDRESS_SIZE = 10, N = 32)(input clk, input rst, input alu_to_pc, input pc_src, input [N-1:0] immediate, input [N-1:0] alu_out, output reg [ADDRESS_SIZE-1:0] instruction_ptr);

	reg [(ADDRESS_SIZE)-1:0] next_pc;
	//wire signed [12:0] offset;
	
	//assign offset = offset_addr<<1;

	
	always@*begin
		if(~pc_src)begin
			next_pc = instruction_ptr + 3'b100;
		end
		else if(pc_src)begin
			if(alu_to_pc)begin
				next_pc = alu_out;
			end
			else begin
				next_pc = instruction_ptr + immediate;
			end
		end
		else begin
			next_pc = instruction_ptr;
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			instruction_ptr <= 'b0;
		end
		else begin
			instruction_ptr <= next_pc;
		end
	end
endmodule