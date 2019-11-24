`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:45:40 11/02/2019
// Design Name:   top
// Module Name:   C:/Users/13743/Desktop/DongNan/VGA_200_164/tb_top.v
// Project Name:  VGA_200_164
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_top;

	// Inputs
	reg clk;
	reg rst_n;
	reg pic_en;

	// Outputs
	wire VGA_HS;
	wire VGA_VS;
	wire [1:0] Red_Green;
	wire [7:0] RGB;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.pic_en(pic_en), 
		.VGA_HS(VGA_HS), 
		.VGA_VS(VGA_VS), 
		.Red_Green(Red_Green), 
		.RGB(RGB)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst_n = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst_n = 1'b1;		
        pic_en = 1'b1;
		// Add stimulus here

	end

	always  #10 clk = ~clk;      



	
endmodule

