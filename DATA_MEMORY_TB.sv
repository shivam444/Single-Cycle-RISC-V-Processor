module DATA_MEMORY_TB;

	parameter ADDRESS_SIZE = 10; 
	parameter N = 32;
	
	localparam BYTE = 3'b000;
	localparam HALF = 3'b001;
	localparam WORD = 3'b010;
	localparam BYTE_U = 3'b100;
	localparam HALF_U = 3'b101;
	
	reg [N-1:0]data_mem[(2**ADDRESS_SIZE)-1:0];
	
	bit clk; always #5 clk = ~clk;
	bit rst; 
	logic mem_read;
	logic mem_write; 
	logic [2:0] word_control; 
	logic [ADDRESS_SIZE - 1:0] rd_addr; 
	logic [ADDRESS_SIZE-1:0] wr_addr; 
	logic [N-1:0] data_in; 
	logic signed [N-1:0] data_out;
	logic signed [N-1:0] data_expected;
	
	int word_arr[5] = '{3'b000, 3'b001, 3'b010, 3'b100, 3'b101};
	int word_control_index;
	
	int i;
	int iterations = 100;
	
	DATA_MEMORY#(.ADDRESS_SIZE(ADDRESS_SIZE),.N(N)) data_mem_dut(.*);
	
	initial begin
		rst = 1'b0;
		repeat(10)@(posedge clk);
		#2
		rst = 1'b1;
		repeat(10)@(posedge clk);
		#2
		repeat(10000)@(posedge clk)begin
			write;
		end
		repeat(10)@(posedge clk);
		#2
		repeat(iterations)@(posedge clk)begin
			read;
		end
		repeat(10)@(posedge clk);
		#2
		print;
		repeat(10)@(posedge clk);
		#2
		$finish;
	end
	
	task write;
		mem_write = 1'b1;
		mem_read = 1'b0;
		word_control = 'bxx;
		rd_addr = 'bxx;
		wr_addr = $urandom%1024;
		data_in = $random;
		repeat(1)@(posedge clk);
		data_mem[wr_addr] = data_in;
		
	endtask
	
	task read;
		mem_write = 1'b0;
		mem_read = 1'b1;
		word_control_index = $urandom%5;
		word_control = word_arr[word_control_index];
		rd_addr = $urandom%1024;
		case(word_control)
			BYTE: begin
					case({rd_addr[1], rd_addr[0]})
						2'b00: data_expected = {{24{data_mem[rd_addr][7]}}, data_mem[rd_addr][7:0]};
						2'b01: data_expected = {{24{data_mem[rd_addr][15]}}, data_mem[rd_addr][15:8]};
						2'b10: data_expected = {{24{data_mem[rd_addr][23]}}, data_mem[rd_addr][23:16]};
						2'b11: data_expected = {{24{data_mem[rd_addr][31]}}, data_mem[rd_addr][31:24]};
						default: data_expected = 'bx;
					endcase
				end
			HALF: begin
					case(rd_addr[1])
						1'b0: data_expected = {{16{data_mem[rd_addr][15]}}, data_mem[rd_addr][15:0]};
						1'b1: data_expected = {{16{data_mem[rd_addr][31]}}, data_mem[rd_addr][31:16]};
						default: data_expected = 'bx;
					endcase
				end
			WORD: data_expected = data_mem[rd_addr];
			BYTE_U: begin
						case({rd_addr[1], rd_addr[0]})
						2'b00: data_expected = {24'b0, data_mem[rd_addr][7:0]};
						2'b01: data_expected = {24'b0, data_mem[rd_addr][15:8]};
						2'b10: data_expected = {24'b0, data_mem[rd_addr][23:16]};
						2'b11: data_expected = {24'b0, data_mem[rd_addr][31:24]};
						default: data_expected = 'bx;
					endcase
				end
			HALF_U: begin
						case(rd_addr[1])
						1'b0: data_expected = {16'b0, data_mem[rd_addr][15:0]};
						1'b1: data_expected = {16'b0, data_mem[rd_addr][31:16]};
						default: data_expected = 'bx;
					endcase
				end
			default: data_expected = 'bx;
		endcase
		#1
		if(data_expected == data_out)begin
			i++;
		end
		else begin
			$display("Expected data = %d, output data = %d", data_expected, data_out);
		end
	endtask
	
	task print;
		if(i == iterations)begin
			$display("Success");
		end
		else begin
			$display("Failure, passed = %d/%d", i,iterations);
		end
	endtask
endmodule