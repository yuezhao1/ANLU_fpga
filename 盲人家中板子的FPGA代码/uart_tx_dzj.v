`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:44:32 11/24/2018 
// Design Name: 
// Module Name:    uart_tx_dzj 
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
module uart_tx_dzj(
	input [3:0]in_key_en,
	input co,
	input zhendong,
	input clk,
	input rst_n,
	input over_tx,
	
	output reg [7:0]data_rx,
	output reg send_en,
	output reg fengshan
    );
	reg [3:0]cnt;                          	//最大要记到14   I like verilog 一共14个字符
	reg[1:0] flag;                   //判断哪个按键按下 输出不同的话
	always@(posedge clk or negedge rst_n)   //数每个字符结束 递 下一个字符的计数器
	begin
	if(!rst_n)
	 cnt<=1'b0;
	else if(over_tx)
	 cnt<=cnt+1'b1;
	else if(|in_key_en)
	 cnt<=1'b0;
	end 
	reg [1:0]tmp_co;
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			tmp_co<=2'b00;
		else begin
			tmp_co[1]<=co;
			tmp_co[0]<=tmp_co[1];
		end 
	end

	assign co_h=~tmp_co[1]&tmp_co[0];
	
	reg [27:0] cnt_3s;
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			cnt_3s<=1'b0;
		else if(cnt_3s==28'd150000000)
			cnt_3s<=1'b0;
		else cnt_3s<=cnt_3s+1'b1;
	end
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			fengshan<=1'b0;
		else if(!co/*&&cnt_3s==28'd150000000*/)
			fengshan<=1'b1;
		else fengshan<=1'b0;
	end 
	
	
	
	always@(posedge clk or negedge rst_n)
	begin
	 if(!rst_n)
	  flag<=1'b0;
	 else if(co_h)
	  flag<=2'b01;
	 else if(zhendong)
	  flag<=2'b10;
	 else if(in_key_en[2])
	  flag<=2'b11;
	 else flag<=flag;
	end
	
	always@(posedge clk or negedge rst_n)
	 begin
	 if(!rst_n)
	  send_en<=1'b0;
	 else if(co_h|(over_tx&cnt<4'd14))
	  send_en<=1'b1;
	 else if(zhendong|(over_tx&cnt<4'd2))
	  send_en<=1'b1;
	 else if(in_key_en[2]|(over_tx&cnt<4'd2))
	  send_en<=1'b1;
	 else send_en<=1'b0;
	 end
	 
	
	always@(*)
	 begin
	  case(flag)
	    0: ;
	 2'd1: 
	       begin
		   case(cnt)                                                 //烟雾
		    4'd0:data_rx=8'b00000001;  //I
			/*4'd1:data_rx=8'b00100000;  // 
			4'd2:data_rx=8'b01001100;  //L
			4'd3:data_rx=8'b01101001;  //i 
			4'd4:data_rx=8'b01101011;  //k
			4'd5:data_rx=8'b01100101;  //e  
			4'd6:data_rx=8'b00100000;  //
			4'd7:data_rx=8'b01000110;  //F  
			4'd8:data_rx=8'b01010000;  //P 
			4'd9:data_rx=8'b01000111;  //G
			4'd10:data_rx=8'b01000001;  //A */
			endcase
		   end
	 2'd2:
		   begin                                                       //震动
		   case(cnt)
		    4'd0:data_rx=8'b00000010;  //I
			/*4'd1:data_rx=8'b00100000;  // 
			4'd2:data_rx=8'b01001100;  //L
			4'd3:data_rx=8'b01101001;  //i 
			4'd4:data_rx=8'b01101011;  //k
			4'd5:data_rx=8'b01100101;  //e  
			4'd6:data_rx=8'b00100000;  //
			4'd7:data_rx=8'b01010110;  //V 
			4'd8:data_rx=8'b01100101;  //e   
			4'd9:data_rx=8'b01110010;  //r  
			4'd10:data_rx=8'b01101001;  //i 
			4'd11:data_rx=8'b01101100;  //l 
			4'd12:data_rx=8'b01101111;  //o 
			4'd13:data_rx=8'b01100111;  //g */
			endcase
		   end
	 2'd3:
		   begin                                                          //门铃
		    case(cnt)
		      4'd0:data_rx=8'b00000011;  //I
			  /*4'd1:data_rx=8'b00100000;  // 
			  4'd2:data_rx=8'b01001100;  //L
			  4'd3:data_rx=8'b01101001;  //i 
			  4'd4:data_rx=8'b01101011;  //k
			  4'd5:data_rx=8'b01100101;  //e  
			  4'd6:data_rx=8'b00100000;  //
			  4'd7:data_rx=8'b00110001;  //1
			  4'd8:data_rx=8'b00110000;  //0   
			  4'd9:data_rx=8'b00110111;  //7  */ 
			endcase
		   end
	  endcase
	 end
endmodule