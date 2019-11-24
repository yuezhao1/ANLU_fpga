`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:35:57 11/02/2019 
// Design Name: 
// Module Name:    select_addr 
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
module select_addr(						
	input							clk,				
	input							rst_n,
	input		[15:0]				flag_square_begin,
	input		[15:0]				rom_addr13,//VGA_square	
	input		[15:0]				rom_addr16,//VGA_bsprite
								
	output		[15:0]				rom_addr	//选择后的地址							
	
    );
	
	
assign 	rom_addr = (flag_square_begin > 3*200)? rom_addr16 : rom_addr13;
	
	
	
	//3行像素数量
//always @ (posedge clk or negedge rst_n)begin
//	if(!rst_n)
//	rom_addr <= 13'd0;
//	else if(flag_square_begin >  3*200)
//	rom_addr <= rom_addr16;
//	else
//	rom_addr <= rom_addr13;
//	end
	


endmodule

