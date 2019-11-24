module top_gy_26(
	input flag_gy26,
	input clk,
	input rst,
	input data_rx, 
	output RX232,
	output [9:0]jiaodu
    );
Top_uart_tx_gy_26 a (
    .flag_gy26(flag_gy26), 
    .clk(clk), 
    .rst(rst), 
    .RX232(RX232),
    .over_all(over_all),
    .over_rx(over_rx)
    );
top_uart_rx_gy_26 b (
    .clk(clk), 
    .rst(rst), 
    .data_rx(data_rx), 
    .jiaodu(jiaodu)
    );

endmodule
