`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:28:52 11/20/2019
// Design Name:   lora_rx
// Module Name:   F:/Xilinx/lora_home_new/lora_rx_test.v
// Project Name:  uart_tx
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: lora_rx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module lora_rx_test;

	// Inputs
	reg clk;
	reg rst_n;
	reg data_rx;
	reg over_all;

	// Outputs
	wire [6:0] smg_duan;
	wire [3:0] smg_wei;
	wire dp;

	// Instantiate the Unit Under Test (UUT)
	lora_rx uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.data_rx(data_rx), 
		.over_all(over_all), 
		.smg_duan(smg_duan), 
		.smg_wei(smg_wei), 
		.dp(dp)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst_n = 0;
		data_rx = 0;
		over_all = 0;

		// Wait 100 ns for global reset to finish
		#20;
		rst_n=1'b1;
		data_rx=1'b1;
		#8680;           //434*20=8680
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;//31
		#8680;           //434*20=8680
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;//31
		#8680;           //434*20=8680
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;//79
		#8680;           //434*20=8680
		data_rx=1'b0;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;
		#8680;
		data_rx=1'b0;
		#8680;
		data_rx=1'b1;//68
		// Add stimulus here

	end
always #10 clk=~clk;      
endmodule

