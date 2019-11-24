module uart_tx_dzj(
	input clk,
	input rst_n,
	input over_tx,
	
	output reg [7:0]data_rx,
	output reg send_en,
	output reg over_all
    );
	reg[3:0] cnt;                          	//最大要记到14   I like FPGA,too 一共14个字符
	always@(posedge clk or negedge rst_n)   //数每个字符结束 递 下一个字符的计数器
	begin
	if(!rst_n)begin
	 cnt<=1'b0;over_all<=1'b0;end
	else if(cnt==4'd5)
	 cnt<=1'b0;
	else if(cnt==4'd4)
	 over_all<=1'b1; 
	else if(over_tx)
	 cnt<=cnt+1'b1;
	else begin cnt<=cnt; over_all<=over_all; end
	end 
	
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			send_en<=1'b1;
		else if(cnt==4'b0011&over_tx)
			send_en<=1'b0;
		else send_en<=send_en;
	end 
	
	always@(*)
	       begin
		   case(cnt)
		    4'd1 : data_rx <= 8'hA5; //0xA5+0x51:查询模式，直接返回角度值，需每次读取都发送 
			4'd2 : data_rx <= 8'h54;     //矫正俯仰角0度
			4'd3 : data_rx <= 8'hA5;  //0xA5+0x52:自动模式，直接返回角度值，只需要初始化时发一次
			4'd4 : data_rx <= 8'h52;
			endcase
		   end
endmodule