module DATA_MEMORY#(parameter ADDRESS_SIZE = 12, N = 32)(input clk, input rst, input mem_read,input mem_write, input [2:0] word_control, input [ADDRESS_SIZE - 1:0] rd_addr, input [ADDRESS_SIZE-1:0] wr_addr, input [N-1:0] data_in, output reg [N-1:0] data_out);

	localparam BYTE = 3'b000;
	localparam HALF = 3'b001;
	localparam WORD = 3'b010;
	localparam BYTE_U = 3'b100;
	localparam HALF_U = 3'b101;
	//reg [N-1:0]data_mem[(2**ADDRESS_SIZE)-1:0];
	//reg [N-1:0] temp_data;
	wire [ADDRESS_SIZE-1:0] a;
	wire [N-1:0] spo;
	reg [N-1:0] mem_data_in;
	//integer i;
	
	data_memory data_memory_unit (
  .a(a),      // input wire [11 : 0] a
  .d(data_in),      // input wire [31 : 0] d
  .clk(clk),  // input wire clk
  .we(mem_write),    // input wire we
  .spo(spo)  // output wire [31 : 0] spo
);

    assign a = rd_addr>>2;
	//assign data_out = mem_read ? data_mem[rd_addr] : 'b0;
	
	always@*begin
		if(mem_read)begin
			case(word_control)
				BYTE: begin
						case({rd_addr[1], rd_addr[0]})
							2'b00: data_out = {{24{spo[7]}}, spo[7:0]};
							2'b01: data_out = {{24{spo[15]}}, spo[15:8]};
							2'b10: data_out = {{24{spo[23]}}, spo[23:16]};
							2'b11: data_out = {{24{spo[31]}}, spo[31:24]};
							default: data_out = 'bx;
						endcase
					end
				HALF: begin
						case(rd_addr[1])
							1'b0: data_out = {{16{spo[15]}}, spo[15:0]};
							1'b1: data_out = {{16{spo[31]}}, spo[31:16]};
							default: data_out = 'bx;
						endcase
					end
				WORD: data_out = spo;
				BYTE_U: begin
							case({rd_addr[1], rd_addr[0]})
							2'b00: data_out = {24'b0, spo[7:0]};
							2'b01: data_out = {24'b0, spo[15:8]};
							2'b10: data_out = {24'b0, spo[23:16]};
							2'b11: data_out = {24'b0, spo[31:24]};
							default: data_out = 'bx;
						endcase
					end
				HALF_U: begin
							case(rd_addr[1])
							1'b0: data_out = {16'b0, spo[15:0]};
							1'b1: data_out = {16'b0, spo[31:16]};
							default: data_out = 'bx;
						endcase
					end
				default: data_out = 'bx;
			endcase
		end
		else begin
			data_out = 'bx;
		end
	end					
	
/* 	always@* begin
		case(word_control)
			BYTE: temp_data = {24'b0, data_in[7:0]};
			HALF: temp_data[15:0] = {16'b0, data_in[15:0]};
			WORD: temp_data = data_in;
			default: temp_data = data_in;
		endcase
	end */
	
	always@* begin
		if(mem_write)begin
			case(word_control)
				BYTE: begin
						case({wr_addr[1],wr_addr[0]})
							2'b00: mem_data_in[7:0] = {spo[31:8], data_in[7:0]};
							2'b01: mem_data_in[15:8] = {spo[31:8], data_in[7:0]};
							2'b10: mem_data_in[23:16] = {spo[31:8], data_in[7:0]};
							2'b11: mem_data_in[31:24] = {spo[31:8], data_in[7:0]};
							default: mem_data_in = spo;
						endcase
					end
				HALF: begin
						case(wr_addr[1])
							1'b0: mem_data_in[15:0] = {spo[31:16], data_in[15:0]};
							1'b1: mem_data_in[31:16] = {spo[31:16], data_in[15:0]};
							default: mem_data_in = spo;
						endcase
					end
				WORD: begin
						mem_data_in = data_in;
					end
				default: mem_data_in = 'bx;
			endcase
		end
		else begin
			mem_data_in = 'bx;
		end
	end
endmodule
	