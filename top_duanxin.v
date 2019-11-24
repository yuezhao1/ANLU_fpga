module top_duanxin(
	input			 	clk,
	input			 	rst_n,
	input				mess_phone_number_prepared_enable,//短信发送使能，连接按键
	input 				data_rx,//gps的接收
	
	output 				gsm_tx
	
    );

	wire 				emergency_contact_1 = 1;//紧急联系人1
	wire 				emergency_contact_2 = 0;//紧急联系人2
	wire 				emergency_contact_3 = 0;//紧急联系人3	
	wire 				bps_sig;
	wire 				cnt_start;
	wire 				rx_int;
	wire 	[7:0] 		data1;
//	wire 	[383:0] 	data_rx_end;
	wire 	[47:0] 		ymr_out;
	wire 	[47:0] 		time_out;
	
	
	reg  [87:0] calling_number_end;
	reg  [2:0] 	out_message_or_calling_en_or_receive;//选择输出，011是发短信功能，10是打电话功能，11是接电话功能	
	
	always@(posedge clk )begin
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
	 wire [183:0]	data_rx_end_jingduweidu;

	
	uart_receive u1_uart_receive (
    .clk(clk), 
    .rst_n(rst_n), 
    .clk_bps(bps_sig), 
    .data_rx(data_rx),
    .rx_int(rx_int), 
    .data_tx(data1), 
    .bps_start(cnt_start)
    );
	
	uart_bps u11_uart_bps (
    .clk(clk), 
    .rst_n(rst_n), 
    .cnt_start(cnt_start), 
    .bps_sig(bps_sig)
    );
	
	pick_up_rx u2_pick_up_rx (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_rx(data1), 
    .rx_int(rx_int), 
    .data_rx_end(data_rx_end),
	.time_out(time_out),
	.ymr_out(ymr_out)
    );
	
	uart_bps mess_u1_uart_bps (
    .clk(clk), 
    .rst_n(rst_n), 
    .cnt_start(cnt_start_ring), 
    .bps_sig(bps_sig_ring)
    );
	
	//短信的发送
	gsm mess_u4_gsm (
    .tx_enable(tx_enable1), 
    .tx_data(tx_data1), 
    .clk(clk), 
    .rst(rst_n), 
    .tx_done(tx_done), 
    .mess_phone_number_prepared_enable(mess_phone_number_prepared_enable), //短信发送使能
	.TEXT_buf(data_rx_end_jingduweidu)
    );
	
	always@(posedge clk ) begin
		if(mess_phone_number_prepared_enable)
			out_message_or_calling_en_or_receive <= 3'b011;
		else 
			out_message_or_calling_en_or_receive <= out_message_or_calling_en_or_receive;
		end	
			
	

	always@(posedge clk ) 
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
    .clk(clk), 
    .rst_n(rst_n), 
    .bps_sig(bps_sig_tx), 
    .cnt_start(tx_enable)
    );
	
	uart_sentdata_mess u3_uart_sentdata_mess (
    .clk(clk), 
    .rst(rst_n), 
    .bps_sig(bps_sig_tx), 
    .tx_data(tx_data), 
    .tx(gsm_tx), 
    .tx_enable(tx_enable), 
    .tx_done(tx_done)
    );
	
	
	top_gps u_top_gps(
	.clk(clk),
	.rst_n(rst_n),
	.data_rx(data_rx),//gps的接收端
	.data_rx_end(data_rx_end_jingduweidu)
    );
	
endmodule
