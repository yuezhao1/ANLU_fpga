module chuli(
	input clk,
	input rst_n,
	input [7:0]angle,
	
	output reg [1:0]led
    );
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			led<=2'b00;
		else if(angle>=6'd45)      //大于45度盲人将要摔倒
			led<=2'b01;
		else led<=2'b10;
	end 


endmodule