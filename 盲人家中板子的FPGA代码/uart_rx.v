`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:25:16 11/25/2018 
// Design Name: 
// Module Name:    uart_rx 
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
module uart_rx(
    input clk,
	input rst_n,
	input bps_clk,
	input data_rx,
	output [7:0]data_tx,
	output reg over_rx,                         //接受结束标志 0表示没在接受数据 1表示正在接受数据
	output reg bps_start,
	output nedge                                                //开始位 下降沿检测标志
	);
	reg [1:0]tmp_rx;                       //下降沿检测所用寄存器
	           
	reg[3:0]num;                           //最大到10 计数
	reg[7:0]data_rx0;                      //第一个寄存器 存每个bit位的数据
	reg[7:0]data_rx1;                      //第二个寄存器 存一个字节的
	always@(posedge clk or negedge rst_n)  //移位寄存器 检测下降沿
	  begin
	  if(!rst_n)  tmp_rx<=2'b11;
	  else
	    begin
	    tmp_rx[0]<=data_rx;
	    tmp_rx[1]<=tmp_rx[0];
	    end
	  end
	assign nedge=~tmp_rx[0]&tmp_rx[1];
	
	always@(posedge clk or negedge rst_n)
	begin
	 if(!rst_n)
	  begin
	    bps_start<=1'b0;
		over_rx  <=1'b0;
	  end
	 else if(!over_rx)
	  begin
	   if(nedge)
	    begin
	    bps_start<=1'b1;
	    over_rx  <=1'b1;
	    end
	  end
	 else if(num==4'd10)
	  begin
	   bps_start<=1'b0;
	   over_rx  <=1'b0;
	  end
	end
	
	always@(posedge clk or negedge rst_n)
	 begin
	   if(!rst_n)
	    begin
	    data_rx0<=1'd0;
		data_rx1<=1'd0;
		num     <=1'd0;
	    end
	   else if(over_rx)
	    begin
		  if(bps_clk)
		    begin
		     num<=num+1'b1;
			 case(num)
			    4'd1: data_rx0[0]<=data_rx;
				4'd2: data_rx0[1]<=data_rx;
				4'd3: data_rx0[2]<=data_rx;
				4'd4: data_rx0[3]<=data_rx;
				4'd5: data_rx0[4]<=data_rx;
				4'd6: data_rx0[5]<=data_rx;
				4'd7: data_rx0[6]<=data_rx;
				4'd8: data_rx0[7]<=data_rx;
			 default: ;
			 endcase
			end
		  else if(num==4'd10)
		    begin
			data_rx1<=data_rx0;
			num<=4'd0;
		    end
		end
	 end
	assign data_tx=data_rx1;
endmodule
