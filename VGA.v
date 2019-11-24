`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:34:55 11/02/2019 
// Design Name: 
// Module Name:    VGA 
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
module VGA(
	input							clk,
	input							rst_n,
	input			[7:0]			M,
	input							pic_en,//控制是否进行特征识别
	input							flag_addr,//表示边框xy比例检测成功，VGA可以进行计数
	input			[15:0]			flag_square_begin,//显示起点
	input			[15:0]			flag_square_end,//显示终点
	input			[6:0]			cnt_x,//特征边沿的x
	input			[6:0]			cnt_y,//特征边沿的y
	
	output							VGA_HS,
	output							VGA_VS,
	output	reg		[15:0]			rom_addr16,
	output	reg		[7:0]			RGB
    );


	
	//行参数
	parameter						H_SP = 10'd96;//同步头脉冲(负极性)
	parameter						H_BP = 10'd48;//显示后沿
	parameter						H_FP = 10'd16;//显示前沿
	parameter						H_DISP = 10'd640;//显示时序段	
	parameter						H_pixels = 10'd800;//行像素点

	//列参数					
	parameter						V_SP = 10'd2;//同步头脉冲(负极性)
	parameter						V_BP = 10'd29;
	parameter						V_FP = 10'd14;
	parameter						V_DISP = 10'd480;
	parameter						V_lines = 10'd525;//总行数

	
	//显示图片 高(H)宽(W)
	parameter						H = 8'd200;
	parameter						W = 8'd164;	

	//图片起点
	parameter 						xpic = 8'd5;
	parameter 						ypic = 8'd5;



	
	
	reg									VGA_clk;	
	reg				[9:0] 				h_cnt;//行计数
	reg				[9:0] 				v_cnt;//场计数

	wire								disp_valid;	
	
	
//分频	
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		VGA_clk <= 1'b0;
	else
		VGA_clk	<=	~VGA_clk;
	end	
	
//行同步信号发生器
always @(posedge VGA_clk or negedge rst_n)begin
	if(!rst_n)
		h_cnt <= 10'b0;
	else begin
		if( h_cnt == H_pixels - 1'b1)
			h_cnt <= 10'b0;
		else
			h_cnt <= h_cnt + 1'b1;	
	end
	end
	
//场同步信号发生器
always @(posedge VGA_clk or negedge rst_n)begin
	if(!rst_n)
		v_cnt <= 10'b0;
	else begin
		if(h_cnt == H_pixels - 1'b1)begin
		if( v_cnt == V_lines - 1'b1)
			v_cnt <= 10'b0;
		else
			v_cnt <= v_cnt + 1'b1;
		end
		end
	end

//HS 和 VS	
assign VGA_VS = (v_cnt >= 0 && v_cnt < V_SP) ? 1'b0:1'b1;
assign VGA_HS = (h_cnt >= 0 && h_cnt < H_SP) ? 1'b0:1'b1;
	
		
assign  disp_valid =	(h_cnt >= (H_SP + H_BP + H_FP) && h_cnt <= H_pixels	&& v_cnt >= (V_SP + V_BP + V_FP) && v_cnt < V_lines)&&
						((h_cnt - (H_SP + H_BP + H_FP)) > 0 && (h_cnt - (H_SP + H_BP + H_FP)) < (0 + W))&&
						((v_cnt - (V_SP + V_BP + V_FP) ) > 0 && (v_cnt - (V_SP + V_BP + V_FP) ) < (0 + H)) ? 1'b1:1'b0;
  

	
//时序电路,用来给rom_addr16寄存器赋值	
always@(posedge clk or negedge rst_n)begin
	 if(!rst_n)
		 rom_addr16 <= 16'd0;
	 else if(disp_valid)
		 rom_addr16 <= (h_cnt - 160) + (v_cnt - 45) * W;
	 else
		 rom_addr16 <= 16'd0;
 end

	
	
	reg [6:0]  N;
	reg [6:0]  n;	

always @(posedge VGA_clk or negedge rst_n)begin
	if(!rst_n)
	N <= 7'd0;
	else if( (N + 1'b1) > cnt_y - 2 )//减2,目的红绿灯下面背景黄线
	N <= 7'd0;
	else if(n == cnt_x )
	N <= N + 1'b1;
	else
	N <= N;
	end
	
	reg		[6:0]		f;

always @(posedge VGA_clk or negedge rst_n)begin
	if(!rst_n)
	f <= 7'd0;
	else if(rom_addr16 >= flag_square_begin + N*200 && n == cnt_x && cnt_x >= 1'b1)
	f <= f + 1'b1;
	else
	f <= 7'd0;
	end
	
	
//时序电路,用来给RGB寄存器赋值
always @ (posedge VGA_clk or negedge rst_n) begin    //每个时钟上升沿赋值
	if(!rst_n)begin
	n <= 7'd0;
	RGB <= 8'd0;
	end
	else if(!pic_en)
	RGB <= M;
	
	else if(n == cnt_x)
	n <= 7'd0;
	else begin
			if( disp_valid == 1'b1)
					begin
					
						case (f)
							
						0:		if(rom_addr16 >= flag_square_begin + N*200 && rom_addr16 <= flag_square_begin + (N+1)*cnt_x + N*80)
								begin
								RGB <= M;
								n <= n + 1;
								end
								else begin
								RGB <= 8'd0;
								n <= 1'b0;
								end
																	
																	
						N :		if(rom_addr16 >= flag_square_begin + N*200 && rom_addr16 <= flag_square_begin + (N+1)*cnt_x + N*80)
								begin
								RGB <= M;
								n <= n + 1;
								end
								else begin
								RGB <= 8'd0;
								n <= 1'b0;
								end
								
						endcase
			
					end
			end	
	end
	
endmodule

