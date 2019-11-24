module top_uart_rx_gy_26(
	input 			clk,
	input 			rst,
	input 			data_rx,
	
	output [9:0]	jiaodu,
	output 			over_rx 
    );
	
	wire [7:0]data_tx;
	
	bps_set_gy_26 a (
    .clk(clk), 
    .rst(rst), 
    .bps_start(bps_start), 
    .bps_clk(bps_clk)
    );
    uart_rx_gy_26 ab (
	.nedge(nedge),
    .clk(clk), 
    .rst(rst), 
    .bps_clk(bps_clk), 
    .data_rx(data_rx), 
    .data_tx(data_tx), 
    .over_rx(over_rx), 
    .bps_start(bps_start)
    );
	uart_rx_dzj_gy_26 abc (
    .clk(clk), 
    .rst(rst), 
    .data_tx(data_tx),
	.over_rx(over_rx),
    .nedge(nedge), 
    .jiaodu(jiaodu)
    );


endmodule
