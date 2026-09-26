// core1, core3, core7 : 인접 코어 2개 (모서리)
module core1 (/*AUTOARG*/
   // Outputs
   temp_out,
   // Inputs
   clk, reset_n, temp, temp_in1, temp_in2
   );

   input logic clk, reset_n;
   input logic [7:0] temp, temp_in1, temp_in2;
   output logic [7:0] temp_out;

   logic [5:0]	      pc;              //wire
   logic [17:0]	      instr;

   logic [3:0]	      opcode, rs1, rs2;
   logic	      branch_taken, jump_taken, we, load1, load2, zero_flag;
   logic [5:0]	      branch_target, jump_target, rd;

   logic [7:0]	      out_rs1, out_rs2;

   logic [7:0]	      alu_result;

   logic [7:0]	      out_temp;  //regfile의 output

   pc_counter counter(
		      // Outputs
		      .pc		(pc),
		      // Inputs
		      .clk		(clk),
		      .reset_n		(reset_n),
		      .branch_taken	(branch_taken),
		      .jump_taken	(jump_taken),
		      .branch_target	(branch_target),
		      .jump_target	(jump_target));

   instruction_memory rom(
			  // Outputs
			  .instr		(instr),
			  // Inputs
			  .pc			(pc)
			  );

   control_unit control(
			// Outputs
			.opcode		(opcode),
			.rs1		(rs1),
			.rs2		(rs2),
			.rd		(rd),
			.branch_taken	(branch_taken),
			.jump_taken	(jump_taken),
			.we		(we),
			.load1		(load1),
			.load2		(load2),
			.branch_target	(branch_target),
			.jump_target	(jump_target),
			// Inputs
			.instr		(instr),
			.zero_flag	(zero_flag));

   regfile1379 RF(
		 // Outputs
		 .out_rs1	(out_rs1),
		 .out_rs2	(out_rs2),
		 .out_temp	(out_temp),
		 // Inputs
		 .clk		(clk),
		 .reset_n	(reset_n),
		 .we		(we),
		 .addr_rs1	(rs1),
		 .addr_rs2	(rs2),
		 .addr_rd	(rd),
		 .wr_data	(alu_result),
		 .load1		(load1),
		 .load2		(load2),
		 .temp		(temp),
		 .in1		(temp_in1),
		 .in2		(temp_in2));

   ALU myalu(
	     // Outputs
	     .zero_flag		(zero_flag),
	     .alu_result	(alu_result),
	     // Inputs
	     .rs1		(out_rs1),
	     .rs2		(out_rs2),
	     .opcode		(opcode));

   assign temp_out = out_temp;

   cover property ( @(posedge clk) opcode == 4'b1111);  // load2 실행 횟수

endmodule // core1
