`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:35:16 11/02/2019 
// Design Name: 
// Module Name:    VGA_square 
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
module VGA_square(

	input										clk,
	input										rst_n,
	input				[7:0]					M_pic,
			
	output										flag_addr,//表示边框xy比例检测成功，VGA可以进行显示
	output		reg		[6:0]					cnt_x,
	output		reg		[7:0]					cnt_y,//127超值
	output		reg		[15:0]					rom_addr13,
	output		reg		[15:0]					flag_square_begin,
	output		reg		[15:0]					flag_square_end
    );		
			
	wire				[7:0]					r1;
	wire        		[7:0]               	g1;
	wire        		[7:0]               	b1;
	wire										red0;  
	wire            	                        green0;
	wire            	                        blue0;
    wire            	                        black;
	wire										black_x;
	
	
	reg											clear;		
	reg					[15:0]					black_reg0;
	reg             	[15:0]                  black_reg1;
	reg             	[15:0]                  black_reg2;
	reg					[6:0]					N;	
	reg					[15:0]					rom_addr13_1;
	reg					[15:0]					rom_addr13_2;
	reg					[2:0]					B;
	reg					[2:0]					BiLi;

		
assign r1 =	{M_pic[7:5],M_pic[7:5],M_pic[7:6]};
assign g1 =	{M_pic[4:2],M_pic[4:2],M_pic[4:3]};
assign b1 =	{M_pic[1:0],M_pic[1:0],M_pic[1:0],M_pic[1:0]};

assign red0   =	((r1 <= 8'd36 && r1 <= 8'd73) || r1 == 8'd0 || r1 == 8'd109) ? 1'b1 : 1'b0;
assign green0 =	((g1 >= 8'd36 && g1 <= 8'd73) || g1 == 8'd0 || g1 == 8'd146) ? 1'b1 : 1'b0;//
assign blue0  =	((b1 >= 8'd80 && b1 <= 8'd85) || b1 == 8'd0) ? 1'b1 : 1'b0;
assign black  = (red0 & green0 & blue0)? 1'b1 : 1'b0;//近似黑色提取

wire	[15:0]		a;
assign a = (cnt_x > 30)?black_reg0:0;


//检测横向特征黑
always @ (posedge clk or negedge rst_n)begin
	if(!rst_n)
	black_reg0 <= 16'd0;
	else if(black && (cnt_x == 6'd1))
	black_reg0 <= rom_addr13_1 - 3'd3 + 3'd4;//加4:为了cnt_y检测保持黑色black像素点
	else
	black_reg0 <= black_reg0;
	end

	
always @ (posedge clk or negedge rst_n)begin
	if(!rst_n)begin
	black_reg1 <= 16'd0;
	black_reg2 <= 16'd0;
	end
	else if(black)begin
	black_reg1 <= rom_addr13_1;
	black_reg2 <= black_reg1;
	end
	else begin
	black_reg1 <= 16'd0;
	black_reg2 <= 16'd0;
	end
	end	
	

//判断两个 特征黑 地址是否相邻
assign   black_x =(black_reg1 - black_reg2 == 1)?1'b1:1'b0;
	

reg		[6:0]		j0;
reg		[6:0]		j1;
wire	[6:0]		h;

assign h = (j0 - j1 == 1'b0)?j0:1'b0;


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
	j0 <= 7'd0;
	j1 <= 7'd0;
	end
	else if(cnt_x > 0)begin
	j0 <= cnt_x;
	j1 <= j0;
	end
	else begin
	j0 <= 7'd0;
	j1 <= 7'd0;
	end
	end
	
//记黑色边框的宽
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	cnt_x <= 7'd0;
	else if(clear)
	cnt_x <= 7'd0;
	else if( cnt_x > (h-1'b1) )///////////22特殊值,即cnt_x计数特征黑的一行像素点数
	cnt_x <= cnt_x;
	else if(black_x == 1'b1)
	cnt_x <= cnt_x + 1'b1;
	else
	cnt_x <= cnt_x;
	end

	
//特征黑色小于cnt_x <= 30不进行运算
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	clear <= 1'b0;
	else if((cnt_x <= 30 && cnt_x > 0 && !black_x) || (cnt_x >= 80 && !black_x))
	clear <= 1'b1;
	else
	clear <= 1'b0;
	end
	
	
	
	
always @(posedge clk or  negedge rst_n)begin
	if(!rst_n)
	rom_addr13_1 <= 16'd0;
	else if(rom_addr13 >= 16'd32800)
	rom_addr13_1 <= 16'd0;
	else if(cnt_x > (h-1'b1))
	rom_addr13_1 <= rom_addr13_1;	
	else if(cnt_y == 8'd0)
	rom_addr13_1 <= rom_addr13_1 + 1'b1;
	else
	rom_addr13_1 <= rom_addr13_1;
	end


wire		[15:0]			c;

assign c = rom_addr13 - cnt_x - 3'd5 + 3'd4;

	
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
	cnt_y <= 8'd0;
	N <= 7'd0;
	rom_addr13_2 <= 16'd0;
	end
	else begin
	rom_addr13 <= rom_addr13_1 + rom_addr13_2 + 1'b1;
	
		if(!black_x && cnt_x >= 7'd6)
			begin
			
				case (c)
				
				black_reg0 + N*200:	begin
									rom_addr13 <= rom_addr13 - (h+5);
									
									if(black)begin
									cnt_y <= cnt_y + 1'b1;
									rom_addr13_2 <= rom_addr13_2 + 200;
									N <= N + 1'b1;
									end
									else begin
									N <= 7'd0;
									cnt_y <= cnt_y;
									end
									end
									
				black_reg0 + N*200:	if(black)begin				
									cnt_y <= cnt_y + 1'b1;
									rom_addr13_2 <= rom_addr13_2 + 200;
									N <= N + 1'b1;
									end
									else begin
									N <= 7'd0;
									cnt_y <= cnt_y;
									end																				
			
				black_reg0 + N*200:	if(black)begin
									cnt_y <= cnt_y + 1'b1;
									rom_addr13_2 <= rom_addr13_2 + 200;
									N <= N + 1'b1;
									end
									else begin
									N <= 7'd0;
									cnt_y <= cnt_y;
									rom_addr13_2 <= rom_addr13_2;
									end
				endcase
			end
		end
	end


reg					clk_4;
reg		[2:0]		cnt_clk_4;
//同上
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	cnt_clk_4 <= 3'd0;
	else if(cnt_clk_4 == 3'd5)
	cnt_clk_4 <= 3'd0;
	else
	cnt_clk_4 <= cnt_clk_4 + 1'b1;
	end
//同上
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	clk_4 <= 1'b0;
	else if(cnt_clk_4 == 3'd5)
	clk_4 <= 3'd0;
	else if(cnt_clk_4 == 3'd3)
	clk_4 <= ~clk_4;
	else
	clk_4 <= clk_4;
	end	  

reg 	[6:0]			i_0;
reg		[6:0]			i_1;

//使比例在cnt_y稳定时进行计算
always @(posedge clk or negedge rst_n)
	if(!rst_n)begin
	i_0 <= 7'd0;
	i_1 <= 7'd0;
	end
	else if(cnt_y)begin
	i_0 <= cnt_y;
	i_1 <= i_0;
	end
	else begin
	i_0 <= 7'd0;
	i_1 <= 7'd0;
	end	

	
reg						flag_cnt_y;
//同上	
always @(posedge clk_4 or negedge rst_n)begin
	if(!rst_n)
	flag_cnt_y <= 1'b0;
	else if(i_0 - i_1 == 1'b0 && cnt_y > 1'b0)
	flag_cnt_y <= 1'b1;
	else
	flag_cnt_y <= 1'b0;
	end

	

//确定长宽比						
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	B <= 3'd0;
	else	begin
			if(flag_cnt_y) 
				begin
				if((cnt_y < 6*cnt_x)&& (cnt_y > 5*cnt_x))
				B <= 3'd4;
				else if((cnt_y < 5*cnt_x)&& (cnt_y > 4*cnt_x))
				B <= 3'd3;	
				else if((cnt_y < 4*cnt_x)&& (cnt_y > 2*cnt_x))
				B <= 3'd2;
				else if((cnt_y < 2*cnt_x)&& (cnt_y > 1*cnt_x))
				B <= 3'd1;
				end
			end
		
	end
	
//产生比例值,判断是否为特定框
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	BiLi <= 3'd0;
	else if(clear)
	BiLi <= 3'd0;
	else	begin
			case (B)
				1:	  BiLi <= 3'd1;
				2:	  BiLi <= 3'd2;
				3:	  BiLi <= 3'd3;
				4:	  BiLi <= 3'd4;
			default:  BiLi <= 3'd0;
			endcase
		end
	end

reg				clr;
	
//检测到第一个非红绿灯比例的黑色特征框,清零所有寄存器的值	
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	clr <= 1'b0;
	else if(BiLi > 3'd2 | BiLi == 3'd1)
	clr <= 1'b1;
	else
	clr <= 1'b0;
	end
	
	
reg 	[6:0]			d0;
reg 	[6:0]			d1;
reg						VGA_clk;

//为了保持cnt_y稳定时的值
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	VGA_clk <= 1'b0;
	else
	VGA_clk <= ~VGA_clk;
	end

//同上	
always @(posedge VGA_clk or negedge rst_n)
	if(!rst_n)begin
	d0 <= 7'd0;
	d1 <= 7'd0;
	end
	else begin
	d0 <= cnt_y;
	d1 <= d0;
	end
	
//cnt_y稳定不变的信号
assign flag_addr = ((d0 - d1)== 1'b0 && cnt_y > 1'b0)?1'b1:1'b0;
		
	
//VGA显示边框的始末
always @(posedge clk or negedge rst_n)
	if(!rst_n)begin
	flag_square_begin <= 16'd0;
	flag_square_end	<= 16'd0;
	end
	else if(BiLi == 3'd2)begin
	flag_square_begin <= black_reg0;
		if(flag_addr)
		flag_square_end	<= black_reg0 + cnt_x + cnt_y * 200;
	end
	else begin
	flag_square_begin <= 16'd0;
	flag_square_end	<= 16'd0;
	end
	
	

endmodule
