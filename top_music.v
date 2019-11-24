module top_music(
	//input key,
	input clk,
	input rst_n,
	input music_rx,
	input [17:0]shijian,
	input [1:0]flag_zhiwen,
	input [1:0]flag_GY25,
	input flag_music,//语音输入放歌
	input [1:0]flag_tu_ao,
	
	//input talk_rx,
	input flag_shijian,
	output RX232,
	output led,
	output over_all,
	output sj_en
    );
	//wire [17:0]shijian;
	wire [3:0]shi_1,shi_2,fen_1,fen_2;
Top_uart_tx_dzj_music a (
    .shi_1(shi_1), 
    .shi_2(shi_2), 
    .fen_1(fen_1), 
    .fen_2(fen_2),
	.flag_zhiwen(flag_zhiwen),
	.flag_music(flag_music),
	.flag_tu_ao(flag_tu_ao),
	.flag_GY25(flag_GY25),
	.sj_en(sj_en),
    .clk(clk), 
    .rst_n(rst_n), 
    .tx_en(tx_en), 
    .shijian_en(flag_shijian), 
    .RX232(RX232),
    .over_all(over_all)	
    );
uart_rx_dzj_music ab (
    .clk(clk), 
	//.over_all(over_all),
    .rst_n(rst_n), 
    .data_rx(music_rx), 
    .flag(tx_en),
	.led(led)
    );
	/*uart_rx_talk abc (
    .clk(clk), 
	.over_all(over_all),
    .rst_n(rst_n), 
    .data_rx(talk_rx), 
    .flag(shijian_en)
    );*/
 /*gps abcd (
    .key(key), 
    .clk(clk), 
    .rst_n(rst_n), 
    .shijian(shijian)
    );*/
	time_ abcde (
    .shijian(shijian), 
    .clk(clk), 
    .rst_n(rst_n), 
    .shijian_en(flag_shijian), 
    .shi_1(shi_1), 
    .shi_2(shi_2), 
    .fen_1(fen_1), 
    .fen_2(fen_2), 
    .sj_en(sj_en)
    );
	
endmodule
