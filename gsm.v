module gsm(  
	input			 			clk,rst,
	input		[183:0] 		TEXT_buf,
	input 						tx_done,//uart结束使能,该输入只维持一个时钟周期
	input 						mess_phone_number_prepared_enable, //一个段时间的高电平（源自 点击确认键）

	output 	reg 				tx_enable,
	output 	reg	[7:0]			tx_data
	);

	wire		[183:0]			TEXT_buf_r;
	
	
	assign 		TEXT_buf_r[7:0]							= TEXT_buf[183:176];
	assign 		TEXT_buf_r[15:8]						= TEXT_buf[175:168];	
	assign 		TEXT_buf_r[23:16]						= TEXT_buf[167:160];	
	assign 		TEXT_buf_r[31:24]						= TEXT_buf[159:152];
	assign 		TEXT_buf_r[39:32]					 	= TEXT_buf[151:144];	
	assign 		TEXT_buf_r[47:40]					 	= TEXT_buf[143:136];		
	assign 		TEXT_buf_r[55:48]					 	= TEXT_buf[135:128];
	assign 		TEXT_buf_r[63:56]					 	= TEXT_buf[127:120];
	assign 		TEXT_buf_r[71:64]						= TEXT_buf[119:112];
	assign 		TEXT_buf_r[79:72]						= TEXT_buf[111:104];
	assign 		TEXT_buf_r[87:80]						= TEXT_buf[103:96];
	assign 		TEXT_buf_r[95:88]						= TEXT_buf[95:88];
	assign 		TEXT_buf_r[103:96]						= TEXT_buf[87:80];
	assign 		TEXT_buf_r[111:104]				 		= TEXT_buf[79:72];
	assign 		TEXT_buf_r[119:112]					 	= TEXT_buf[71:64];
	assign 		TEXT_buf_r[127:120]				 		= TEXT_buf[63:56];
	assign 		TEXT_buf_r[135:128]					 	= TEXT_buf[55:48];
	assign 		TEXT_buf_r[143:136]						= TEXT_buf[47:40];
	assign 		TEXT_buf_r[151:144]						= TEXT_buf[39:32];
	assign 		TEXT_buf_r[159:152]						= TEXT_buf[31:24];
	assign 		TEXT_buf_r[167:160]						= TEXT_buf[23:16];
	assign 		TEXT_buf_r[175:168]					 	= TEXT_buf[15:8];
	assign 		TEXT_buf_r[183:176]					 	= TEXT_buf[7:0];
			

	

	reg			[383:0]			TEXT_buf_1;
	
	always@(posedge clk or negedge rst)
		if(!rst)
		TEXT_buf_1 <= 1'b0;
		else
		TEXT_buf_1 <= {	TEXT_buf_r,								
						8'h0A,								
						8'h21,8'h67,8'h6E,8'h69,8'h6E,8'h72,8'h61,8'h77,								
						8'h21,8'h67,8'h6E,8'h69,8'h6E,8'h72,8'h61,8'h77,								
						8'h21,8'h67,8'h6E,8'h69,8'h6E,8'h72,8'h61,8'h77};								
										
	
	wire 	[87:0] 			phone_number_buf=88'h34_38_32_31_37_36_32_38_33_37_31;//程宁勃
	reg		[31:0]			AT;//AT命令寄存器;
	reg		[119:0]			CSCS;//AT+CSCS="GSM",设置为 GSM 编码字符集
	reg		[87:0]			CMGF;//AT+CMGF=1
	reg		[183:0]			CMGS;//AT + CMGS="phone_number"
	reg		[383:0]			TEXT;//message
	reg		[7:0]			jieshu;
	reg		[6:0]			num;
	
	reg message_sent_enable;
	 //短信发送使能信号的处理  (延时了一个时钟周期，并且获得了两个系统时钟周期的高电平使能信号)
	 reg mess_phone_number_prepared_enable_r1 ;
	 reg mess_phone_number_prepared_enable_r2 ;
	 reg mess_phone_number_prepared_enable_r3 ;
	 always@(posedge clk or negedge rst)
	 if(!rst)	begin
		mess_phone_number_prepared_enable_r1 <= 0 ;
		mess_phone_number_prepared_enable_r2 <= 0 ;
		mess_phone_number_prepared_enable_r3 <= 0 ;
	 end
	 else	begin
		mess_phone_number_prepared_enable_r1 <= mess_phone_number_prepared_enable ;
		mess_phone_number_prepared_enable_r2 <= mess_phone_number_prepared_enable_r1 ;
		mess_phone_number_prepared_enable_r3 <= mess_phone_number_prepared_enable_r2 ;
	 end
	 wire mess_phone_number_prepared_enable_r ;
	 assign mess_phone_number_prepared_enable_r = mess_phone_number_prepared_enable_r2 | mess_phone_number_prepared_enable_r3 ;
	 always@(posedge clk or negedge rst)
	 if(!rst)
		message_sent_enable <= 0 ;
	 else 
		message_sent_enable <= mess_phone_number_prepared_enable_r ;
	
	reg message_sent_enable_r1;
	reg message_sent_enable_r2;
	wire message_sent_enable_r;
	assign message_sent_enable_r = message_sent_enable_r1 & ~message_sent_enable_r2 ;
	always@(posedge clk or negedge rst)
	if(!rst)	begin
		message_sent_enable_r1 <= 0;
		message_sent_enable_r2 <= 0;
		end
	else	begin
		message_sent_enable_r1 <= mess_phone_number_prepared_enable;
		message_sent_enable_r2 <= message_sent_enable_r1 ;
		end

	parameter T1s = 27'd90_000;

	reg[26:0]cnt_T1s;
	reg[25:0]cnt_T5s;
	
	always@(posedge clk or negedge rst)
	begin
		if(!rst) begin
			cnt_T1s <= 26'd0;
			end
		else if(message_sent_enable_r==1'b1) begin
			cnt_T1s <= 0 ;
			end
		else if(cnt_T1s == T1s)	begin	//每完成一次计数，就是结束了一组8bit的ASCII码的发送		
			cnt_T1s <= 26'd0;
			end
		else begin
			cnt_T1s <= cnt_T1s + 1'b1;
			end
	end
 
	always@(posedge clk or negedge rst)
	begin
		if(!rst) begin
			cnt_T5s <= 26'd0;
			end
		else if(message_sent_enable_r==1'b1) begin
			cnt_T5s <= 0 ;
			end
		else if(cnt_T1s == T1s) begin	     
			cnt_T5s <= cnt_T5s + 1'b1;
			end
		else begin
			cnt_T5s <= cnt_T5s;
			end
	end
 
	reg message_sent_done_flag ;		//来自下一个发送模块，发送完成一组指令的使能信号。高"1"有效,维持一小段时钟周期
	reg message_sent_enable_en ;		//真正启动发送的使能信号。可以发送的期间，长期置高电平"1"有效
	always@(posedge clk or negedge rst)	
	begin
		if(!rst)	//复位
			message_sent_enable_en <= 0 ;
		else if(message_sent_done_flag==1'b1)	//若结束一组发送
			message_sent_enable_en <= 0 ;	//可发送使能拉低，不再发送，且一直维持低电平
		else if(message_sent_enable_r==1'b1)	//若得到一次发送使能
			message_sent_enable_en <= 1 ;	//可发送的信号拉高，开始发送，且维持高电平
	end
 
 
	always@(posedge clk or negedge rst)
	begin
		if(!rst) begin
			tx_enable <= 1'b0;
			AT <= 32'h0a_0d_54_41;
			tx_data <= 8'b0;
			CSCS <= 120'h0a_0d_22_4d_53_47_22_3d_53_43_53_43_2b_54_41;//换行、回车、AT+CSCS="GSM"的倒序,15
			CMGF <= 88'h0a_0d_31_3d_46_47_4d_43_2b_54_41;//换行、回车、AT+CMGF=1的倒序,11
			jieshu <= 8'h1A;
			TEXT <= 0;
			num <= 0;
			CMGS <= 0 ;
			end
		else if(tx_done) begin   
			tx_enable <= 1'b0;
			end
		else if(cnt_T1s == T1s && num <= 10'd110 && message_sent_enable_en==1) begin	//每次发送完一个字符的ASCII码（在时间上），执行一次下列内容	
			
			if((num <= 2'd3) && (cnt_T5s <= 9'd400) ) begin  //AT 发送A T 回车 换行 => 4*4*8=128，要发送128位二进制数，cnt_T5s计到400即128的发送一条指令时间+272的时延（等待返回一个OK）		
			tx_enable <= 1'b1;
			tx_data <= AT;
			AT <= AT >> 4'd8;
			num <= num + 1'b1;		//这个num还真不能拿到这个always块的外边去做累加，因为他和每次发送一组指令后的等待有关，发送一个数num加一次一，但是发完一组指令需要等待，此时cnt_5s累加，但是num不用累加
			TEXT <= TEXT_buf_1 ;
			CMGS <= {24'h0a0d22,phone_number_buf,72'h223d53474d432b5441};
			end		
		//ATTENTION PLEASE!!! num记到3之后到cnt_T5s之间的这一段时间是空的，因为下一条只有在cnt_T5s记到401时才会开始发送对应指令		
		//发送AT+CSCS="GSM"回车换行，15个字符
			else if( 3'd4 <= num && num <= 5'd18 &&  9'd401 <= cnt_T5s && cnt_T5s <= 10'd900 )//CMGF   11*4*8=352,400+352+148=900 ，故本条指令延时了148（这个数随意定）
			begin
				tx_enable <= 1'b1;
				tx_data <= CSCS;
				CSCS <= CSCS >> 4'd8;
				num <= num + 1'b1;
			end		
			//发送AT+CMGF=1， 11个字符
			else if( 5'd19 <= num && num <= 5'd29 && 10'd901 <= cnt_T5s && cnt_T5s <= 11'd1400 )//CSMP
			begin
				tx_enable <= 1'b1;
				tx_data <= CMGF;
				CMGF <= CMGF >> 8;
				num <= num + 1'b1;
			end		
			//发送CMGS="",23字符
			else if( 30 <= num && num <= 52 && 1401 <= cnt_T5s && cnt_T5s <= 2500 )//CSCS
			begin
				tx_enable <= 1'b1;
				tx_data <= CMGS;
				CMGS <= CMGS >> 4'd8;
				num <= num + 1'b1;
			end
			//发短信，48，字符
			else if( 53 <= num && num <= 100 && 2501 <= cnt_T5s && cnt_T5s <= 4200)//CMGS//1700s
			begin
				tx_enable <= 1'b1;
				tx_data <= TEXT;
				TEXT <= TEXT >> 8;
				num <= num + 1'b1;
			end
			//发1A
			else if( num >= 101 && num <= 102 && 4201 <= cnt_T5s && cnt_T5s <= 4300)//CMGS
			begin
				tx_enable <= 1'b1;
				tx_data <= jieshu;
				jieshu <= jieshu >> 8;
				num <= num + 1'b1;
			end
			else if(103 <= num && num <= 104 && 4301 <= cnt_T5s && cnt_T5s <= 4305) begin
					num <= num+1 ;
					end
			else if(105 <= num && num <= 106 && 4306 <= cnt_T5s && cnt_T5s <= 4308) begin

				tx_enable <= 1'b0;
				num <= num + 1'b1 ;
//				num <= 0;
				end 
			else if(4309 <= cnt_T5s && cnt_T5s <= 4310)
			num <= 0 ;
			else 
			begin
				tx_enable <= 1'b0;
				tx_data <= tx_data;
				num <= num;
				CSCS <= 120'h0a_0d_22_4d_53_47_22_3d_53_43_53_43_2b_54_41;//换行、回车、AT+CSCS="GSM"的倒序,15
				CMGF <= 88'h0a_0d_31_3d_46_47_4d_43_2b_54_41;//换行、回车、AT+CMGF=1的倒序,11
				AT <= 32'h0a_0d_54_41;
				jieshu <= 8'h1A;
				CMGS <= {24'h0a0d22,phone_number_buf,72'h223d53474d432b5441};
			end
		end
	end
	
	always@(posedge clk or negedge rst)
	if(!rst)
	message_sent_done_flag <= 0 ;
	else if(4313 <= cnt_T5s && cnt_T5s <= 4314)
	message_sent_done_flag <= 0 ;
	else if(4311 <= cnt_T5s && cnt_T5s <= 4312)		//注意和223之后还有一小段时间间隔
	message_sent_done_flag <= 1 ;
	else
	message_sent_done_flag <= message_sent_done_flag ;

endmodule
