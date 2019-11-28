`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:40:43 11/24/2018 
// Design Name: 
// Module Name:    Top_uart_tx 
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
module Top_uart_tx(
	input clk,
	input send_en,
	input rst_n,
	input[7:0]data_rx,
	
	output  RX232,
	output  over_rx    //结束后会有一个高电平
    );
	bps_set a (
    .clk(clk), 
    .rst_n(rst_n), 
    .bps_start(bps_start), 
    .bps_clk(bps_clk)
    );
	uart_tx ab (
    .clk(clk), 
    .bps_clk(bps_clk), 
    .send_en(send_en), 
    .rst_n(rst_n), 
    .data_rx(data_rx), 
    .RX232(RX232), 
    .over_rx(over_rx), 
    .bps_start(bps_start)
    );




endmodule
