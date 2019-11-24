module top_lora_tx(
	input 				clk,
	input 				rst_n,
	input				send_en,
	input	[7:0]		data_rx,
	
	output              RX232,
	output              over_rx
	);

	wire				bps_start_1;	
	
	bps_set_lora u_bps_set_lora(
		.clk(clk),
		.rst_n(rst_n),
		.bps_start(bps_start_1),
		.bps_clk(bps_clk)
		);
		
	uart_tx_lora u_uart_tx_lora(	
		.clk(clk),
		.bps_clk(bps_clk),
		.send_en(send_en),
		.rst_n(rst_n),
		.data_rx(data_rx),
		.RX232(RX232),
		.over_rx(over_rx),
		.bps_start(bps_start_1)
		);
	
	
endmodule
