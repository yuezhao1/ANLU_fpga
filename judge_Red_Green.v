`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:35:32 11/02/2019 
// Design Name: 
// Module Name:    judge_Red_Green 
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
module judge_Red_Green(
	input											clk,
	input											rst_n,
	input				[7:0]						RGB,
											
	output		reg		[1:0]						Red_Green  //01代表红色 , 10代表绿色
    );

	
	wire				[7:0]						r1;
	wire				[7:0]						g1;
	wire				[7:0]						b1;
	wire											red0;
	wire    										green0;
	wire    										blue0;
	wire											red1;
	wire    										green1;
	wire    										blue1;
	wire											red_en;
	wire    										green_en;
	

assign r1 =	{RGB[7:5],RGB[7:5],RGB[7:6]};
assign g1 =	{RGB[4:2],RGB[4:2],RGB[4:3]};
assign b1 =	{RGB[1:0],RGB[1:0],RGB[1:0],RGB[1:0]};

//红色阈值
assign red0   =	(r1 > 8'd0 && r1 <= 8'd185) ? 1'b1 : 1'b0;
assign green0 =	(g1	>= 8'd0 && g1 <= 8'd38) ? 1'b1 : 1'b0;
assign blue0  =	(b1 >= 8'd0 && b1 <= 8'd10) ? 1'b1 : 1'b0;

//绿色阈值
assign red1   =	(r1 > 8'd0 && r1 <= 8'd20) ? 1'b1 : 1'b0;
assign green1 =	(g1	> 8'd0 && g1 <= 8'd70) ? 1'b1 : 1'b0;
assign blue1  =	(b1 > 8'd0 && b1 <= 8'd20) ? 1'b1 : 1'b0;


assign red_en = (red0 && green0 && blue0) ? 1'b1 : 1'b0;
assign green_en = (red1 && green1 && blue1) ? 1'b1 : 1'b0;




	
	reg		[9:0]		R_cnt;

	
always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		R_cnt <= 10'd0;
		else if(red_en)
		R_cnt <= R_cnt + 1'b1;
		else
		R_cnt <= R_cnt;
	end

	reg		[9:0]		G_cnt;
	
always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		G_cnt <= 10'd0;
		else if(green_en)
		G_cnt <= G_cnt + 1'b1;
		else
		G_cnt <= G_cnt;
	end	
	
always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		Red_Green <= 2'b0;
		else if(R_cnt >= 200)
		Red_Green <= 2'b01;		//01代表红色
		else if(G_cnt >= 200)
		Red_Green <= 2'b10;		//10代表绿色
		else
		Red_Green <= 2'b0;
	end
	


endmodule
