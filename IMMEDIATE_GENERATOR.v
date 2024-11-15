module immediate_GENERATOR#(parameter INSTRUCTION_LEN = 32, immediate_LEN = 32)(input [INSTRUCTION_LEN-1:0] instruction, output reg [immediate_LEN-1:0] immediate);
	
	localparam R_FORMAT = 7'd51;
	localparam I_FORMAT = 7'd3;
	localparam S_FORMAT = 7'd35;
	localparam B_FORMAT = 7'd99;
	localparam LUI = 7'd55;
	localparam AUIPC = 7'd23;
	localparam JAL = 7'd111;
	localparam JALR = 7'd103;
	localparam AI_FORMAT = 7'd19;
	
	always@*begin
		case(instruction[6:0])
			B_FORMAT : immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8],1'b0};
			I_FORMAT : immediate = {{20{instruction[31]}}, instruction[31:20]};
			S_FORMAT : immediate = {{20{instruction[31]}}, instruction[31:25] , instruction[11:7]};
			AI_FORMAT: immediate = {{20{instruction[31]}}, instruction[31:20]};
			LUI: immediate = {instruction[31:12], 12'b0};
			AUIPC: immediate = {instruction[31:12], 12'b0};
			JAL: immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
			JALR: immediate = {{20{instruction[31]}}, instruction[31:20]};
			default : immediate = 'b0;
		endcase
	end
endmodule