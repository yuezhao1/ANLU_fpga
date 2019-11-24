module x7seg_msg(
     input [9:0] x,
	  input clk,
	  input rst_n,
	  //output reg [6:0] smg_duan,
	  //output reg [3:0] smg_wei,
	  //output reg  dp,
	  output reg led1,
	  output [9:0]hq
    );
	
	 
	 assign hq = x[3:0]*1 + x[7:4]*10 + x[9:8]*100;
	 
	 
	 always@(posedge clk or negedge rst_n)
	 if(rst_n==0)
	   led1 <= 0;
	 else if(hq <= 60)
	   led1 <= 1;
	  else 
	   led1 <= 0;
endmodule
