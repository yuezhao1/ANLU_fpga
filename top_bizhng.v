module top_bizhng(clk,rst,echo,trig,dianji2,flag,echo2,trig2,data_rx,RX232,led1,led0,jiaodu,led4,led5,led6,led7,flag1
    );
	input clk;
	input rst;
	input echo;
	input echo2;
	input flag;
	input data_rx;
	output RX232;
	output [9:0]jiaodu;
	output trig;
	output trig2;
	output led1;
		output led0;
		output led7;
	output  led6;
	output  led5;
	output  led4;
	output [1:0]dianji2;
	output flag1;
	wire [9:0]jiaodu;
	wire [9:0]jiaodu1;
	wire [9:0]hq;
	wire [9:0]hz;
	wire rst;
bizhang bi (
    .clk(clk), 
    .rst(rst), 
    .hq(hq), 
    .hz(hz), 
    .jiaodu(jiaodu), 
    .dianji2(dianji2), 
    .led7(led7), 
    .led6(led6), 
    .led5(led5), 
    .led4(led4),  
    .jiaodu1(jiaodu1),
	.flag1(flag1)
    );

top2  st (
    .clk(clk), 
    .rst_n(rst), 
    .echo2(echo2), 
    .trig2(trig2), 
    .led0(led0), 
    .hz(hz)
    );
top  to (
    .clk(clk), 
    .rst_n(rst), 
    .echo(echo), 
    .trig(trig), 
    .led1(led1), 
    .hq(hq)
    );
/*top_gy_26 na (
    .flag(flag), 
    .clk(clk), 
    .rst_n(rst), 
    .data_rx(data_rx), 
    .RX232(RX232), 
    .jiaodu(jiaodu)
    );*/
	top_gy_26 na (
    .flag(flag), 
    .clk(clk), 
    .rst(rst), 
    .data_rx(data_rx), 
    .jiaodu(jiaodu), 
    .RX232(RX232)
    );
endmodule
