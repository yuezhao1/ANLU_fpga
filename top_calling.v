module top_calling(
	input			 	clk,
	input			 	rst_n,
	input				calling_sent_en_cheng,	//打电话使能，连接按键
	input				calling_sent_en_zhi,	//第二个紧急联系人
	
	output 				calling_tx
	
    );

	wire 				bps_sig;
	wire 				cnt_start;
	wire 				rx_int;
	wire 	[7:0] 		data1;
	wire 	[47:0] 		ymr_out;
	wire 	[47:0] 		time_out;
	wire				calling_sent_en_1;
	
	assign calling_sent_en_1 = ~calling_sent_en_cheng;
	assign calling_sent_en_2 = ~calling_sent_en_zhi;

		
	 reg  			tx_enable;
	 reg  [7:0]		tx_data;		
	 wire 			bps_sig_tx;
	 wire 			tx_done;
	 wire [7:0]		tx_data2 ;	 
	 wire 			tx_enable1;
	 wire			tx_enable2;
	 wire			tx_enable3;
	 wire			tx_enable4;	 
	 wire [7:0]		tx_data1;
	 wire 			bps_sig_ring;
	 wire 			cnt_start_ring;
	
	
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
	
	//打电话
	calling mess_u5_calling (
    .tx_enable(tx_enable2), 
    .tx_data(tx_data2), 
    .clk(clk), 
    .rst(rst_n), 
    .tx_done(tx_done), 
    .calling_sent_enable_1(calling_sent_en_1),
    .calling_sent_enable_2(calling_sent_en_2)
    );
	
	
	uart_bps_mess u2_uart_bps_mess (
    .clk(clk), 
    .rst_n(rst_n), 
    .bps_sig(bps_sig_tx), 
    .cnt_start(tx_enable2)
    );
	
	uart_sentdata_mess u3_uart_sentdata_mess (
    .clk(clk), 
    .rst(rst_n), 
    .bps_sig(bps_sig_tx), 
    .tx_data(tx_data2), 
    .tx(calling_tx), 
    .tx_enable(tx_enable2), 
    .tx_done(tx_done)
    );
	
endmodule

