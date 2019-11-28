`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:00:08 11/24/2018
// Design Name:   Top_uart_tx
// Module Name:   F:/Xilinx/uart/uart_tx/Top_uart_tx_test.v
// Project Name:  uart_tx
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Top_uart_tx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Top_uart_tx_test;

	// Inputs
	reg clk;
	reg send_en;
	reg rst_n;
	reg [7:0] data_rx;

	// Outputs
	wire RX232;
	wire over_rx;

	// Instantiate the Unit Under Test (UUT)
	Top_uart_tx uut (
		.clk(clk), 
		.send_en(send_en), 
		.rst_n(rst_n), 
		.data_rx(data_rx), 
		.RX232(RX232), 
		.over_rx(over_rx)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		send_en = 0;
		rst_n = 0;
		data_rx = 0;

		// Wait 100 ns for global reset to finish
		#10;
		send_en=1'b1;
		rst_n=1'b1;
		data_rx=8'b01001001;
        
		// Add stimulus here

	end
    always #10 clk=~clk;  
endmodule

