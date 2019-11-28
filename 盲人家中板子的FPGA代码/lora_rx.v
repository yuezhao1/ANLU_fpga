`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:28:55 10/05/2019 
// Design Name: 
// Module Name:    uart_rx_talk 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lora_rx(
	input clk,
	input rst_n,
	input data_rx,
	input over_all,
	
	output  [6:0] smg_duan,
	output  [3:0] smg_wei,
	output  dp
	
    );
wire [7:0]data_tx;
bps_set_115200 a (
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
	/*uart_rx_dzj_lora abc (
    .clk(clk),
	.over_all(over_all),	
    .rst_n(rst_n), 
    .data_tx(data_tx), 
    .nedge(nedge), 
	.over_rx(over_rx),
    .flag_lora(flag_lora)
    );*/
	wire [15:0] x;
	lora_rx_chuli abcd (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_tx(data_tx), 
    .x(x)
    );
	x7seg_msg abcde (
    .x(x), 
    .clk(clk), 
    .clr(!rst_n), 
    .smg_duan(smg_duan), 
    .smg_wei(smg_wei), 
    .dp(dp)
    );


endmodule
