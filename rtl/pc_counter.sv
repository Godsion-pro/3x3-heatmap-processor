module pc_counter(/*AUTOARG*/
   // Outputs
   pc,
   // Inputs
   clk, reset_n, branch_taken, jump_taken, branch_target, jump_target
   );
   input logic clk, reset_n;
   input logic branch_taken , jump_taken; //1이면 branch

   input logic [5:0] branch_target,jump_target;

   output logic [5:0] pc;


   always_ff @(posedge clk) begin

      if (!reset_n)
	pc <= 0;

      else begin
	 if (branch_taken)
	   pc <=  branch_target;
	 else if (jump_taken)
	   pc <= jump_target;
	 else
	   pc <= pc + 1;
      end // else: !if(!reset_n)
   end // always_ff @ (posedge clk)


endmodule // pc_counter
