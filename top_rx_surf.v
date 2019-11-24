module top_rx_surf(
	input 			clk,
	input 			rst_n,
	input 			data_rx,
		
	output			flag_en_1,//存使能
	output [7:0]	addr_daohang_data,
	output [92:0]	data_rx_end_internet
    );
	
	
	wire 	[7:0]	data_tx;
	
	
surf_internet_rx u_surf_internet_rx (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_rx(data_tx), 
    .rx_int(rx_int), 
	.flag_en_1(flag_en_1),
	.addr_daohang_data(addr_daohang_data),
    .data_rx_end_internet(data_rx_end_internet)
    );

uart_bps_1 u_uart_bps_1 (
    .clk(clk), 
    .rst_n(rst_n), 
    .cnt_start(bps_start),
    .bps_sig(clk_bps)
    );

uart_receive_1 u_uart_receive_1 (
    .clk(clk), 
    .rst_n(rst_n), 
    .clk_bps(clk_bps), 
    .data_rx(data_rx), 
	
    .rx_int(rx_int), 
    .data_tx(data_tx), 
    .bps_start(bps_start)
    );

endmodule
