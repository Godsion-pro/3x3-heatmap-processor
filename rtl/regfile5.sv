module regfile5 (/*AUTOARG*/
		 // Outputs
		 out_rs1, out_rs2, out_temp,
		 // Inputs
		 clk, reset_n, we, addr_rs1, addr_rs2, addr_rd, wr_data, load1, load2, temp, up, down, right, left
		 );
   input clk, reset_n, we, load1, load2; //쓰기 신호
   input [3:0] addr_rs1, addr_rs2;
   input [5:0] addr_rd;
   input [7:0] wr_data;
   input [7:0] up, down, right, left; // 연산 위해 필요한 값
   input [7:0] temp;  //연산 전에 넘기기 작업에 필요  -> 자기값 $t7 입출력 전용
   //

   output logic [7:0] out_temp;

   output logic [7:0] out_rs1, out_rs2;

   logic [7:0]	      mem [0:12];

   always_ff@(posedge clk) begin
      if(!reset_n) begin
	 mem[0] <= 8'd0;    //  calculate result
	 mem[1] <= 8'd0;   //   heat

	 mem[2] <= 8'd0;   // up (heat)
	 mem[3] <= 8'd0;  //  down
	 mem[4] <= 8'd0;  //  right
	 mem[5] <= 8'd0; //   left
	 mem[6] <= 8'd5;  // divide 5
	 mem[7] <= 8'd0;   // 입출력용
	 mem[8] <= 8'd1; // 1
	 mem[9] <= 8'd5;  // loop limit (연산 사이클 5회)
	 mem[10] <= 8'd0; // loop counter
	 mem[11] <= 8'd0;  //상수 0
	 mem[12] <= 8'd0;  //연산 완료 신호
      end // if (!reset_n)

      else begin
	 if (we) begin
	    mem[addr_rd] <= wr_data;
	 end

	 else if (load1) begin
	    mem[7] <= temp;    //입력
	 end

	 else if (load2) begin
	    mem[2] <= up;      //위
	    mem[3] <= down;    //아래
	    mem[4] <= right;   //오른쪽
	    mem[5] <= left;    //왼쪽
	 end

      end
   end // always_ff @ (posedge clk)


   assign out_rs1 = mem[addr_rs1];
   assign out_rs2 = mem[addr_rs2];
   assign out_temp = mem[7];   //출력


endmodule // regfile5
