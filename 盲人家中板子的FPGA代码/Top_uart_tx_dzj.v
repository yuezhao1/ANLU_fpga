`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:45:17 11/25/2018 
// Design Name: 
// Module Name:    Top_uart_tx_dzj 
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
module Top_uart_tx_dzj(
	input [3:0]in_key_en,
	input clk,
	input rst_n,
	input co,
	input zhendong,
	
	output RX232,
	output over_rx,
	output fengshan
    );
	wire [7:0]data_rx;
	wire [3:0]out_key_en;
	uart_tx_dzj a (
	.co(co),
	.zhendong(zhendong),
    .in_key_en(out_key_en), 
    .clk(clk), 
    .rst_n(rst_n), 
    .over_tx(over_rx), 
    .data_rx(data_rx), 
    .send_en(send_en),
	.fengshan(fengshan)
    );
	fangdou ab (
    .in_key_en(in_key_en), 
    .rst_n(rst_n), 
    .clk(clk), 
    .out_key_en(out_key_en)
    );
	uart_tx abc (
    .clk(clk), 
    .bps_clk(bps_clk), 
    .send_en(send_en), 
    .rst_n(rst_n), 
    .data_rx(data_rx), 
    .RX232(RX232), 
    .over_rx(over_rx), 
    .bps_start(bps_start)
    );
	bps_set abcd (
    .clk(clk), 
    .rst_n(rst_n), 
    .bps_start(bps_start), 
    .bps_clk(bps_clk)
    );


endmodule
