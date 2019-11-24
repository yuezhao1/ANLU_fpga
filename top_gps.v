module top_gps(
	input 			clk,
	input 			rst_n,
	input 			data_rx,
	
	output [383:0]	data_rx_end
    );
	wire [7:0]data_tx;
gps_rx a (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_rx(data_tx), 
    .rx_int(rx_int), 
	
    .data_rx_end(data_rx_end), 
    .ymr_out(ymr_out), 
    .time_out(time_out)
    );

uart_bps_9600 u_uart_bps_9600 (
    .clk(clk), 
    .rst_n(rst_n), 
    .cnt_start(bps_start),
	
    .bps_sig(clk_bps)
    );

uart_receive_9600 u_uart_receive_9600 (
    .clk(clk), 
    .rst_n(rst_n), 
    .clk_bps(clk_bps), 
    .data_rx(data_rx), 
	
    .rx_int(rx_int), 
    .data_tx(data_tx), 
    .bps_start(bps_start)
    );

endmodule
