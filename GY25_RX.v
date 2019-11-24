module GY25_RX(clk,rst_n,rs232_rx,data_byte,rx_done,bps_cnt
    );
  input wire 	  clk;
  input wire 	  rst_n;
  input wire 	  rs232_rx;
  
  output reg [7:0]data_byte;
  output reg 	  rx_done;
  output reg [7:0]bps_cnt;
  
  wire 		neged;
  reg 		UART_state;
  reg [8:0]	cnt;
  reg		bps_clk;
  reg [2:0]	r_date_byte[7:0];
  reg [7:0]	tmp_date_byte;
  reg 		s0_rs232_rx;
  reg 		s1_rs232_rx;
  reg 		tmp0_rs232_rx;
  reg 		tmp1_rs232_rx;
  reg [2:0]	start_bit;
  reg [2:0]	end_bite;

	//同步寄存，消除亚稳态//////////////////////
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
				s0_rs232_rx<=0;
				s1_rs232_rx<=0;
			end
		else
			begin
				s0_rs232_rx<=rs232_rx;
				s1_rs232_rx<=s0_rs232_rx;
			end 
	end 
	//检测下降沿/////////////////////////////////////
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		 begin
			tmp0_rs232_rx<=0;
			tmp1_rs232_rx<=0;
		 end
		else 
		 begin
			tmp0_rs232_rx<=s1_rs232_rx;
			tmp1_rs232_rx<=tmp0_rs232_rx;
		 end 
		end 
	assign neged=!tmp0_rs232_rx & tmp1_rs232_rx;//检测下降沿/
	//串口状态////////////////////////////
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			UART_state<=0;
		else if(neged)
			UART_state<=1;
		else if(bps_cnt==159||((bps_cnt==12)&&(start_bit>2)))
			UART_state<=0;
	end
	/////////////////////////////////////////
	always @(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		cnt<=0;
	else if(UART_state) begin
		if(cnt==26)
			cnt<=0;
		else 
			cnt<=cnt+1;
		end
		else
		cnt<=0;
	end
	//波特率时钟///////////////////////////////   
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			bps_clk<=0;
		else if(cnt==1)
			bps_clk<=1;
		else 
			bps_clk<=0;
	end
	//发送完成信号////////////////////////////
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			rx_done<=0;
		else if(bps_cnt==159)
			rx_done<=1;
		else
			rx_done<=0;
	end
	//波特率时钟计数器//////////////////////////
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			bps_cnt<=0;
		else if(bps_cnt==159||((bps_cnt==12)&&(start_bit>2)))
				bps_cnt<=0;
		else if(bps_clk)
				bps_cnt<=bps_cnt+1;
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			start_bit<=3'b0;
			r_date_byte[0]<=3'b0;
			r_date_byte[1]<=3'b0;
			r_date_byte[2]<=3'b0;
			r_date_byte[3]<=3'b0;
			r_date_byte[4]<=3'b0;
			r_date_byte[5]<=3'b0;
			r_date_byte[6]<=3'b0;
			r_date_byte[7]<=3'b0;
			end_bite<=3'b0;
		end
		else if(bps_clk) begin
			case(bps_cnt)
			1:begin
				start_bit<=3'b0;
				r_date_byte[0]<=3'b0;
				r_date_byte[1]<=3'b0;
				r_date_byte[2]<=3'b0;
				r_date_byte[3]<=3'b0;
				r_date_byte[4]<=3'b0;
				r_date_byte[5]<=3'b0;
				r_date_byte[6]<=3'b0;
				r_date_byte[7]<=3'b0;
				end_bite<=3'b0;
			end
			6,7,8,9,10,11:           start_bit<=start_bit+rs232_rx;          
			22,23,24,25,26,27:       r_date_byte[0]<=r_date_byte[0]+rs232_rx;
			38,39,40,41,42,43:       r_date_byte[1]<=r_date_byte[1]+rs232_rx;
			54,55,56,57,58,59:       r_date_byte[2]<=r_date_byte[2]+rs232_rx;
			70,71,72,73,74,75:       r_date_byte[3]<=r_date_byte[3]+rs232_rx;
			86,87,88,89,90,91:       r_date_byte[4]<=r_date_byte[4]+rs232_rx;
			102,103,104,105,106,107: r_date_byte[5]<=r_date_byte[5]+rs232_rx;
			118,119,120,121,122,123: r_date_byte[6]<=r_date_byte[6]+rs232_rx;
			134,135,136,137,138,139: r_date_byte[7]<=r_date_byte[7]+rs232_rx;
			150,151,152,153,154,155: end_bite<=end_bite+rs232_rx;
			default: ;
			endcase
		end
	end
	always @(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
	tmp_date_byte<=0;
	else if(bps_cnt==159)begin
		tmp_date_byte[0]<=r_date_byte[0][2];
		tmp_date_byte[1]<=r_date_byte[1][2];
		tmp_date_byte[2]<=r_date_byte[2][2];
		tmp_date_byte[3]<=r_date_byte[3][2];
		tmp_date_byte[4]<=r_date_byte[4][2];
		tmp_date_byte[5]<=r_date_byte[5][2];
		tmp_date_byte[6]<=r_date_byte[6][2];
		tmp_date_byte[7]<=r_date_byte[7][2];
		end
	else
		tmp_date_byte<=8'b0;
	end
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			data_byte<=0;
		else if(rx_done)
			data_byte<=tmp_date_byte;
		else
			data_byte<=data_byte;
		
	end	  
endmodule
