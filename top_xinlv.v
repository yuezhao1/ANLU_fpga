module top_xinlv(
	input 				clk,
	input 				rst_n,
	input 				data_rx,

	output reg	[7:0]		xinlv
    );
	
	wire 	[7:0]		data_tx;
	wire				rx_int;
	wire	[7:0]		xinlv_1;
	
	reg		[25:0]		cnt;
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			cnt <= 26'd0;
		else if(cnt == 26'd5000_0000 - 1)
			cnt <= 26'd0;
		else
			cnt <= cnt + 1;
		end

	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			xinlv <= 8'b0;
		else if(cnt == 26'd5000_0000 - 1)
			xinlv <= xinlv_1;
		else
			xinlv <= xinlv;
		end
	
	
xinlv_rx xinlv_rx (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_rx(data_tx), 
    .rx_int(rx_int), 
	.xinlv(xinlv_1)
    );

uart_bps_xinlv u_uart_bps_xinlv (
    .clk(clk), 
    .rst_n(rst_n), 
    .cnt_start(bps_start),
    .bps_sig(clk_bps)
    );

uart_receive_xinlv u_uart_receive_xinlv (
    .clk(clk), 
    .rst_n(rst_n), 
    .clk_bps(clk_bps), 
    .data_rx(data_rx), 
    .rx_int(rx_int), 
    .data_tx(data_tx), 
    .bps_start(bps_start)
    );


endmodule
