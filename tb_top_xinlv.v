`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:44:46 11/16/2019
// Design Name:   top_xinlv
// Module Name:   C:/Users/13743/Desktop/DongNan/xinlv/xinlv/tb_top_xinlv.v
// Project Name:  xinlv
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_xinlv
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_top_xinlv;

	// Inputs
	reg clk;
	reg rst_n;
	reg data_rx;

	// Outputs
	wire [7:0] xinlv;

	// Instantiate the Unit Under Test (UUT)
	top_xinlv uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.data_rx(data_rx), 
		.xinlv(xinlv)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst_n = 0;
		data_rx = 0;

		// Wait 100 ns for global reset to finish
		#20;
		rst_n=1'b1;
		data_rx=1'b1;
		#104160;           //5208*20=104160 ns
		rst_n=1'b1;
		data_rx=1'b0;
		
		
		// Add stimulus here

		#104160;		//B 42
		data_rx=1'b0;
		#104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//P 50
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;   
        #104160;
        data_rx=1'b0;
        
        #104160;		//M 4d
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//6 36
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//9 39
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
		data_rx=1'b0;
		#104160;
		data_rx=1'b1;
		#104160;
		data_rx=1'b1;
		#104160;
 		data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
		#104160;		//B 42
		data_rx=1'b0;
		#104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//P 50
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;   
        #104160;
        data_rx=1'b0;
        
        #104160;		//M 4d
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//5 35
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//8 38
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1; 
        #104160;
        data_rx=1'b0;
        
		#104160;		//B 42
		data_rx=1'b0;
		#104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//P 50
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;   
        #104160;
        data_rx=1'b0;
        
        #104160;		//M 4d
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
		
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//8 38
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//7 37
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;


        #104160;
        data_rx=1'b1; 
        #104160;
        data_rx=1'b0;
        
		#104160;		//B 42
		data_rx=1'b0;
		#104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;		//P 50
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        
        #104160;
        data_rx=1'b1;   
        #104160;
        data_rx=1'b0;
        
        #104160;		//M 4d
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b0;
        #104160;
        data_rx=1'b1;
        #104160;
        data_rx=1'b0;
		
        #104160;
        data_rx=1'b1;		
		
end 


always #10 clk = ~clk;		
				
endmodule		
		
		
		
		