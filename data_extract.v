module data_extract(clk,rst_n,date_byte,angle,rx_done,bps_cnt,byte1
    );
	input  wire 	   clk;
	input  wire 	   rst_n;
	input  wire [7:0]  date_byte;
	input  wire 	   rx_done;
	input  wire	[7:0]  bps_cnt;
	
	output reg  [7:0]  angle;
	output reg 	[7:0]  byte1 ;
	
	reg 		s_sign ; 		 //帧头高电平标志
	
	reg			s_sign_1;
	reg 		s_sign_2;
	wire 		neged 	;		 //帧头高电平标志下降沿
	reg  [1:0]	fy_byte_cnt;		 //对俯仰角的BYTE计数
	reg  [3:0]  byte_cnt  ;		 //对所有byte计数
	reg 		fuyang_angle;   //俯仰角高电平标志
  	reg	 [7:0]	freq_cnt    ;     //采样频率计数器
	reg  [7:0] 	byte2;			 //俯仰角高 8 位 ,航向角低 8 位
	wire [15:0]	fs;				 //负数

	always @(posedge clk or negedge rst_n)
	begin 
		if(!rst_n)
			byte_cnt <= 0;
		else if(byte_cnt==8) //帧结束标志
			byte_cnt <= 0;
		else if( rx_done == 1)
			byte_cnt <= byte_cnt + 1;
		else 
			byte_cnt <= byte_cnt;			
	end 
	
	always @(posedge clk or negedge rst_n)
	begin 
		if(!rst_n)
				s_sign <= 0;
		else if(byte_cnt==4'b0011)
				s_sign <= 1;
		else 
				s_sign <= 0;
	end 
	always @(posedge clk or negedge rst_n)
	begin 
		if(!rst_n)
			begin 
				s_sign_1 <= 0;
		        s_sign_2 <= 0;
			end 
		else 
			begin
				s_sign_1 <= s_sign;
				s_sign_2 <= s_sign_1;
			end 
	end 
	
	assign neged = ~s_sign_1 & s_sign_2;
	
    always @(posedge clk or negedge rst_n)
	begin 
		if(!rst_n)
			fuyang_angle <= 0;
		else if (neged == 1 && freq_cnt == 1 )
			fuyang_angle <= 1;
		else if(fy_byte_cnt == 2)
			fuyang_angle <= 0;
		else 
			fuyang_angle <= fuyang_angle;
	end 

  	always @(posedge clk or negedge rst_n)
	begin 
		if(!rst_n)
			freq_cnt <= 0 ;
		else if(freq_cnt == 3)
			freq_cnt <= 0;
		else if(neged == 1)
			freq_cnt <= freq_cnt+1;
		else 
			freq_cnt <= freq_cnt;
	end   
	always @(posedge clk or negedge rst_n)
	begin 
		if(!rst_n)
			fy_byte_cnt <= 0;
		else if(freq_cnt == 2 && fuyang_angle == 1)
				if(rx_done == 1)
					fy_byte_cnt <= fy_byte_cnt + 1;
				else 
					fy_byte_cnt <= fy_byte_cnt ;
		else 
			fy_byte_cnt <= 0;
	end 
	always @(posedge clk or negedge rst_n)
	begin 
		if(!rst_n)	
			begin 
				byte1 <= 0;
				byte2 <= 0;
			end 
		else if(fuyang_angle == 1)
				begin 
					if(fy_byte_cnt == 0 && bps_cnt== 80) 
						byte1 <= date_byte;
					else if(fy_byte_cnt == 1 && bps_cnt== 80)
						byte2 <= date_byte;
					else 
						begin 
							byte1 <= byte1;
							byte2 <= byte2;
						end 
				end 
		else 
			begin 
				byte1 <= byte1;
				byte2 <= byte2;
			end 
	end 
		
	assign fs = (byte1[7] == 1) ? ( ~{byte1[7:0], byte2[7:0]}) : 0;
	always@(posedge clk or negedge rst_n)
	begin 
		if(!rst_n) 
			angle <= 0;
		else if(fy_byte_cnt == 2)
				begin 
				if(byte1[7] == 1'b1)			//负数的时候取反加一
					angle <= (fs +1'b1)*41>>12;	//*41>>12 = /100		
				else 
					angle <= ({byte1[7:0] , byte2[7:0]})*41>>12;
				end 
		else 
			angle <= angle;
	end 		
endmodule
