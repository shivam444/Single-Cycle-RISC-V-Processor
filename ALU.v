module ALU#(parameter INSTRUCTION_LEN = 32, N = 32)(input [INSTRUCTION_LEN-1:0] instruction, input [1:0] alu_op, input [N-1:0] data_1, input [N-1:0] data_2, output reg signed [N-1:0] data_out, output reg overflow);
	
	localparam R_FORMAT = 7'd51;
	localparam I_FORMAT = 7'd3;
	localparam S_FORMAT = 7'd35;
	localparam B_FORMAT = 7'd99;
	localparam LUI = 7'd55;
	localparam AUIPC = 7'd23;
	localparam JAL = 7'd111;
	localparam JALR = 7'd103;
	localparam AI_FORMAT = 7'd19;
	
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
	
	wire signed [N-1:0] signed_data_1;
	wire signed [N-1:0] signed_data_2;
	reg [N-1:0] temp_data_out;
	
	reg [3:0] alu_control;
	wire [6:0] funct7;
	wire[2:0] funct3;
	wire [6:0] opcode;
	
	assign opcode = instruction[6:0];
	assign signed_data_1 = data_1;
	assign signed_data_2 = data_2;
	assign funct7 = instruction[31:25];
	assign funct3 = instruction[14:12];
	
	always@*begin
		case(alu_op)
			2'b00: alu_control = 4'b0010;
			2'b01: alu_control = 4'b0110;
			2'b10: begin
					if(opcode == R_FORMAT)begin
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
					end
					else if(opcode == AI_FORMAT)begin
						case(funct3)
							3'b000: alu_control = ADD;
							3'b111: alu_control = AND;
							3'b110: alu_control = OR;
							3'b100: alu_control = XOR;
							3'b001: alu_control = LOGIC_LEFT;
							3'b101: begin
										if(funct7 == 7'h00)begin
											alu_control = LOGIC_RIGHT;
										end
										else if(funct7 == 7'h20)begin
											alu_control = ARITH_RIGHT;
										end
										else begin
											alu_control = 'bx;
										end
									end
							3'b010: alu_control = SET_LESS_THAN;
							3'b011: alu_control = SET_LESS_THAN_U;
							default : alu_control = 'bx;
						endcase
					end
					else begin
						alu_control = 'bx;
					end
					end
			default: alu_control = 'bx;
		endcase
	end
	
	always@*begin
		if(opcode == AI_FORMAT)begin
			case(alu_control)
				AND: {overflow,data_out} = data_1 & data_2;
				OR: {overflow,data_out} = data_1 | data_2;
				ADD: {overflow,data_out} = data_1 + data_2;
				SUB: {overflow,data_out} = data_1 - data_2;
				XOR: {overflow,data_out} = data_1 ^ data_2;
				LOGIC_LEFT: {overflow,data_out} = data_1 << data_2[4:0];
				LOGIC_RIGHT: begin
								{overflow,temp_data_out} = data_1>>>data_2[4:0];
								data_out = temp_data_out;
							end
				ARITH_RIGHT: {overflow,data_out} = data_1>>data_2[4:0];
				SET_LESS_THAN: {overflow,data_out} = (signed_data_1 < signed_data_2)?1'b1:1'b0;
				SET_LESS_THAN_U: {overflow,data_out} = (data_1 < data_2)?1'b1:1'b0;
				default: {overflow,data_out} = 'b0;
			endcase
		end
		else begin
			case(alu_control)
				AND: {overflow,data_out} = data_1 & data_2;
				OR: {overflow,data_out} = data_1 | data_2;
				ADD: {overflow,data_out} = data_1 + data_2;
				SUB: {overflow,data_out} = data_1 - data_2;
				XOR: {overflow,data_out} = data_1 ^ data_2;
				LOGIC_LEFT: {overflow,data_out} = data_1 << data_2;
				LOGIC_RIGHT: begin
								{overflow,temp_data_out} = data_1>>>data_2;
								data_out = temp_data_out;
							end
				ARITH_RIGHT: {overflow,data_out} = data_1>>data_2;
				SET_LESS_THAN: {overflow,data_out} = (signed_data_1 < signed_data_2)?1'b1:1'b0;
				SET_LESS_THAN_U: {overflow,data_out} = (data_1 < data_2)?1'b1:1'b0;
				default: {overflow,data_out} = 'b0;
			endcase
		end
	end
	
endmodule