module top_hongwai(
	input 				clk,
	input 				rst_n,
	input 				data_rx,

	output 	[1:0]		flag_tu_ao
    );
	
	wire 	[7:0]		data_tx;
	wire				rx_int;
	
hongwai_rx u_hongwai_rx (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_rx(data_tx), 
    .rx_int(rx_int), 
	.flag_tu_ao(flag_tu_ao)
    );

uart_bps_9600 u_uart_bps_9600 (
    .clk(clk), 
    .rst_n(rst_n), 
    .cnt_start(bps_start),
    .bps_sig(clk_bps)
    );

uart_receive u_uart_receive (
    .clk(clk), 
    .rst_n(rst_n), 
    .clk_bps(clk_bps), 
    .data_rx(data_rx), 
	
    .rx_int(rx_int), 
    .data_tx(data_tx), 
    .bps_start(bps_start)
    );


endmodule
