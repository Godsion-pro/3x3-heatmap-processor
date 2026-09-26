module ALU(/*AUTOARG*/
   // Outputs
   zero_flag, alu_result,
   // Inputs
   rs1, rs2, opcode
   );
   input [7:0] rs1, rs2;
   input [3:0] opcode;

   output logic	      zero_flag;
   output logic [7:0] alu_result;  //add 연산 결과

   always_comb begin
      zero_flag = 1'b0;
      alu_result = 0;

      case (opcode)
	4'b0000 : begin  //add(sw)
	   alu_result = rs1 + rs2;
	end

	4'b0001 : begin   //div
	   assert(rs2 != 0)
	     else $fatal("Division by zero detected (rs2==0) at time %0t", $time);  //rs2가 0이면
	   if (rs2 != 0)
	     $display("Division performed normally: %0d / %0d = %0d", rs1, rs2, rs1 / rs2);
	   alu_result = rs1 / rs2;
	end

	4'b0010 : begin   //BEQ
	   zero_flag = (rs1 == rs2) ? 1 : 0;
	end

	4'b0100 : begin  // jump(EXIT)
	   zero_flag = 1;
	end

	default: begin

	end
      endcase // case (opcode)

   end // always_comb

endmodule // ALU
