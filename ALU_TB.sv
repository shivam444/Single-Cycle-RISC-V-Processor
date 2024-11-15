`timescale 1ns/1ps

module ALU_TB;

	parameter INSTRUCTION_ADDR_SIZE = 5; 
	parameter N = 32;
	
	localparam ADD = 4'b0010;
	localparam SUB = 4'b0110;
	localparam AND = 4'b0000;
	localparam OR = 4'b0001;
	localparam XOR = 4'b0111;
	localparam LOGIC_LEFT = 4'b1000;
	localparam LOGIC_RIGHT = 4'b1001;
	localparam ARITH_RIGHT = 4'b1010;
	localparam SET_LESS_THAN = 4'b1011;
	localparam SET_LESS_THAN_U = 4'b1100;
	
	logic [(2**INSTRUCTION_ADDR_SIZE)-1:0] instruction; 
	logic [1:0] alu_op; 
	logic [N-1:0] data_1; 
	logic [N-1:0] data_2; 
	logic signed [N-1:0] data_out;
	logic [6:0] funct7;
	logic [2:0] funct3;
	logic [3:0] alu_control;
	int index7, index3;
	int check_val;
	int i,j;
	int iterations = 100;
	logic signed [N-1:0] signed_data_1;
	logic signed [N-1:0] signed_data_2;
	
	ALU#(.INSTRUCTION_ADDR_SIZE(INSTRUCTION_ADDR_SIZE), .N(N)) alu_dut(.*);
	
	int funct7_vals[2] = '{7'h00, 7'h20};
	int funct3_vals[8] = '{3'h0, 3'h1, 3'h2, 3'h3, 3'h4, 3'h5, 3'h6, 3'h7};
	
	initial begin
		repeat(iterations)begin
			check;
		end
		print;
	end
	
	task check;
		alu_op = 'b10;
		data_1 = $urandom;
		data_2 = $urandom;
		index7 = $urandom%2;
		index3 = $urandom%8;
		funct7 = funct7_vals[index7];
		funct3 = funct3_vals[index3];
		signed_data_1 = data_1;
		signed_data_2 = data_2;
		instruction = {funct7, 5'b0, 5'b0, funct3, 5'b0, 7'b0110011};
		case({funct7,funct3})
			10'b0000000000: alu_control = ADD;
			10'b0100000000: alu_control = SUB;
			10'b0000000111: alu_control = AND;
			10'b0000000110: alu_control = OR;
			10'b0000000100: alu_control = XOR;
			10'b0000000001: alu_control = LOGIC_LEFT;
			10'b0000000101: alu_control = LOGIC_RIGHT;
			10'b0100000101: alu_control = ARITH_RIGHT;
			10'b0000000010: alu_control = SET_LESS_THAN;
			10'b0000000011: alu_control = SET_LESS_THAN_U;
			default : alu_control = 'bx;
		endcase
		case(alu_control)
			AND: check_val = data_1 & data_2;
			OR: check_val = data_1 | data_2;
			ADD: check_val = data_1 + data_2;
			SUB: check_val = data_1 - data_2;
			XOR: check_val = data_1 ^ data_2;
			LOGIC_LEFT: check_val = data_1 << data_2;
			LOGIC_RIGHT: check_val = data_1>>data_2;
			ARITH_RIGHT: check_val = data_1>>>data_2;
			SET_LESS_THAN: check_val = (signed_data_1 < signed_data_2)?1'b1:1'b0;
			SET_LESS_THAN_U: check_val = (data_1 < data_2)?1'b1:1'b0;
			default: check_val = 'b0;
		endcase
		#3
		//$display("Output = %d, Expected = %d", data_out, check_val);
		if(data_out == check_val)begin
			i++;
		end
		else begin
			$display("ALU control = %d", alu_control);
		end
	endtask
	
	task print;
		if(i == iterations)begin
			$display("Success");
		end
		else begin
			$display("Failure, %d/%d passed", i, iterations);
		end
	endtask
	
endmodule