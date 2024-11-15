module REGISTER_FILE#(parameter ADDRESS_LEN = 5, N= 32)(input clk, input rst, input reg_write, input [ADDRESS_LEN-1:0] rd_addr_1, input [ADDRESS_LEN-1:0] rd_addr_2, input [ADDRESS_LEN-1:0] wr_addr, input [N-1:0] data, output [N-1:0] rd_data_1, output [N-1:0] rd_data_2);

	reg [N-1:0]mem[(2**ADDRESS_LEN)-1:0];
	reg [N-1:0] temp_data;
	integer i;
	
	always@*begin
		if(reg_write)begin
			temp_data = data;
		end
		else begin
			temp_data = mem[wr_addr];
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			for(i = 0;i<2**ADDRESS_LEN;i = i+1)begin
				mem[i] <= 0;
			end
			//mem[5] <= -5;
		end
		else if(wr_addr != 'b0) begin
			mem[wr_addr] <= temp_data;
		end
	end
	
	assign rd_data_1 = mem[rd_addr_1];
	assign rd_data_2 = mem[rd_addr_2];
	
endmodule
			
		