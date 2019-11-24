module smg2(input [9:0] x,
	  input clk,
	  input rst_n,
	  //output reg [6:0] smg_duan,
	  //output reg [3:0] smg_wei,
	  //output reg  dp,
	  output reg led0,
	  output  [9:0]hz
    );
	 
	 assign hz = x[3:0]*1 + x[7:4]*10 + x[9:8]*100;
	 
	 
	 always@(posedge clk or negedge  rst_n)
	 if(!rst_n)
	   led0 <= 0;
	 else if(hz <=40)
	   led0 <= 1;
	  else 
	   led0 <= 0;


endmodule
