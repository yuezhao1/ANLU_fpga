module uart_tx(	
	input clk,
	input bps_clk,
	input send_en,
	input rst_n,
	input[7:0]data_rx,
	
	output reg RX232,
	output reg over_rx,     //结束后会有一个高电平
	output reg bps_start
    );
	reg [3:0]cnt;   //数高电平用的计数器
	always@(posedge clk or negedge rst_n)  //计数器
	begin
	 if(!rst_n)
	  cnt<=1'b0;
	 else if(cnt==4'd11)
	  cnt<=4'd0;
	 else if(bps_clk)
	  cnt<=cnt+1'b1;
	 else cnt<=cnt;
	end 
	
	always@(posedge clk or negedge rst_n)
	begin
	 if(!rst_n)
	  over_rx<=1'b0;
	 else if(cnt==4'd11)
	  over_rx<=1'b1;
	 else over_rx<=1'b0;
	end
    
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		bps_start<=1'b0;
	else if(send_en)
		bps_start<=1'b1;
	else if(over_rx)
		bps_start<=1'b0;
	else bps_start<=bps_start;
	end
	
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		RX232<=1'b1;
	else 
	    begin
		case(cnt)
		0: RX232<=1'b1;
		1: RX232<=1'b0;
		2: RX232<=data_rx[0];
		3: RX232<=data_rx[1];
		4: RX232<=data_rx[2];
		5: RX232<=data_rx[3];
		6: RX232<=data_rx[4];
		7: RX232<=data_rx[5];
		8: RX232<=data_rx[6];
		9: RX232<=data_rx[7];
		10:RX232<=1'b1;
		endcase
		end
	end
endmodule


