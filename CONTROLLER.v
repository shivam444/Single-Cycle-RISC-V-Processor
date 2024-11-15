module CONTROLLER#(parameter INSTRUCTION_LEN = 32)(input [INSTRUCTION_LEN-1:0] instruction, output reg pc_src, output reg mem_read, output reg mem_to_reg, output reg pc_to_alu, output reg [1:0] alu_op, output reg mem_write, output reg alu_src, output reg reg_write, output reg reg_write_src, output reg imm_to_reg, output reg alu_to_pc);

	localparam R_FORMAT = 7'd51;
	localparam I_FORMAT = 7'd3;
	localparam S_FORMAT = 7'd35;
	localparam B_FORMAT = 7'd99;
	localparam LUI = 7'd55;
	localparam AUIPC = 7'd23;
	localparam JAL = 7'd111;
	localparam JALR = 7'd103;
	localparam AI_FORMAT = 7'd19;
	
	wire [6:0] opcode;
	wire [6:0] funct7;
	wire [2:0] funct3;
	
	assign opcode = instruction[6:0];
	
	always@* begin
		case(opcode)
			R_FORMAT: begin
						pc_src = 1'b0;
						mem_read = 1'b0;
						mem_write = 1'b0;
						mem_to_reg = 1'b0;
						alu_op = 2'b10;
						alu_src = 1'b0;//From register file
						reg_write = 1'b1;
						reg_write_src = 1'b0;//From write back stage
						alu_to_pc = 1'b0;
						imm_to_reg = 1'b0;
						pc_to_alu = 1'b0;
					end
			I_FORMAT: begin
						pc_src = 1'b0;
						mem_read = 1'b1;
						mem_write = 1'b0;
						mem_to_reg = 1'b1;
						alu_op = 2'b00;
						alu_src = 1'b1;//From immediate
						reg_write = 1'b1;
						reg_write_src = 1'b0;//From write back stage
						alu_to_pc = 1'b0;
						imm_to_reg = 1'b0;
						pc_to_alu = 1'b0;
					end
			S_FORMAT: begin
						pc_src = 1'b0;
						mem_read = 1'b0;
						mem_write = 1'b1;
						mem_to_reg = 1'bx;
						alu_op = 2'b00;
						alu_src = 1'b1;//From immediate
						reg_write = 1'b0;
						reg_write_src = 1'bx;//From write back stage
						alu_to_pc = 1'b0;
						imm_to_reg = 1'b0;
						pc_to_alu = 1'b0;
					end
			B_FORMAT: begin
						pc_src = 1'b1;
						mem_read = 1'b0;
						mem_write = 1'b0;
						mem_to_reg = 1'bx;
						alu_op = 2'b01;
						alu_src = 1'b0;//From register file
						reg_write = 1'b0;
						reg_write_src = 1'bx;//From write back stage
						alu_to_pc = 1'b0;
						imm_to_reg = 1'b0;
						pc_to_alu = 1'b0;
					end
			LUI: begin
						pc_src = 1'b0;
						mem_read = 1'b0;
						mem_write = 1'b0;
						mem_to_reg = 1'b0;
						alu_op = 2'bxx;
						alu_src = 1'bx;
						reg_write = 1'b1;
						reg_write_src = 1'b0;//From write back stage
						alu_to_pc = 1'b0;
						imm_to_reg = 1'b1;//From immediate to register file
						pc_to_alu = 1'b0;
					end
			AUIPC: begin
						pc_src = 1'b0;
						mem_read = 1'b0;
						mem_write = 1'b0;
						mem_to_reg = 1'b0;
						alu_op = 2'b00;
						alu_src = 1'b1;
						reg_write = 1'b1;
						reg_write_src = 1'b0;
						alu_to_pc = 1'b0;
						imm_to_reg = 1'b0;//From immediate to register file
						pc_to_alu = 1'b1;
					end
			JAL: begin
						pc_src = 1'b1;
						mem_read = 1'b0;
						mem_write = 1'b0;
						mem_to_reg = 1'b0;
						alu_op = 2'bxx;
						alu_src = 1'bx;
						reg_write = 1'b1;
						reg_write_src = 1'b1;//From PC+4
						alu_to_pc = 1'b0;
						imm_to_reg = 1'b0;//From immediate to register file
						pc_to_alu = 1'b0;
					end
			JALR: begin
						pc_src = 1'b1;
						mem_read = 1'b0;
						mem_write = 1'b0;
						mem_to_reg = 1'b0;
						alu_op = 2'b00;
						alu_src = 1'b1;//From immediate
						reg_write = 1'b1;
						reg_write_src = 1'b1;//From PC+4
						alu_to_pc = 1'b1;
						imm_to_reg = 1'b0;//From immediate to register file
						pc_to_alu = 1'b0;
					end
			AI_FORMAT: begin
						pc_src = 1'b0;
						mem_read = 1'b0;
						mem_write = 1'b0;
						mem_to_reg = 1'b0;
						alu_op = 2'b10;
						alu_src = 1'b1;//From immediate
						reg_write = 1'b1;
						reg_write_src = 1'b0;//From write back stage
						alu_to_pc = 1'b0;
						imm_to_reg = 1'b0;//From immediate to register file
						pc_to_alu = 1'b0;
					end
			default: begin
						pc_src = 1'b0;
						mem_read = 1'b0;
						mem_write = 1'b0;
						mem_to_reg = 1'b0;
						alu_op = 2'b00;
						alu_src = 1'b0;
						reg_write = 1'b0;
						reg_write_src = 1'b0;//From write back stage
						alu_to_pc = 1'b0;
						imm_to_reg = 1'b0;//From immediate to register file
						pc_to_alu = 1'b0;
					end
		endcase
	end
endmodule