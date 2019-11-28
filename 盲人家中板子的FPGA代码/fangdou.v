`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:31:17 10/26/2018 
// Design Name: 
// Module Name:    fangdou 
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
module fangdou(in_key_en,rst_n,clk,out_key_en);
	input [3:0]in_key_en;
	input clk,rst_n;
	
	output [3:0]out_key_en;
	
	parameter clk190 = 18'd263157;
	
	reg [24:0]cnt;
	reg [3:0]delay1,delay2,delay3;
	wire [3:0]out_key_en_r;
	reg [3:0]out_key_en_rr;
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cnt <= 0;
		else if(cnt == clk190)
			cnt <= 0;
		else 
			cnt <= cnt + 1;
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
				delay1 <= 4'b0000;
				delay2 <= 4'b0000;
				delay3 <= 4'b0000;
			end
		else if(cnt == clk190)
			begin
				delay1 <= in_key_en;
				delay2 <= delay1;
				delay3 <= delay2;
			end
	end
	
	assign out_key_en_r = delay1 & delay2 & delay3 ;
	
	always@(posedge clk)
		out_key_en_rr <= out_key_en_r;
	
	assign out_key_en = out_key_en_r & ~out_key_en_rr; //原始信号 & ~延时后的信号
	
endmodule
