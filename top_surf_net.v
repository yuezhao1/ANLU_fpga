module top_surf_net(
	input			 			clk_24m,
	input			 			rst_n,
	input						mess_phone_number_prepared_enable,//发送使能，连接按键
	input 						data_rx,
								
	output 						gsm_tx,//输出给sim900a信号
								
								
	input						du_en,
	input 						a,
    input 						b,//1
	input 						flag,
	input						data_rx_jiaodu,						
								
	output		[6:0] 			smg_duan,
	output		[3:0] 			smg_wei,
	output		 				dp,
	output						RX232,
	output		[1:0]			dianji,
	output		[8:0]			baidu_JD
	
	
	
	
	
    );

	wire 				emergency_contact_1 = 1;//紧急联系人1
	wire 				emergency_contact_2 = 0;
	wire 				emergency_contact_3 = 0;	
	wire 				bps_sig;
	wire 				cnt_start;
	wire 				rx_int;
	wire 	[7:0] 		data1;
	wire 	[47:0] 		ymr_out;
	wire 	[47:0] 		time_out;
	wire				clk_25m;
	wire				clk_50m;
	wire				clk_72m;



	
	reg  [87:0] calling_number_end;
	reg  [2:0] 	out_message_or_calling_en_or_receive;//选择输出，011是发短信功能，10是打电话功能，11是接电话功能	
	
	always@(posedge clk_50m )begin
		case ({0,emergency_contact_1,emergency_contact_2,emergency_contact_3})
			4'b1000:calling_number_end<= 88'h0;
			4'b0100:calling_number_end<= 88'h34_38_32_31_37_36_32_38_33_37_31;//程宁勃
			4'b0010:calling_number_end<= 88'h30_36_34_38_34_33_31_39_36_37_31;//刘仰猛;
			4'b0001:calling_number_end<= 88'h37_39_38_38_37_38_37_38_32_33_31;//张胜亭;
			default:calling_number_end<=calling_number_end;
		endcase
		end
		
	 reg  			tx_enable;
	 reg  [7:0]		tx_data;		
	 wire 			bps_sig_tx;
	 wire 			tx_done;
	 wire 			tx_enable1;
	 wire			tx_enable2;
	 wire			tx_enable3;
	 wire			tx_enable4;	 
	 wire [7:0]		tx_data1;
	 wire 			bps_sig_ring;
	 wire 			cnt_start_ring;
	

	
	
	PLL_50M u_PLL_50M (
	.refclk(clk_24m),
	.clk0_out(clk_72m),
	.clk1_out(clk_50m),
	.clk2_out(clk_25m)
);
	
	uart_receive u1_uart_receive (
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .clk_bps(bps_sig), 
    .data_rx(data_rx),
    .rx_int(rx_int), 
    .data_tx(data1), 
    .bps_start(cnt_start)
    );
	
	uart_bps u11_uart_bps (
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .cnt_start(cnt_start), 
    .bps_sig(bps_sig)
    );
	
	pick_up_rx u2_pick_up_rx (
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .data_rx(data1), 
    .rx_int(rx_int), 
    .data_rx_end(data_rx_end),
	.time_out(time_out),
	.ymr_out(ymr_out)
    );
	
	uart_bps mess_u1_uart_bps (
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .cnt_start(cnt_start_ring), 
    .bps_sig(bps_sig_ring)
    );
	
	//访问网址
	surf_internet mess_u4_surf_internet (
    .tx_enable(tx_enable1), 
    .tx_data(tx_data1), 
    .clk(clk_50m), 
    .rst(rst_n), 
    .tx_done(tx_done), 
    .mess_phone_number_prepared_enable(mess_phone_number_prepared_enable) //上网发送使能
    );
	
	always@(posedge clk_50m ) begin
		if(mess_phone_number_prepared_enable)
			out_message_or_calling_en_or_receive <= 3'b011;
		else 
			out_message_or_calling_en_or_receive <= out_message_or_calling_en_or_receive;
		end	
			
	

	always@(posedge clk_50m ) 
		begin
			case(out_message_or_calling_en_or_receive)
				3'b011:	begin 
						tx_data <= tx_data1;
						tx_enable <= tx_enable1;
						end
				default:;
			endcase
		end		
	
	uart_bps_mess u2_uart_bps_mess (
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .bps_sig(bps_sig_tx), 
    .cnt_start(tx_enable)
    );
	
	uart_sentdata_mess u3_uart_sentdata_mess (
    .clk(clk_50m), 
    .rst(rst_n), 
    .bps_sig(bps_sig_tx), 
    .tx_data(tx_data), 
    .tx(gsm_tx), 
    .tx_enable(tx_enable), 
    .tx_done(tx_done)
    );
	
	wire	[92:0]		data_rx_end_internet;
	wire				flag_en_1;
	wire	[2:0]		addr_daohang_data;
	
	
	//read internet data	
	top_rx_surf u_top_rx_surf (
	.clk(clk_50m),
	.rst_n(rst_n),
	.data_rx(data_rx),
	.flag_en_1(flag_en_1),//ram写使能
	.addr_daohang_data(addr_daohang_data),//ram写地址
	.data_rx_end_internet(data_rx_end_internet)//ram写数据
    );
	
	
wire	[2:0]		addr_daohang;
wire	[92:0]		dout_daohang;
	
	reg		[3:0]	cnt_flag_en_1;
	
	always @(posedge clk_50m or negedge rst_n)
		begin
			if(!rst_n)
				cnt_flag_en_1 <= 1'b0;
			else if(cnt_flag_en_1 >= 7)
				cnt_flag_en_1 <= cnt_flag_en_1;
			else if(flag_en_1)
				cnt_flag_en_1 <= cnt_flag_en_1 + 1'b1;
			else
				cnt_flag_en_1 <= cnt_flag_en_1;
		end

	reg		[26:0]	cnt_3s;
	
	always @(posedge clk_24m or negedge rst_n)		
		begin
			if(!rst_n)
				cnt_3s <= 27'b0;
			else if(cnt_3s == 27'd7200_0000 - 1)
				cnt_3s <= cnt_3s;
			else if(cnt_flag_en_1 == 7)
				cnt_3s <= cnt_3s + 1;
			else
				cnt_3s <= 27'b0;
		end
	
	assign   read_en =  (cnt_3s == 27'd7200_0000 - 1)?1:0;

	
	
	//导航RAM	
	ram_daohang_data u_ram_daohang_data (
	//write
	.clka(clk_50m),
	.cea(flag_en_1),
	.addra(addr_daohang_data),
	.dia(data_rx_end_internet),
	//read
	.clkb(clk_50m),
	.rstb(!rst_n),
	.addrb(addr_daohang),
	.dob(dout_daohang)
    );


	
	
	top2 u_daohang(
	.clk_24m(clk_24m),
	.rst(rst_n),
	.du_en(du_en),
	.a(a),
    .b(b),//1
	.flag(flag),
	.data_rx_jiaodu(data_rx_jiaodu),
	.smg_duan(smg_duan),
	.smg_wei(smg_wei),
	.dp(dp),
	.RX232(RX232),
	.dianji(dianji),
	.baidu_JD(baidu_JD),
	.addra(addr_daohang),
	.douta(dout_daohang)
	);
	
	
	
	
	
endmodule
