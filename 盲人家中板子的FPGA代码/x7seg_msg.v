`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:08:19 10/26/2017 
// Design Name: 
// Module Name:    x7seg_msg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module x7seg_msg(
     input [15:0] x,
	  input clk,
	  input clr,
	  output reg [6:0] smg_duan,
	  output reg [3:0] smg_wei,
	  output reg  dp
    );
	 
	 reg [1:0] s;
	 reg [3:0] digit;
	 wire [3:0] aen;
	 
	 parameter t1=18'd250000;
	 reg [17:0] cnt1;
	 
	 assign aen=4'b1111;
	 
	 always@(posedge clk or posedge clr)
	 begin
	    if(clr==1) begin
		    cnt1<=0;
		 end
		 else if(cnt1==t1-1) begin
		    cnt1<=0;
		 end
		 else begin
		    cnt1<=cnt1+1;
		 end
	 end
	 
	 always@(*)
	 begin
	    case(s)
		 0: digit=x[3:0];
		 1: digit=x[7:4];
		 2: digit=x[11:8];
		 3: digit=x[15:12];
		 default: digit=x[3:0];
		 endcase
	 end
	 
	 //7段解码器
	 always@(*)
	 begin
	    case(digit)
	    0: smg_duan=7'b0000001;
		 1: smg_duan=7'b1001111;
		 2: smg_duan=7'b0010010;
		 3: smg_duan=7'b0000110;
		 4: smg_duan=7'b1001100;
		 5: smg_duan=7'b0100100;
		 6: smg_duan=7'b0100000;
		 7: smg_duan=7'b0001111;
		 8: smg_duan=7'b0000000;
		 9: smg_duan=7'b0000100;
		 'ha: smg_duan=7'b0001000;
		 'hb: smg_duan=7'b1100000;
		 'hc: smg_duan=7'b0110001;
		 'hd: smg_duan=7'b1000010;
		 'he: smg_duan=7'b0110000;
		 'hf: smg_duan=7'b0111000;//空白
		 default:smg_duan=7'b1111111;
		 endcase
	 end
	 
	 //数字选择
	 always@(*)
	 begin
	    smg_wei=4'b1111;
		 if(aen[s]==1)
		    smg_wei[s]=0;
	 end
	 
	 //2位计数器
	 always@(posedge clk or posedge clr)
	 begin
	    if(clr==1) begin
		    s<=0;
			 dp<=1;
		 end	 
		 else if(cnt1==t1-1) begin
		   s<=s+1;
			if(s==1) begin
			   dp<=0;
			end
			else begin
			   dp<=1;
		   end
	    end
		 else begin
		   s<=s;
		 end
	 end
endmodule
