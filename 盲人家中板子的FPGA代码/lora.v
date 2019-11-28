`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:18:20 11/21/2019 
// Design Name: 
// Module Name:    lora 
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
module lora(
	input [3:0]in_key_en,
	input clk,
	input rst_n,
	input co,
	input zhendong,
	input data_rx,
	
	output  [6:0] smg_duan,
	output  [3:0] smg_wei,
	output  dp,
	output RX232,
	output fengshan
    );
Top_uart_tx_dzj tx (
    .in_key_en(in_key_en), 
    .clk(clk), 
    .rst_n(rst_n), 
    .co(co), 
    .zhendong(zhendong), 
    .RX232(RX232), 
    .over_rx(), 
    .fengshan(fengshan)
    );
lora_rx rx (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_rx(data_rx), 
    .smg_duan(smg_duan), 
    .smg_wei(smg_wei), 
    .dp(dp)
    );
endmodule
