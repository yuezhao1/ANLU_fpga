module bps_set_57600(
	input clk,
	input rst_n,
	input bps_start,
	output bps_clk
    );
	reg[12:0]cnt_bps;
	parameter bps=13'd868;  //(50_000_000/57600)
	always@(posedge clk or negedge rst_n)
	    begin
	    if(!rst_n)                 cnt_bps<= 13'd0;
	    else if(cnt_bps==bps-1'b1) cnt_bps<= 13'd0;
	    else if(bps_start)         cnt_bps<= cnt_bps+1'b1;
	    else                       cnt_bps<= 1'b0;
	    end
	assign bps_clk=(cnt_bps==13'd434)?1'b1:1'b0;               //868/2=434
endmodule
