module tp_z(

clk,rst,du_en,flag_gy26,data_rx,RX232,smg_duan,smg_wei,dp,a,b,dianji
    );
	input	clk;
	input	rst;
	input	du_en;
	input	a;
	input	b;
    input	flag_gy26;
	input	data_rx;
	
	output 	RX232;
	output 	[1:0]dianji;
	output 	[6:0]smg_duan;
	output 	[3:0]smg_wei;
	output 	dp;
	
	
	wire [9:0]jiaodu;
	wire [60:0]jishu;
	wire rst;
	
	wire [7:0]licheng;
	
	  //wire [9:0]jiaodu;

shumaguan sh (
    .jishu(jishu), 
	.jiaodu(jiaodu),
    .clk(clk), 
    .smg_duan(smg_duan), 
    .smg_wei(smg_wei), 
    .dp(dp), 
    .rst(rst),
	.licheng1(licheng)
    );
zhuti zh (
    .clk(clk), 
    .rst(rst), 
    .du_en(du_en), 
    .a(a), 
    .b(b), 
    .jiaodu(jiaodu), 
    .dianji(dianji), 
	.baidu_JD(baidu_JD),
    .jishu(jishu), 
    .JD(JD),
	.licheng(licheng)
    );
top_gy_26 to (
    .flag_gy26(flag_gy26), 
    .clk(clk), 
    .rst(rst), 
    .data_rx(data_rx), 
    .jiaodu(jiaodu), 
    .RX232(RX232)
    );

/*top to (
    .clk(clk), 
    .rst(rst), 
    .a(a), 
    .b(b), 
    .smg_duan(smg_duan), 
    .smg_wei(smg_wei), 
    .dp(dp), 
    .turn1(turn1), 
    .key1(key1), 
    .key2(key2)
    );*/


endmodule
