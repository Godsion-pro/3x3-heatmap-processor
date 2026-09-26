module control_unit (
		     // Outputs
		     output logic [3:0]	opcode,
		     output logic [3:0]	rs1, rs2,
		     output logic [5:0]	rd,
		     output logic	branch_taken, jump_taken, we, load1, load2,
		     output logic [5:0]	branch_target, jump_target,

		     // Inputs
		     input logic [17:0]	instr,
		     input logic	zero_flag

		     );

   // Instruction Format: [17:14] opcode | [13:10] rs1 | [9:6] rs2 | [5:0] rd/imm

   // Decode instruction fields
   always_comb begin
      opcode         = instr[17:14];
      rs1            = instr[13:10];
      rs2            = instr[9:6];
      rd             = instr[5:0];
   end

   // Control signals
   always_comb begin
      // 기본값
      we            = 1'b0;
      load1         = 1'b0;
      load2         = 1'b0;
      branch_taken  = 1'b0;
      jump_taken    = 1'b0;

      branch_target = rd;
      jump_target = rd;

      case (opcode)
	4'b0000: begin // add(sw)
	   we = 1'b1;
	end

	4'b0001: begin // div
	   we = 1'b1;
	end

	4'b0010: begin // beq
	   branch_taken = zero_flag;
	end


	4'b0100: begin // jump (exit)
	   jump_taken = 1'b1;
	end

	4'b1110: begin // load1
	   load1 = 1;
	end

	4'b1111: begin // load2
	   load2 = 1;
	end

	default: begin
	   // NOP or undefined
	end
      endcase
   end

endmodule
