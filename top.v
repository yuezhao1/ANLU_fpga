`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:34:38 11/02/2019 
// Design Name: 
// Module Name:    top 
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
module top(
	input							clk,
	input							rst_n,
	input							pic_en,

	output							VGA_HS,
	output							VGA_VS,
	output			[1:0]			Red_Green,
	output			[7:0]			RGB

    );
	
	wire							VGA_clk;
	wire							disp_valid;//判断是否在有效的显示区域
	wire			[7:0]			M;	
	wire			[7:0]			M_pic;
	wire			[15:0]			rom_addr16;
	wire			[15:0]			rom_addr13;
	wire							flag_addr;
	wire			[15:0]			flag_square_begin;
	wire			[15:0]			flag_square_end;
	wire			[6:0]			cnt_x;
	wire			[6:0]           cnt_y;
	wire			[7:0]			a;
	wire			[15:0]			rom_addr;
	
	
	
div_25HZ U_div_25HZ (
    .clk(clk), 
    .rst_n(rst_n), 
    .VGA_clk(VGA_clk)
    );

	
VGA U_VGA (
    .clk(clk), 
    .rst_n(rst_n),  
    .M(a), 
	.cnt_x(cnt_x),
	.cnt_y(cnt_y),
	.pic_en(pic_en),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
    .flag_addr(flag_addr), 
    .flag_square_begin(flag_square_begin), 
    .flag_square_end(flag_square_end), 
    .rom_addr16(rom_addr16), 
    .RGB(RGB)
    );	
	

VGA_pic_double U_VGA_pic_double (
  .clka(VGA_clk), // input clka
  .addra(rom_addr), // input [12 : 0] addra
  .douta(a) // output [7 : 0] douta
);


VGA_square U_VGA_square (
    .clk(VGA_clk), 
    .rst_n(rst_n), 
    .M_pic(a),
	.cnt_x(cnt_x),
	.cnt_y(cnt_y),
    .flag_addr(flag_addr), 
    .rom_addr13(rom_addr13), 
    .flag_square_begin(flag_square_begin), 
    .flag_square_end(flag_square_end)
    );
	
	
judge_Red_Green U_judge_Red_Green (
    .clk(clk), 
    .rst_n(rst_n), 
    .RGB(RGB), 
    .Red_Green(Red_Green)
    );
	
	
select_addr U_select_addr (								
	.clk(clk),
    .rst_n(rst_n), 	
    .flag_square_begin(flag_square_begin), 
	.rom_addr13(rom_addr13), //VGA_square	
	.rom_addr16(rom_addr16), //VGA_bsprite
	.rom_addr(rom_addr)
	);

	
endmodule
