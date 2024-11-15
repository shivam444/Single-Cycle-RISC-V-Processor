module SINGLE_CYLE_RISC_V#(parameter INSTRUCTION_LEN = 32, DATA_LEN = 32)(input clock, input reset, output [3:0] Anode_Activate,output [6:0] LED_out);
//module SINGLE_CYLE_RISC_V#(parameter INSTRUCTION_LEN = 32, DATA_LEN = 32)(input clk, input reset, output reg [DATA_LEN-1:0] res);	
	//Generating Reset
	reg [1:0] reset_sync;
	wire rst; //Async reset signal (Synchronized)
	reg clk_counter;
	reg [DATA_LEN-1:0] print_val;
	wire clk;//40MHz clock
	
//	always@(posedge clock or negedge reset)begin
//	   if(~reset)begin
//	       clk_counter <= 'b0;
//       end
//       else begin
//            clk_counter <= clk_counter + 1'b1;
//        end
//	end
//	assign clk = clk_counter;
	  clk_40M clk_40M_dut
   (
    // Clock out ports
    .clk_out1(clk),     // output clk_out1
   // Clock in ports
    .clk_in1(clock)      // input clk_in1
);
	reg [DATA_LEN-1:0] res;
	
	always@(posedge clk or negedge reset)begin
		if(~reset)begin
			reset_sync <= 'b0;
		end
		else begin
			reset_sync[1] <= 1'b1;
			reset_sync[0] <= reset_sync[1];
		end
	end
	assign rst = reset_sync[0];
	//Till here
	
	localparam R_FORMAT = 7'd51;
	localparam I_FORMAT = 7'd3;
	localparam S_FORMAT = 7'd35;
	localparam B_FORMAT = 7'd99;
	localparam LUI = 7'd55;
	localparam AUIPC = 7'd23;
	localparam JAL = 7'd111;
	localparam JALR = 7'd103;
	localparam AI_FORMAT = 7'd19;
	
	localparam ADDRESS_SIZE = 10;
	localparam REGISTER_FILE_SIZE = 5;
	localparam DATA_MEMORY_SIZE = 12;
	
	wire [6:0] opcode;
	wire [ADDRESS_SIZE-1:0] instruction_ptr;
	wire [INSTRUCTION_LEN-1:0] instruction;
	wire [DATA_LEN-1:0] immediate;
	wire pc_src; 
	wire mem_read; 
	wire mem_to_reg; 
	wire [1:0] alu_op; 
	wire mem_write; 
	wire alu_src; 
	wire reg_write; 
	wire reg_write_src; 
	wire imm_to_reg; 
	wire alu_to_pc;
	wire pc_to_alu;
	wire [REGISTER_FILE_SIZE-1:0] reg_rd_addr_1;
	wire [REGISTER_FILE_SIZE-1:0] reg_rd_addr_2;
	wire [REGISTER_FILE_SIZE-1:0] reg_wr_addr;
	wire [DATA_LEN-1:0] reg_data_in;
	wire [DATA_LEN-1:0] reg_rd_data_1;
	wire [DATA_LEN-1:0] reg_rd_data_2;
	wire [DATA_LEN-1:0] alu_in_1;
	wire [DATA_LEN-1:0] alu_in_2;
	wire [DATA_LEN-1:0] alu_data_out;
	wire [DATA_LEN-1:0] data_mem_data_out;
	wire [DATA_LEN-1:0] val_write_back;
	wire alu_overflow;
	wire zero;
	wire less_equal;
	//wire greater;
	reg branch_taken;
	
	//reg [6:0] funct7;
	wire [2:0] funct3;
	wire [REGISTER_FILE_SIZE-1:0] rs1;
	wire [REGISTER_FILE_SIZE-1:0] rs2;
	wire [REGISTER_FILE_SIZE-1:0] rd;
	
	//assign funct7 = instruction[31:25];
	assign funct3 = instruction[14:12];
	assign rs1 = instruction[19:15];
	assign rs2 = instruction[24:20];
	assign rd = instruction[11:7];
	assign opcode = instruction[6:0];
	
	always@* begin
		if(opcode == B_FORMAT)begin
			case(funct3)
				3'b000: branch_taken = pc_src & zero;
				3'b001: branch_taken = pc_src &(~zero);
				3'b100: branch_taken = pc_src & less_equal;
				3'b101: branch_taken = pc_src &(~less_equal);
				3'b110: branch_taken = pc_src & less_equal;
				3'b111: branch_taken = pc_src &(~less_equal);
				default: branch_taken = 1'b0;
			endcase
		end
		else if((opcode == JAL) || (opcode == JALR))begin
			branch_taken = 1'b1;
		end
		else begin
			branch_taken = 1'b0;
		end
	end
	PROGRAM_COUNTER#(.ADDRESS_SIZE(ADDRESS_SIZE),.N(DATA_LEN)) program_counter(.clk(clk),.rst(rst),.alu_to_pc(alu_to_pc), .pc_src(branch_taken),.immediate(immediate),.alu_out(alu_data_out),.instruction_ptr(instruction_ptr));
	INSTRUCTION_MEMORY#(.ADDRESS_SIZE(ADDRESS_SIZE),.N(DATA_LEN)) instruction_memory(.clk(clk),.rst(rst),.rd_addr(instruction_ptr),.instruction(instruction));
	CONTROLLER#(.INSTRUCTION_LEN(INSTRUCTION_LEN)) controller(.instruction(instruction),.pc_src(pc_src),.mem_read(mem_read),.mem_to_reg(mem_to_reg),.pc_to_alu(pc_to_alu),.alu_op(alu_op),.mem_write(mem_write),.alu_src(alu_src),.reg_write(reg_write),.reg_write_src(reg_write_src),.imm_to_reg(imm_to_reg),.alu_to_pc(alu_to_pc));
	immediate_GENERATOR#(.INSTRUCTION_LEN(INSTRUCTION_LEN),.immediate_LEN(DATA_LEN)) immediate_generator(.instruction(instruction),.immediate(immediate));
	
	assign reg_data_in = reg_write_src?(instruction_ptr+3'b100):val_write_back;
	assign val_write_back = imm_to_reg?immediate:mem_to_reg?data_mem_data_out:alu_data_out;
	
	assign reg_rd_addr_1 = rs1;
	assign reg_rd_addr_2 = rs2;
	assign reg_wr_addr = rd;
	
	REGISTER_FILE#(.ADDRESS_LEN(REGISTER_FILE_SIZE),.N(DATA_LEN)) register_file(.clk(clk),.rst(rst),.reg_write(reg_write),.rd_addr_1(reg_rd_addr_1),.rd_addr_2(reg_rd_addr_2),.wr_addr(reg_wr_addr),.data(reg_data_in),.rd_data_1(reg_rd_data_1),.rd_data_2(reg_rd_data_2));
	
	assign alu_in_1 = pc_to_alu? instruction_ptr:reg_rd_data_1;
	assign alu_in_2 = alu_src?immediate:reg_rd_data_2;
	
	ALU#(.INSTRUCTION_LEN(INSTRUCTION_LEN),.N(DATA_LEN)) alu(.instruction(instruction),.alu_op(alu_op),.data_1(alu_in_1),.data_2(alu_in_2),.data_out(alu_data_out),.overflow(alu_overflow));
	
	assign zero = ~|alu_data_out;
	assign less_equal = alu_overflow;
	
	DATA_MEMORY#(.ADDRESS_SIZE(DATA_MEMORY_SIZE),.N(DATA_LEN)) data_memory(.clk(clk),.rst(rst),.mem_read(mem_read),.mem_write(mem_write),.word_control(funct3),.rd_addr(alu_data_out),.wr_addr(alu_data_out),.data_in(reg_rd_data_2),.data_out(data_mem_data_out));

//	assign res = mem_to_reg?data_mem_data_out:alu_data_out;;
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			res <= 'b0;
		end
		else if((opcode != 'd00))  begin
			res <= val_write_back;
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			print_val <= 'b0;
		end
		else if((opcode == AI_FORMAT)||(opcode == R_FORMAT))  begin
			print_val <= alu_data_out;
		end
	end
	
	Seven_segment_LED_Display_Controller seven_seg_disp_dut(.clk(clk),.reset(rst),.res(print_val),.Anode_Activate(Anode_Activate),.LED_out(LED_out));
	
endmodule