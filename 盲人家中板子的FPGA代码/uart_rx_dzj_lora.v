`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:34:12 10/05/2019 
// Design Name: 
// Module Name:    uart_rx_dzj_talk
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
module uart_rx_dzj_lora(
	input clk,
	input rst_n,
	input [7:0]data_tx,
	input over_rx,
	input nedge,
	input over_all,
	output reg flag_lora
    );
	
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			flag_lora<=2'b00;
		else if(data_tx==8'd01)                 //烟雾
			flag_lora<=2'b01;
		else if(data_tx==8'd2)                  //震动
			flag_lora<=2'b10;
		else if(data_tx==8'd3)                   //门铃
			flag_lora<=2'b11;
		else flag_lora<=flag_lora;
	end
	
	
//parameter s0=4'd0,s1=4'd1,s2=4'd2,s3=4'd3,s4=4'd4;
//	reg[3:0] present_state,next_state;
//	always@(posedge clk or negedge rst_n)
//	begin
//	  if(!rst_n)
//		begin
//	    present_state<=s0;
//		end
//	  else if(~over_rx&nedge) present_state<=next_state;
//	end
//	
//	always@(*)
//	 begin
//	 case(present_state)
//	    s0: if(data_tx==8'h31/*8'b01001001*/)  //时间 
//			  next_state<=s1;
//			else next_state<=s0;
//		s1: if(data_tx==8'h02/*8'b00100000*/)  
//			  next_state<=s2;
//			else next_state<=s0;
//		s2: if(data_tx==8'h80/*8'b01001100*/)  
//			  next_state<=s3;
//			else next_state<=s0;
//		s3: if(data_tx==8'hEF/*8'b01101001*/)  
//			  next_state<=s4;
//			else next_state<=s0;
//		s4: if(data_tx==8'hAA/*8'b01001001*/) 
//			   next_state<=s1;
//			 else next_state<=s0;
//		default: next_state<=s0;
//	 endcase
//	 end 
//	always@(posedge clk or negedge rst_n)
//	 begin
//		if(!rst_n)
//			flag<=0;
//		/*else if(over_all)
//		    flag<=1'b0;*/
//		else if(next_state==s1)
//			flag<=1'b1;
//		else flag<=flag;
//	 end
endmodule
