module top_zhiwen(
	input clk,
	input rst_n,
	input chumo,
	input data_rx,
	
	output RX232,
	output [1:0]flag
	
    );
Top_uart_tx_zhiwen a (
    .flag(tx_en), 
    .clk(clk), 
    .rst_n(rst_n), 
    .RX232(RX232), 
    .over_rx(over_rx), 
    .over_all(over_all)
    );
zhiwen ab (
	.zhongzhi(zhongzhi),
    .chumo(chumo), 
	.over_all(over_all),
    .tx_en(tx_en)
    );
top_uart_rx abc (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_rx(data_rx),
    .flag(flag)
    );
assign zhongzhi = flag[0];



endmodule
