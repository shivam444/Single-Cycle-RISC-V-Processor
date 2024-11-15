module INSTRUCTION_MEMORY#(parameter ADDRESS_SIZE = 10, N = 32)(input clk, input rst, input [ADDRESS_SIZE-1:0] rd_addr, output [N-1:0] instruction);
	
	//reg [N-1:0]instruction_memory[(2**ADDRESS_SIZE)-1:0];
	integer i;
	wire [ADDRESS_SIZE-1:0] a;
	wire [N-1:0] spo;
	
	instructuion_mem instruction_mem_unit (
  .a(a),      // input wire [9 : 0] a
  .spo(spo)  // output wire [31 : 0] spo
);
    assign a = rd_addr>>2;
	assign instruction = ~(rd_addr[1]|rd_addr[0])?spo:{16'b0,spo[31:16]};
	
//	always@(posedge clk or negedge rst)begin
//		if(~rst)begin
//			instruction_memory[0] <= 32'b00000000000100010000000110110011;//R format
//			instruction_memory[1] <= 32'b00000000000000000000000110000011;//LOAD
//			instruction_memory[2] <= 32'b00000000000100000000000010100011;//STORE
//			instruction_memory[3] <= 32'b11111110000100010000111011100011;//BEQ
//			instruction_memory[4] <= 32'b00000000000000000100000110110111;//LUI
//			instruction_memory[5] <= 32'b00000000010000000000000101101111;//JAL
//			instruction_memory[6] <= 32'b00000000010000010000000111100111;//JALR
//			instruction_memory[7] <= 32'b00000000000000000001000110010111;//AUIPC
//			instruction_memory[8] <= 32'b00001001000100010000000010010011;//ADDI
//			instruction_memory[9] <= 32'b00001000101100001000000100000011;//LOAD BYTE
//			instruction_memory[10] <= 32'b00001000101100001001000100000011;//LOAD HALF
//			instruction_memory[11] <= 32'b00000000001100000000001000100011;//STORE BYTE
//			instruction_memory[12] <= 32'b00000001111100000001001100100011;//STORE HALF
//			instruction_memory[13] <= 32'b01000000000100101101000110110011;//SHIFT RIGHT ARITH
//			instruction_memory[14] <= 32'b00000000000100101101000110110011;//SHIFT RIGHT LOGIC
//		end
//	end
endmodule