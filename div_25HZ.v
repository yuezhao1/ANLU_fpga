`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:34:21 11/02/2019 
// Design Name: 
// Module Name:    div_25HZ 
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
module div_25HZ(
	input				clk,
	input				rst_n,
				
	output	reg			VGA_clk
    );
	
//2分频	
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
	VGA_clk <= 1'b0;
	else
	VGA_clk	<=	~VGA_clk;
	end
endmodule
