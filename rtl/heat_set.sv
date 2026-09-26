module heat_set(/*AUTOARG*/
   // Outputs
   heat1_out, heat2_out, heat3_out, heat4_out, heat5_out, heat6_out,
   heat7_out, heat8_out, heat9_out,
   // Inputs
   clk, reset_n, heat_in, cal_done_in
   );
   input clk, reset_n;
   //clock에 따라 받지 않으면 어느 core의 heat인지 구별 어려움

   input logic [7:0] heat_in;
   input logic	     cal_done_in;

   output logic [7:0] heat1_out, heat2_out, heat3_out, heat4_out, heat5_out, heat6_out,
		      heat7_out, heat8_out, heat9_out;

   logic [7:0]	      heat [0:8];
   //0: c9 |  1:c8 | 2: c7 |  3: c6 | 4 : c5 | 5:c4 | 6:c3 | 7:c2 | 8:c1


   logic [3:0]	      count;

   always_ff@(posedge clk) begin
      if (!reset_n) begin
	 heat1_out <=0;
	 heat2_out <=0;
	 heat3_out <=0;
	 heat4_out <=0;
	 heat5_out <=0;
	 heat6_out <=0;
	 heat7_out <=0;
	 heat8_out <=0;
	 heat9_out <=0;
	 count <= 0;
      end

      else begin
	 if (cal_done_in) begin
	    if (count != 9) begin

	       heat[count] <= heat_in;
	       count <= count +1;

	    end
	    else  // count == 9
	      count <= 0;
	 end

	 if (count==9) begin
	    heat1_out <= heat[8];
	    heat2_out <= heat[7];
	    heat3_out <= heat[6];
	    heat4_out <= heat[5];
	    heat5_out <= heat[4];
	    heat6_out <= heat[3];
	    heat7_out <= heat[2];
	    heat8_out <= heat[1];
	    heat9_out <= heat[0];
	 end

      end // else: !if(!reset_n)
   end // always_ff@ (posedge clk)

endmodule // heat_set
