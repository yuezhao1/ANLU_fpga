module surf_internet(  
	input			 	clk,rst,
	input 				tx_done,//uart结束使能,该输入只维持一个时钟周期
	input 				mess_phone_number_prepared_enable, //一个段时间的高电平（源自 点击确认键）

	output reg 			tx_enable,
	output reg[7:0]		tx_data

	);
	
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
 
/*	
AT										//AT						2+2
 
AT+SAPBR=3,1,"APN","CMNET" 				//APN						26+2
	                                                                
AT+SAPBR=3,1,"PHONENUM","18329680221"	//PHONENUM                  37+2
	                                                                
AT+SAPBR=4,1							//SAPBR41                   12+2
	                                                                
AT+SAPBR=5,1	                        //SAPBR51                   12+2
	                                                                
AT+SAPBR=1,1	                        //SAPBR11                   12+2
	                                                                
AT+SAPBR=2,1	                        //SAPBR21                   12+2
	                                    
AT+HTTPINIT	                            //HTTPINIT					11+2
	                                    
AT+HTTPPARA="CID","1"	                //CID						21+2
										//URL           			164+2
AT+HTTPPARA="URL","http://api.map.baidu.com/directionlite/v1/walking?origin=34.160585,108.907325&destination=34.1578,108.905183&ak=fQfrhmplBKN1dEP9VPyY9mrRQrIuNzTO"

AT+HTTPACTION=0							//HTTPACTION				15+2

AT+HTTPREAD=1,40037						//HTTPREAD					19+2

AT+HTTPTERM								//HTTPTERM					11+2

AT+SAPBR=0,1							//SAPBR01					12+2						sum = 394	
*/	
	
	
	reg		[31:0]					AT;			//4
	reg		[223:0]					APN;        //28
	reg     [311:0]                 PHONENUM;   //39
	reg     [111:0]                 SAPBR41;    //14
	reg     [111:0]                 SAPBR51;    //14
	reg     [111:0]                 SAPBR11;    //14
	reg     [111:0]                 SAPBR21;    //14
	reg     [103:0]                 HTTPINIT;   //13
	reg     [183:0]                 CID;        //23
	reg     [1327:0]                URL;        //166
	reg     [135:0]                 HTTPACTION; //17
	reg     [167:0]                 HTTPREAD;   //21
	reg     [103:0]                 HTTPTERM;   //13
	reg     [111:0]                 SAPBR01;    //14
	reg		[10:0]					num;        
	
	
 
 
	always@(posedge clk or negedge rst)
	begin
		if(!rst) begin
			tx_enable	<= 1'b0;
			tx_data		<= 8'b0;
			AT			<= 32'h0a_0d_54_41; //换行、回车、AT的倒序
																			//换行、回车、{AT+SAPBR=3,1,"APN","CMNET"}的倒序,28个字符
			APN         <= 224'h0a_0d_22_54_45_4e_4d_43_22_2c_22_4e_50_41_22_2c_31_2c_33_3d_52_42_50_41_53_2b_54_41; 			
																			//换行、回车、{AT+SAPBR=3,1,"PHONENUM","18329680221"}的倒序,39个字符
			PHONENUM    <= 312'h0a_0d_22_31_32_32_30_38_36_39_32_33_38_31_22_2c_22_4d_55_4e_45_4e_4f_48_50_22_2c_31_2c_33_3d_52_42_50_41_53_2b_54_41; 
			SAPBR41     <= 112'h0a_0d_31_2c_34_3d_52_42_50_41_53_2b_54_41; 	//换行、回车、{AT+SAPBR=4,1}的倒序,14个字符
			SAPBR51     <= 112'h0a_0d_31_2c_35_3d_52_42_50_41_53_2b_54_41; 	//换行、回车、{AT+SAPBR=5,1}的倒序,14个字符
			SAPBR11     <= 112'h0a_0d_31_2c_31_3d_52_42_50_41_53_2b_54_41; 	//换行、回车、{AT+SAPBR=1,1}的倒序,14个字符
			SAPBR21     <= 112'h0a_0d_31_2c_32_3d_52_42_50_41_53_2b_54_41; 	//换行、回车、{AT+SAPBR=2,1}的倒序,14个字符
			HTTPINIT    <= 104'h0a_0d_54_49_4e_49_50_54_54_48_2b_54_41; 	//换行、回车、{AT+HTTPINIT}的倒序,13个字符
			CID         <= 184'h0a_0d_22_31_22_2c_22_44_49_43_22_3d_41_52_41_50_50_54_54_48_2b_54_41; //换行、回车、{AT+HTTPPARA="CID","1"}的倒序,23个字符	
																			//换行、回车、{AT+HTTPPARA="URL","http://api.map.baidu.com/directionlite/v1/walking?origin=34.160585,108.907325&destination=34.1578,108.905183&ak=fQfrhmplBKN1dEP9VPyY9mrRQrIuNzTO"}的倒序,166
			URL         <=1328'h0a_0d_22_4f_54_7a_4e_75_49_72_51_52_72_6d_39_59_79_50_56_39_50_45_64_31_4e_4b_42_6c_70_6d_68_72_66_51_66_3d_6b_61_26_33_38_31_35_30_39_2e_38_30_31_2c_38_37_35_31_2e_34_33_3d_6e_6f_69_74_61_6e_69_74_73_65_64_26_35_32_33_37_30_39_2e_38_30_31_2c_35_38_35_30_36_31_2e_34_33_3d_6e_69_67_69_72_6f_3f_67_6e_69_6b_6c_61_77_2f_31_76_2f_65_74_69_6c_6e_6f_69_74_63_65_72_69_64_2f_6d_6f_63_2e_75_64_69_61_62_2e_70_61_6d_2e_69_70_61_2f_2f_3a_70_74_74_68_22_2c_22_4c_52_55_22_3d_41_52_41_50_50_54_54_48_2b_54_41; //换行、回车、{AT+HTTPPARA="URL","http://api.map.baidu.com/directionlite/v1/walking?origin=34.160585,108.907325&destination=34.1578,108.905183&ak=fQfrhmplBKN1dEP9VPyY9mrRQrIuNzTO"}的倒序,166
		
			HTTPACTION  <= 136'h0a_0d_30_3d_4e_4f_49_54_43_41_50_54_54_48_2b_54_41;//换行、回车、{AT+HTTPACTION=0}的倒序,17个字符

			HTTPREAD    <= 168'h0a_0d_37_33_30_30_34_2c_31_3d_44_41_45_52_50_54_54_48_2b_54_41;//换行、回车、{AT+HTTPREAD=1,40037}的倒序,21个字符
			
			HTTPTERM    <= 104'h0a_0d_4d_52_45_54_50_54_54_48_2b_54_41;//换行、回车、{AT+HTTPTERM}的倒序,13个字符
			
			SAPBR01     <= 112'h0a_0d_31_2c_30_3d_52_42_50_41_53_2b_54_41;//换行、回车、{AT+SAPBR=0,1}的倒序,14个字符
			
			num <= 0;
			end
		else if(tx_done) begin   
			tx_enable <= 1'b0;
			end
		else if(cnt_T1s == T1s && num <= 11'd401 && message_sent_enable_en==1) begin//每次发送完一个字符的ASCII码（在时间上），执行一次下列内容	
		
			if((num <= 8'd3) && (cnt_T5s <= 9'd400) )  //AT 发送A T 回车 换行 => 4*4*8=128，要发送128位二进制数，cnt_T5s计到400即128的发送一条指令时间+272的时延（等待返回一个OK）
			begin 		
				tx_enable 	<= 1'b1;
				tx_data		<= AT;
				num 		<= num + 1'b1;//这个num还真不能拿到这个always块的外边去做累加，因为他和每次发送一组指令后的等待有关，发送一个数num加一次一，但是发完一组指令需要等待，此时cnt_5s累加，但是num不用累加
				AT 			<= AT >> 4'd8;		
			end		
		//ATTENTION PLEASE!!! num记到3之后到cnt_T5s之间的这一段时间是空的，因为下一条只有在cnt_T5s记到401时才会开始发送对应指令		
		//发送{AT+SAPBR=3,1,"APN","CMNET"}换行、回车的倒序,28个字符
			else if( 3'd4 <= num && num <= 11'd31 &&  9'd401 <= cnt_T5s && cnt_T5s <= 26'd1400 )//APN   28*4*8=896,400+896+104=1400 ,故本条指令延时了104（这个数随意定）
			begin
				tx_enable <= 1'b1;
				tx_data <= APN;
				APN <= APN >> 4'd8;
				num <= num + 1'b1;
			end		
			//{AT+SAPBR=3,1,"PHONENUM","18329680221"}换行、回车的倒序,39个字符
			else if( 11'd32 <= num && num <= 11'd70 && 1401 <= cnt_T5s && cnt_T5s <= 2800 )//PHONENUM	39*4*8=1248,1400+1248+152=2800,故本条指令延时了152（这个数随意定）
			begin
				tx_enable <= 1'b1;
				tx_data <= PHONENUM;
				PHONENUM <= PHONENUM >> 4'd8;
				num <= num + 1'b1;
			end		
			//发送{AT+SAPBR=4,1}换行、回车的倒序,14个字符															
			else if( 11'd71 <= num && num <= 11'd84 && 2801 <= cnt_T5s && cnt_T5s <= 3400 )//SAPBR41	14*4*8=448,2800+448+152=3400,
			begin                                                                                                   
				tx_enable <= 1'b1;                                                                                  
				tx_data <= SAPBR41;
				SAPBR41 <= SAPBR41 >> 4'd8;
				num <= num + 1'b1;
			end
			//发送{AT+SAPBR=5,1}换行、回车的倒序,14个字符
			else if( 85 <= num && num <= 98 && 3401 <= cnt_T5s && cnt_T5s <= 4000)//SAPBR51		14*4*8=448,3400+448+152=4000,
			begin
				tx_enable <= 1'b1;
				tx_data <= SAPBR51;
				SAPBR51 <= SAPBR51 >> 4'd8;
				num <= num + 1'b1;
			end
			//发送{AT+SAPBR=1,1}换行、回车的倒序,14个字符
			else if( 99 <= num && num <= 112 && 4001 <= cnt_T5s && cnt_T5s <= 10600)//SAPBR11	14*4*8=448,4000+448+6152=10600,
			begin
				tx_enable <= 1'b1;
				tx_data <= SAPBR11;
				SAPBR11 <= SAPBR11 >> 4'd8;
				num <= num + 1'b1;
			end
			//发送{AT+SAPBR=2,1}换行、回车的倒序,14个字符
			else if( 113 <= num && num <= 126 && 10601 <= cnt_T5s && cnt_T5s <= 13200)//SAPBR21	14*4*8=448,10600+448+2152=13200
			begin
				tx_enable <= 1'b1;
				tx_data <= SAPBR21;
				SAPBR21 <= SAPBR21 >> 4'd8;
				num <= num + 1'b1;
			end		
			
			//发送{AT+HTTPINIT}换行、回车的倒序,13个字符
			else if( 127 <= num && num <= 139 && 13201 <= cnt_T5s && cnt_T5s <= 15800)//13*4*8=416,13200+416+184=15800
			begin
				tx_enable <= 1'b1;
				tx_data <= HTTPINIT;
				HTTPINIT <= HTTPINIT >> 4'd8;
				num <= num + 1'b1;
			end			
			//发送{AT+HTTPPARA="CID","1"}换行、回车的倒序,23个字符
			else if( 140 <= num && num <= 162 && 15801 <= cnt_T5s && cnt_T5s <= 18700)//23*4*8=416,15800+736+2164=18700
			begin                                                                                                   			
				tx_enable <= 1'b1;                                                                             					     	
				tx_data <= CID;                                                                                					    
				CID <= CID >> 4'd8;                                                                            					  	 	
				num <= num + 1'b1;                                                                             					     
			end			                                                                                       					    	
			
			//发送{AT+HTTPPARA="URL"....}换行、回车的倒序,166个字符		
			else if( 163 <= num && num <= 328 && 18701 <= cnt_T5s && cnt_T5s <= 30200)//166*4*8=5312,18700+5312+6188=30200  		    
			begin                                                                                                   			
				tx_enable <= 1'b1;                                                                             					
				tx_data <= URL;                                                                                					
				URL <= URL >> 4'd8;                                                                            					
				num <= num + 1'b1;                                                                             					
			end			                                                                                       					
			                                                                                                                    
			//发送{AT+HTTPACTION=0}换行、回车的倒序,17个字符	                                                    
			else if( 329 <= num && num <= 345 && 30201 <= cnt_T5s && cnt_T5s <= 31900)//17*4*8=544,30200+544+1156=31900
			begin                                                                                 			
				tx_enable <= 1'b1;                                                                			
				tx_data <= HTTPACTION;                                                             					
				HTTPACTION <= HTTPACTION >> 4'd8;                                                         					
				num <= num + 1'b1;                                                                			
			end			                                                                          			
			
			//发送{AT+HTTPREAD=1,40037}换行、回车的倒序,21个字符
			else if( 346 <= num && num <= 366 && 31901 <= cnt_T5s && cnt_T5s <= 35700)//21*4*8=672,31900+672+3128=35700			
			begin                                                                                 			
				tx_enable <= 1'b1;                                                                			
				tx_data <= HTTPREAD;                                                              					
				HTTPREAD <= HTTPREAD >> 4'd8;                                                         					
				num <= num + 1'b1;                                                                			
			end			                                                                          			
			
			//发送{AT+HTTPTERM}换行、回车的倒序,13个字符
			else if( 367 <= num && num <= 379 && 35701 <= cnt_T5s && cnt_T5s <= 38300)//13*4*8=416,35700+416+2184=38300
			begin                                                                                 
				tx_enable <= 1'b1;                                                                
				tx_data <= HTTPTERM;                                                              		
				HTTPTERM <= HTTPTERM >> 4'd8;                                                         		
				num <= num + 1'b1;                                                                
			end			                                                                          

			//发送{AT+SAPBR=0,1}换行、回车的倒序,14个字符
			else if( 380 <= num && num <= 393 && 38301 <= cnt_T5s && cnt_T5s <= 40900)//14*4*8=448,38300+448+2152=40900
			begin                                                                                                   
				tx_enable <= 1'b1;                                                                             		
				tx_data <= SAPBR01;                                                                                		
				SAPBR01 <= SAPBR01 >> 4'd8;                                                                            		
				num <= num + 1'b1;                                                                             					
			end			                                                                                       					
			
			else if(394 <= num && num <= 395 && 40901 <= cnt_T5s && cnt_T5s <= 40905)
				begin
					num <= num+1 ;
				end
			else if(396 <= num && num <= 397 && 40906 <= cnt_T5s && cnt_T5s <= 40908)
				begin
					tx_enable <= 1'b0;
					num <= num + 1'b1 ;
//					num <= 0;
				end 
			else if(40909 <= cnt_T5s && cnt_T5s <= 40910)
			num <= 0 ;
			else 
			begin
				tx_enable	<= 1'b0;
				tx_data		<= tx_data;
				num			<= num;
				AT			<= 32'h0a_0d_54_41; //换行、回车、AT的倒序
																				//换行、回车、{AT+SAPBR=3,1,"APN","CMNET"}的倒序,28个字符
				APN			<= 224'h0a_0d_22_54_45_4e_4d_43_22_2c_22_4e_50_41_22_2c_31_2c_33_3d_52_42_50_41_53_2b_54_41; 			
																				//换行、回车、{AT+SAPBR=3,1,"PHONENUM","18329680221"}的倒序,39个字符
				PHONENUM	<= 312'h0a_0d_22_31_32_32_30_38_36_39_32_33_38_31_22_2c_22_4d_55_4e_45_4e_4f_48_50_22_2c_31_2c_33_3d_52_42_50_41_53_2b_54_41; 
				SAPBR41		<= 112'h0a_0d_31_2c_34_3d_52_42_50_41_53_2b_54_41; 	//换行、回车、{AT+SAPBR=4,1}的倒序,14个字符
				SAPBR51		<= 112'h0a_0d_31_2c_35_3d_52_42_50_41_53_2b_54_41; 	//换行、回车、{AT+SAPBR=5,1}的倒序,14个字符
				SAPBR11		<= 112'h0a_0d_31_2c_31_3d_52_42_50_41_53_2b_54_41; 	//换行、回车、{AT+SAPBR=1,1}的倒序,14个字符
				SAPBR21		<= 112'h0a_0d_31_2c_32_3d_52_42_50_41_53_2b_54_41; 	//换行、回车、{AT+SAPBR=2,1}的倒序,14个字符
				HTTPINIT	<= 104'h0a_0d_54_49_4e_49_50_54_54_48_2b_54_41; 	//换行、回车、{AT+HTTPINIT}的倒序,13个字符
				CID			<= 184'h0a_0d_22_31_22_2c_22_44_49_43_22_3d_41_52_41_50_50_54_54_48_2b_54_41; //换行、回车、{AT+HTTPPARA="CID","1"}的倒序,23个字符	
																				//换行、回车、{AT+HTTPPARA="URL","http://api.map.baidu.com/directionlite/v1/walking?origin=34.160585,108.907325&destination=34.1578,108.905183&ak=fQfrhmplBKN1dEP9VPyY9mrRQrIuNzTO"}的倒序,166
				URL			<=1328'h0a_0d_22_4f_54_7a_4e_75_49_72_51_52_72_6d_39_59_79_50_56_39_50_45_64_31_4e_4b_42_6c_70_6d_68_72_66_51_66_3d_6b_61_26_33_38_31_35_30_39_2e_38_30_31_2c_38_37_35_31_2e_34_33_3d_6e_6f_69_74_61_6e_69_74_73_65_64_26_35_32_33_37_30_39_2e_38_30_31_2c_35_38_35_30_36_31_2e_34_33_3d_6e_69_67_69_72_6f_3f_67_6e_69_6b_6c_61_77_2f_31_76_2f_65_74_69_6c_6e_6f_69_74_63_65_72_69_64_2f_6d_6f_63_2e_75_64_69_61_62_2e_70_61_6d_2e_69_70_61_2f_2f_3a_70_74_74_68_22_2c_22_4c_52_55_22_3d_41_52_41_50_50_54_54_48_2b_54_41; //换行、回车、{AT+HTTPPARA="URL","http://api.map.baidu.com/directionlite/v1/walking?origin=34.160585,108.907325&destination=34.1578,108.905183&ak=fQfrhmplBKN1dEP9VPyY9mrRQrIuNzTO"}的倒序,166
			
				HTTPACTION	<= 136'h0a_0d_30_3d_4e_4f_49_54_43_41_50_54_54_48_2b_54_41;//换行、回车、{AT+HTTPACTION=0}的倒序,17个字符
	
				HTTPREAD	<= 168'h0a_0d_37_33_30_30_34_2c_31_3d_44_41_45_52_50_54_54_48_2b_54_41;//换行、回车、{AT+HTTPREAD=1,40037}的倒序,21个字符
				
				HTTPTERM	<= 104'h0a_0d_4d_52_45_54_50_54_54_48_2b_54_41;//换行、回车、{AT+HTTPTERM}的倒序,13个字符
				
				SAPBR01		<= 112'h0a_0d_31_2c_30_3d_52_42_50_41_53_2b_54_41;//换行、回车、{AT+SAPBR=0,1}的倒序,14个字符				
				
			end
		end
	end
	
	always@(posedge clk or negedge rst)
	begin
		if(!rst)
			message_sent_done_flag <= 0;
		else if(40913 <= cnt_T5s && cnt_T5s <= 40914)
			message_sent_done_flag <= 0;
		else if(40911 <= cnt_T5s && cnt_T5s <= 40912)		//注意和223之后还有一小段时间间隔
			message_sent_done_flag <= 1;
		else
			message_sent_done_flag <= message_sent_done_flag;
	end
endmodule
