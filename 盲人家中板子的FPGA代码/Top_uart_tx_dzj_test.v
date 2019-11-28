`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:08:43 11/25/2018
// Design Name:   Top_uart_tx_dzj
// Module Name:   F:/Xilinx/uart/uart_tx/Top_uart_tx_dzj_test.v
// Project Name:  uart_tx
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Top_uart_tx_dzj
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Top_uart_tx_dzj_test;

	// Inputs
	reg [3:0] in_key_en;
	reg clk;
	reg rst_n;

	// Outputs
	wire RX232;
	wire over_rx;

	// Instantiate the Unit Under Test (UUT)
	Top_uart_tx_dzj uut (
		.in_key_en(in_key_en), 
		.clk(clk), 
		.rst_n(rst_n), 
		.RX232(RX232), 
		.over_rx(over_rx)
	);

	initial begin
		// Initialize Inputs
		in_key_en = 0;
		clk = 0;
		rst_n = 0;

		// Wait 100 ns for global reset to finish
		#10;
		rst_n=1'b1;
		in_key_en=4'b0100;
		#1000000;
		in_key_en=4'b0;
		// Add stimulus here

	end
    always #10 clk=~clk;  
endmodule

