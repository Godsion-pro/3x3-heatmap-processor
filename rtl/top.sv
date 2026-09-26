// 3x3 Multi-Core Heatmap Processor - top
//
//  core 배치 (serpentine: temp 입력이 core1 -> core9 방향으로 shift)
//     core1 - core2 - core3
//                       |
//     core6 - core5 - core4
//       |
//     core7 - core8 - core9 -> heat_set
//
module top (
   // Outputs
   heat1, heat2, heat3, heat4, heat5, heat6, heat7, heat8, heat9,
   // Inputs
   clk, reset_n, temp_val
   );
   input logic clk,reset_n;
   input logic [7:0] temp_val;

   output logic [7:0] heat1, heat2, heat3, heat4, heat5, heat6, heat7, heat8, heat9;


   logic [7:0]	      val_1,val_2,val_3,val_4,val_5,val_6,val_7,val_8,val_9;
   logic	      cal_done1;
   logic [7:0]	      heat1_out, heat2_out, heat3_out, heat4_out, heat5_out, heat6_out, heat7_out, heat8_out, heat9_out;

   core1 core1(
		.clk		(clk),
		.reset_n	(reset_n),
		.temp_out    	(val_1),
		.temp        	(temp_val),
		.temp_in1    	(val_6),
		.temp_in2    	(val_2)
		);

   core2 core2(
		.clk		(clk),
		.reset_n	(reset_n),
		.temp_out    	(val_2),
		.temp        	(val_1),
		.temp_in1    	(val_5),
		.temp_in2    	(val_1),
		.temp_in3    	(val_3)
		);

   core1 core3(
		.clk		(clk),
		.reset_n	(reset_n),
		.temp_out    	(val_3),
		.temp        	(val_2),
		.temp_in1    	(val_4),
		.temp_in2    	(val_2)
		);

   core2 core4(
		.clk		(clk),
		.reset_n	(reset_n),
		.temp_out    	(val_4),
		.temp        	(val_3),
		.temp_in1    	(val_3),
		.temp_in2    	(val_9),
		.temp_in3    	(val_5)
		);

   core5 core5(
		.clk		(clk),
		.reset_n	(reset_n),
		.temp_out    	(val_5),
		.temp_in     	(val_4),
		.up          	(val_2),
		.down        	(val_8),
		.left        	(val_6),
		.right       	(val_4)
		);

   core2 core6(
		.clk		(clk),
		.reset_n	(reset_n),
		.temp_out    	(val_6),
		.temp        	(val_5),
		.temp_in1    	(val_1),
		.temp_in2    	(val_7),
		.temp_in3    	(val_5)
		);

   core1 core7(
		.clk		(clk),
		.reset_n	(reset_n),
		.temp_out    	(val_7),
		.temp        	(val_6),
		.temp_in1    	(val_6),
		.temp_in2    	(val_8)
		);

   core2 core8(
		.clk		(clk),
		.reset_n	(reset_n),
		.temp_out    	(val_8),
		.temp        	(val_7),
		.temp_in1    	(val_5),
		.temp_in2    	(val_7),
		.temp_in3    	(val_9)
		);

   core9 core9(
		.clk		(clk),
		.reset_n	(reset_n),
		.temp_out    	(val_9),
		.cal_done    	(cal_done1),
		.temp        	(val_8),
		.temp_in1    	(val_4),
		.temp_in2    	(val_8)
		);

   heat_set heat_set(
		     // Outputs
		     .heat1_out		(heat1_out[7:0]),
		     .heat2_out		(heat2_out[7:0]),
		     .heat3_out		(heat3_out[7:0]),
		     .heat4_out		(heat4_out[7:0]),
		     .heat5_out		(heat5_out[7:0]),
		     .heat6_out		(heat6_out[7:0]),
		     .heat7_out		(heat7_out[7:0]),
		     .heat8_out		(heat8_out[7:0]),
		     .heat9_out		(heat9_out[7:0]),
		     // Inputs
		     .clk		(clk),
		     .reset_n		(reset_n),
		     .heat_in		(val_9),
		     .cal_done_in	(cal_done1));

   assign heat1 = heat1_out;
   assign heat2 = heat2_out;
   assign heat3 = heat3_out;
   assign heat4 = heat4_out;
   assign heat5 = heat5_out;
   assign heat6 = heat6_out;
   assign heat7 = heat7_out;
   assign heat8 = heat8_out;
   assign heat9 = heat9_out;

   // ASSERTION: 각 코어의 입력값이 X(8'hxx)가 아닌지 검사
   // Core1 (val_6, val_2)
   always_comb begin
      assert (val_6 !== 8'hxx && val_2 !== 8'hxx)
	else $fatal("[ASSERTION FAIL] Core1 has invalid input at time %0t", $time);
      $display("[ASSERTION PASS] Core1 inputs are valid");
   end

   // Core2 (val_5, val_1, val_3)
   always_comb begin
      assert (val_5 !== 8'hxx && val_1 !== 8'hxx && val_3 !== 8'hxx)
	else $fatal("[ASSERTION FAIL] Core2 has invalid input at time %0t", $time);
      $display("[ASSERTION PASS] Core2 inputs are valid");
   end

   // Core3 (val_4, val_2)
   always_comb begin
      assert (val_4 !== 8'hxx && val_2 !== 8'hxx)
	else $fatal("[ASSERTION FAIL] Core3 has invalid input at time %0t", $time);
      $display("[ASSERTION PASS] Core3 inputs are valid");
   end

   // Core4 (val_3, val_9, val_5)
   always_comb begin
      assert (val_3 !== 8'hxx && val_9 !== 8'hxx && val_5 !== 8'hxx)
	else $fatal("[ASSERTION FAIL] Core4 has invalid input at time %0t", $time);
      $display("[ASSERTION PASS] Core4 inputs are valid");
   end

   // Core5 (val_4, val_2, val_8, val_6)
   always_comb begin
      assert (val_4 !== 8'hxx && val_2 !== 8'hxx && val_8 !== 8'hxx && val_6 !== 8'hxx)
	else $fatal("[ASSERTION FAIL] Core5 has invalid input at time %0t", $time);
      $display("[ASSERTION PASS] Core5 inputs are valid");
   end

   // Core6 (val_1, val_7, val_5)
   always_comb begin
      assert (val_1 !== 8'hxx && val_7 !== 8'hxx && val_5 !== 8'hxx)
	else $fatal("[ASSERTION FAIL] Core6 has invalid input at time %0t", $time);
      $display("[ASSERTION PASS] Core6 inputs are valid");
   end

   // Core7 (val_6, val_8)
   always_comb begin
      assert (val_6 !== 8'hxx && val_8 !== 8'hxx)
	else $fatal("[ASSERTION FAIL] Core7 has invalid input at time %0t", $time);
      $display("[ASSERTION PASS] Core7 inputs are valid");
   end

   // Core8 (val_5, val_7, val_9)
   always_comb begin
      assert (val_5 !== 8'hxx && val_7 !== 8'hxx && val_9 !== 8'hxx)
	else $fatal("[ASSERTION FAIL] Core8 has invalid input at time %0t", $time);
      $display("[ASSERTION PASS] Core8 inputs are valid");
   end

   // Core9 (val_4, val_8)
   always_comb begin
      assert (val_4 !== 8'hxx && val_8 !== 8'hxx)
	else $fatal("[ASSERTION FAIL] Core9 has invalid input at time %0t", $time);
      $display("[ASSERTION PASS] Core9 inputs are valid");
   end

endmodule // top
