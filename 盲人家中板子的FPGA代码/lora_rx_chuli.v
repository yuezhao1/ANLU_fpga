`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:57:18 11/20/2019 
// Design Name: 
// Module Name:    lora_rx_chuli 
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
module lora_rx_chuli(
	input clk,
	input rst_n,
	input [7:0]data_tx,

	output  reg [15:0] x
    );
	reg [7:0]data;
	reg [25:0]cnt_1s;
	always@(posedge clk or negedge rst_n)         //1秒计数器
	begin
		if(!rst_n)
			cnt_1s<=1'b0;
		else if(cnt_1s==26'd50000000)//else if(cnt_1s==26'd50000000)
			cnt_1s<=1'b0;
		else cnt_1s<=cnt_1s+1'b1;
	end
	reg [15:0] x_reg;
	reg flag;
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			begin x_reg<=1'b0; data<=1'b0;flag<=1'b0; end
		else 
			begin
				if(cnt_1s==26'd50000000)//if(cnt_1s==26'd50000000)                //1秒
					begin data<=data_tx; x_reg<=1'b0;end
				else if(data>=10'd1000)
					begin 
						x_reg[15:12]<=x_reg[15:12]+1'b1;
						data<=data-10'd1000;
					end 
				else if(data>=8'd100)
					begin 
						x_reg[11:8]<=x_reg[11:8]+1'b1;
						data<=data-8'd100;
					end
				else if(data>=4'd10)
					begin
						x_reg[7:4]<=x_reg[7:4]+1'b1;
						data<=data-4'd10;
					end 
				else if(data>=1'd1)
					begin
						x_reg[3:0]<=x_reg[3:0]+1'b1;
						data<=data-1'd1;
						flag<=1'b1;
					end
				else if(data==1'd0)
					flag<=1'b1;
				else flag<=1'b0;
			 end			
	end 
always@(*)
begin
	if(flag)
		x<=x_reg;
		else x<=x;
end 
endmodule
