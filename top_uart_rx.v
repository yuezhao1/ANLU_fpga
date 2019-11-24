module top_uart_rx(
	input clk,
	input rst_n,
	input data_rx,
	//input over_all,
	output [1:0]flag,
	output over_rx 
    );
	wire [7:0]data_tx;
	bps_set_57600 a (
    .clk(clk), 
    .rst_n(rst_n), 
    .bps_start(bps_start), 
    .bps_clk(bps_clk)
    );
    uart_rx ab (
	.nedge(nedge),
    .clk(clk), 
    .rst_n(rst_n), 
    .bps_clk(bps_clk), 
    .data_rx(data_rx), 
    .data_tx(data_tx), 
    .over_rx(over_rx), 
    .bps_start(bps_start)
    );
	uart_rx_dzj_zhiwen abc (
    .clk(clk), 
	//.over_all(over_all),
    .rst_n(rst_n), 
    .data_tx(data_tx), 
    .nedge(nedge), 
	.over_rx(over_rx),
    .flag(flag)
    );
endmodule
