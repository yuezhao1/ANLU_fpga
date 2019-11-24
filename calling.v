module calling(
 
	input 					clk,rst,
	input 					tx_done,				//uart结束使能,该输入只维持一个时钟周期
	input 					calling_sent_enable_1,	//一个段时间的高电平（源自 点击确认键）
	input 					calling_sent_enable_2,
	
	output reg 				tx_enable,
	output reg	[7:0]		tx_data
	);

	wire 	[87:0]		calling_number_cheng = 88'h34_38_32_31_37_36_32_38_33_37_31;//程宁勃
	wire	[87:0]		calling_number_zhi = 88'h39_32_33_36_35_38_31_39_35_35_31;//支梦巡
	reg		[87:0]		calling_number;

	always @(*)
		if(calling_sent_enable_1 == 1)
		calling_number <= calling_number_cheng;
		else if(calling_sent_enable_2 == 1)
		calling_number <= calling_number_zhi;
		else
		calling_number <= calling_number_cheng;
	
	
	reg [31:0]	AT;//AT命令寄存器；
	reg [5:0]	num;
	
	reg [47:0] 	ATE1;	//设置回显，即模块将收到的指令完整的返回给发送给设备，方便调试
	reg [135:0] ATD;	//ATD+"phone_number"+;
	reg [39:0]	ATH;	//挂断电话
	reg [87:0]	COLP;
	
	reg [87:0] phone_number_buf;
	 //手机号的处理
	 always@(posedge clk or negedge rst)
	 if(!rst)	begin
		phone_number_buf <= 0 ;
		end
	 else begin
		phone_number_buf <= calling_number ;
		end
	
	//短发送使能信号的处理  (延时了一个时钟周期，并且获得了两个系统时钟周期的高电平使能信叿)
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
		mess_phone_number_prepared_enable_r1 <= (calling_sent_enable_1 || calling_sent_enable_2) ;
		mess_phone_number_prepared_enable_r2 <= mess_phone_number_prepared_enable_r1 ;
		mess_phone_number_prepared_enable_r3 <= mess_phone_number_prepared_enable_r2 ;
	end
	wire mess_phone_number_prepared_enable_r ;
	assign mess_phone_number_prepared_enable_r = mess_phone_number_prepared_enable_r2 | mess_phone_number_prepared_enable_r3 ;
	
	reg calling_sent_enable;
	always@(posedge clk or negedge rst)
	if(!rst)
		calling_sent_enable <= 0 ;
	else 
		calling_sent_enable <= mess_phone_number_prepared_enable_r ;

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
		message_sent_enable_r1 <= calling_sent_enable;
		message_sent_enable_r2 <= message_sent_enable_r1 ;
	end
	
	parameter T1s = 27'd90_000;
	
	reg[26:0]cnt_T1s;
	reg[10:0]cnt_T5s;
	always@(posedge clk or negedge rst)
	begin
		if(!rst)
		begin
			cnt_T1s <= 26'd0;
		end
		else if(message_sent_enable_r==1)
		begin
			cnt_T1s <= 0 ;
		end
		else if(cnt_T1s == T1s)		//每完成一次计数，就是结束了一绿8bit的ASCII码的发鿿
		begin
		cnt_T1s <= 26'd0;
		end
		else 
		begin
		cnt_T1s <= cnt_T1s + 1'b1;
		end
	end
	
	always@(posedge clk or negedge rst)
	begin
		if(!rst)
		begin
			cnt_T5s <= 26'd0;
		end
		else if(message_sent_enable_r==1)
		begin
			cnt_T5s <= 0 ;
		end
		else if(cnt_T1s == T1s)
		begin	     
			cnt_T5s <= cnt_T5s + 1'b1;
		end
		else 
		begin
			cnt_T5s <= cnt_T5s;
		end
	end
	
	reg message_sent_done_flag ;		//来自下一个发送模块，发鿁完成一组指令的使能信号。高"1"有效,维持丿小段时钟周期
	reg message_sent_enable_en ;		//真正启动发鿁的使能信号。可以发送的期间，长期置高电广"1"有效
	always@(posedge clk or negedge rst)	begin
	if(!rst)	//复位
		message_sent_enable_en <= 0 ;
	else if(message_sent_done_flag==1)	//若结束一组发逿
		message_sent_enable_en <= 0 ;	//可发送使能拉低，不再发鿁，且一直维持低电平
	else if(message_sent_enable_r==1)	//若得到一次发送使胿
		message_sent_enable_en <= 1 ;	//可发送的信号拉高，开始发送，且维持高电平
	end
	
	
	always@(posedge clk or negedge rst)
	begin
		if(!rst)
		begin
			tx_enable <= 1'b0;
			AT <= 32'h0a_0d_54_41;
			COLP <= 88'h0a_0d_31_3d_50_4c_4f_43_2b_54_41;//换行、回车㿁AT+COLP=1的忒序,11
			tx_data <= 8'b0;
			ATE1<=48'h0a_0d_31_45_54_41;
			ATH<=40'h0a_0d_48_54_41;
			num <= 0;
			ATD <= 0 ;
			end
		else if(tx_done)
		begin   
			tx_enable <= 1'b0;
			end
		
		else if(cnt_T1s == T1s && num <= 6'd60 && message_sent_enable_en==1)		//每次发鿁完丿个字符的ASCII码（在时间上），执行丿次下列内宿
		begin
			if((num <= 3) && (cnt_T5s <= 400) )//AT		发鿁A T 回车 换行 => 4*4*8=128，要发鿿128位二进制数，cnt_T5s计到400卿128的发送一条指令时闿+272的时延（等待返回丿个OK＿
			begin
				tx_enable <= 1'b1;
				tx_data <= AT;
				AT <= AT >> 8;
				num <= num + 1'b1;		
				ATD <= {24'h0a0d3b,phone_number_buf,24'h445441};
			end
			//设置号码显示＿6个字笿
			else if( 4 <= num && num <= 9 &&  401 <= cnt_T5s && cnt_T5s <= 700 )//CMGF   6*4*8=192,400+352+148=900 ，故本条指令延时亿148（这个数随意定）
			begin
					tx_enable <= 1'b1;
					tx_data <= ATE1;
					ATE1 <= ATE1 >> 8;
					num <= num + 1'b1;
				end
				
			//拨打号码＿ 17个字笿
			else if( 10 <= num && num <= 26 &&  701 <= cnt_T5s && cnt_T5s <= 1400 )
				begin
					tx_enable <= 1'b1;
					tx_data <= ATD;
					ATD <= ATD >> 8;
					num <= num + 1'b1;
				end
						
			//电话显示 发鿁AT+COLP=1 11个字笿
			else if( 27 <= num && num <= 37 &&  1401 <= cnt_T5s && cnt_T5s <= 1900)
			///&& 901 <= cnt_T5s && cnt_T5s <= 1400 )//COLP
			begin
				tx_enable <= 1'b1;
				tx_data <= COLP;
				COLP <= COLP >> 8;
				num <= num + 1'b1;
			end
			else if(38 <= num && num <= 39 )begin
					num <= num+1'b1 ;
					end
			else if(40 <= num && num <= 41 )begin
				tx_enable <= 1'b0;
				num <= 0 ;
				end 
			else 
			begin
				tx_enable <= 1'b0;
				tx_data <= tx_data;
				num <= num;
				AT <= 32'h0a_0d_54_41;
				COLP <= 88'h0a_0d_31_3d_50_4c_4f_43_2b_54_41;//换行、回车㿁AT+COLP=1的忒序,11
				ATE1<=48'h0a_0d_31_45_54_41;
				ATH<=40'h0a_0d_48_54_41;
			end
		end
	end
	
	always@(posedge clk or negedge rst)
	if(!rst)
		message_sent_done_flag <= 0 ;
	else if(1908 <= cnt_T5s && cnt_T5s <= 1999)
		message_sent_done_flag <= 0 ;
	else if(1905 <= cnt_T5s && cnt_T5s <= 1906)		//注意咿223之后还有丿小段时间间隔
		message_sent_done_flag <= 1 ;
	else
		message_sent_done_flag <= message_sent_done_flag ;
	
endmodule
