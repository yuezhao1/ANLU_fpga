module gps_yuyin(
	input key,
	input clk,
	input rst_n,
	output reg [17:0]shijian
    );
	always@(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			shijian<=1'b0;
		else if(key)
			shijian<=18'd102444;
	end 

endmodule