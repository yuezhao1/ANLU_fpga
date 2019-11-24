module TOP_GY_25(
	input clk_24m,
	input rst_n,
	input rs232_rx,
	
	output RX232,
	output [1:0]led
    );
wire [7:0]bps_cnt;
wire [7:0]data_byte;
wire [7:0]angle;

wire		clk_72m;
wire		clk_50m;


PLL_50M_GY_25 u_PLL_50M_GY_25(
		.refclk(clk_24m),
		.clk0_out(clk_72m),
		.clk1_out(clk_50m)
	);



GY25_RX a (
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .rs232_rx(rs232_rx), 
    .data_byte(data_byte), 
    .rx_done(rx_done), 
    .bps_cnt(bps_cnt)
    );

data_extract ab (
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .date_byte(data_byte), 
    .angle(angle), 
    .rx_done(rx_done), 
    .bps_cnt(bps_cnt), 
    .byte1(byte1)
    );



Top_gy_25_tx abc (
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .RX232(RX232), 
    .over_rx(over_rx), 
    .over_all(over_all)
    );

chuli abcd (
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .angle(angle), 
    .led(led)
    );



endmodule
