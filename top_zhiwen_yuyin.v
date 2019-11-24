module top_zhiwen_yuyin(
	input 					clk_24m,
	input 					rst_n,
	
	
	//指纹、语音检测、语音播�
	input 					data_rx_zhiwen,     //指纹模块输入接口
	input 					chumo,       		//指纹模块触摸输入电平
	output 		[1:0]		flag,      			//指纹检测指示灯  01匹配成功  10匹配失败  之后用flag[1]做其他模块的复位 即指纹检测不对其他模块不工作

	input 					key,
	input 					talk_rx,    		//语音识别模块输入接口
	output 					flag_shijian,    	//语音识别指示�
	input 					music_rx,   		//音乐播放模块输入接口
	output 					RX232_music,     	//音乐播放模块输出接口
	output 					RX232_zhiwen,
	output 					sj_en,


	
	
	//检测摔�
	input					rs232_rx_GY25,
	output					RX232_GY25,
	output		[1:0]		led_GY25,
	
	//发短�+ 经纬�
	input					data_rx_duanxin,//gps模块的经纬度的接�
	output					gsm_tx,

	
	//红外 接受�
	input					data_rx_hongwai,
	
	//打电�
	input					calling_sent_en_cheng,
	input					calling_sent_en_zhi,
	output					calling_tx,
	
	//心率
	input					data_rx_xinlv,
	
	//lora
	input					data_rx_lora,
	output		[1:0]		flag_lora_lora,
	output	reg				zhendong,
	output					RX232_lora_tx,
	
	//daohang
	input  du_en,
	input  a,
	input  b,
	
    input	flag_gy26,
	input	data_rx,
	output [1:0]dianji,
	output 	RX232,
	output 	[6:0]smg_duan,
	output 	[3:0]smg_wei,
	output 	dp
	

    );
	
	wire 		[17:0]		shijian;
	
	wire					clk_72m;
	wire					clk_50m;	
	wire					clk_25m;
	wire		[1:0]		flag_tu_ao;
	wire					flag_daohang;
	
	
	
PLL_50M u_PLL_50M(
		.refclk(clk_24m),
		.clk0_out(clk_72m),
		.clk1_out(clk_50m),
		.clk2_out(clk_25m)
	);	
	
	
top_zhiwen u_top_zhiwen (							//指纹模块实例�
    .clk(clk_50m), 
    .rst_n(rst_n), 
    .chumo(chumo), 
    .data_rx(data_rx_zhiwen), 
    .RX232(RX232_zhiwen), 
    .flag(flag)
    );


top_music u_top_music (							//音乐播放模块（任意时间播报）+语音识别模块 + 伪GPS 实例�
    //.key(key), 
    .clk(clk_50m), 
    .rst_n(rst_n),
	.shijian(shijian),
	.flag_shijian(flag_shijian),
	.flag_zhiwen(flag),
	.flag_music(flag_music),
	.flag_tu_ao(flag_tu_ao),
	.sj_en(sj_en),
	.flag_GY25(led_GY25),
    .music_rx(music_rx), 
	.over_all(over_all),
    .RX232(RX232_music), 
    .led(led)
    );
	
uart_rx_talk c (						//语音
    .clk(clk_50m), 
    .rst_n(flag[0]), 
    .data_rx(talk_rx), 
    .over_all(over_all), 
    .flag_shijian(flag_shijian), 
	.flag_music(flag_music),
	.flag_daohang(flag_daohang),
    .over_rx()
    );
	
	gps_yuyin d (						//语音播放时间
    .key(key), 
    .clk(clk_50m), 
    .rst_n(flag[0]), 
    .shijian(shijian)
    );
	
	//GY_25模块检测摔�
	TOP_GY_25 u_TOP_GY_25(
	.clk_24m(clk_24m),
	.rst_n(flag[0]),
	.rs232_rx(rs232_rx_GY25),
	.RX232(RX232_GY25),
	.led(led_GY25)
    );	
	
	
	reg					reg_led_GY25;
	
	always @(posedge clk_24m or negedge rst_n)
		begin
			if(!rst_n)
			reg_led_GY25 <= 1'b0;
			else if(led_GY25[0] == 1)
			reg_led_GY25 <= 1'b1;
			else if(led_GY25[0] == 0)
			reg_led_GY25 <= 1'b0;
			else
			reg_led_GY25 <= reg_led_GY25;
		end
	
	reg		[26:0]		cnt;
	
	always @(posedge clk_24m or negedge rst_n)
		begin
			if(!rst_n)
			cnt <= 27'b0;
			else if(cnt == 27'd1_2000_0000 - 1)
			cnt <= 0;
			else if(reg_led_GY25 == 1)
			cnt <= cnt + 1;
			else
			cnt <= cnt;
		end
	
	reg					GY_25_en;
	
	always @(posedge clk_24m or negedge rst_n)
		begin
		if(!rst_n)
			GY_25_en <= 1'b0;
		else if(cnt == 27'd1_2000_0000 - 1)
			GY_25_en <= led_GY25[0];
		else
			GY_25_en <= GY_25_en;
		end
	
	
	
	top_duanxin u_top_duanxin_gps(
	.clk(clk_50m),
	.rst_n(flag[0]),
	.mess_phone_number_prepared_enable(GY_25_en),//短信发送使能，连接按键
	.data_rx(data_rx_duanxin),
	.gsm_tx(gsm_tx)
	);
	
	lora_rx u_top_lora_rx(
	.clk(clk_50m),
	.rst_n(flag[0]),
	.data_rx(data_rx_lora),
	.over_all(over_all_lora),
	.flag_lora(flag_lora_lora),
	.over_rx(over_rx_lora)
    );
	
	
	always @(posedge clk_24m)
		if(flag_lora_lora == 2'b01 || flag_lora_lora == 2'b10 || flag_lora_lora == 2'b11)
			zhendong <= 1'b1;
		else
			zhendong <= 1'b0;
	
	//红外
	top_hongwai u_top_hongwai(
	.clk(clk_50m),
	.rst_n(flag[0]),
	.data_rx(data_rx_hongwai),
	.flag_tu_ao(flag_tu_ao)//语音模块播报_前方有凹�1
    );
	
	
	//打电�
	top_calling u_top_calling(
	.clk(clk_50m),
	.rst_n(flag[0]),
	.calling_sent_en_cheng(calling_sent_en_cheng),//打电话使能，连接按键
	.calling_sent_en_zhi(calling_sent_en_zhi),
	.calling_tx(calling_tx)
    );
	
	wire	[7:0]	xinlv;	
	
	//心率模块
	top_xinlv u_top_xinlv(
	.clk(clk_50m),
	.rst_n(flag[0]),
	.data_rx(data_rx_xinlv),
	.xinlv(xinlv)
    );
	
	//lora发�
	top_lora_tx u_top_lora_tx (
	.clk(clk_50m),
	.rst_n(flag[0]),
	.send_en(1),
	.data_rx(xinlv),
	.RX232(RX232_lora_tx),
	.over_rx()
	); 
	
	//导航
	tp_z u_tp_z(

	.clk(clk_50m),
	.rst(rst_n),
	.du_en(du_en),
	.a(a),
	.b(b),
    .flag_gy26(flag_gy26),
	.data_rx(data_rx),
	
	.RX232(RX232),					//RX232;		
	.dianji(dianji),	        //[1:0]dianji;
	.smg_duan(smg_duan),	        //[6:0]smg_duan;
	.smg_wei(smg_wei),	        //[3:0]smg_wei;
	.dp(dp)    );                //dp;


endmodule
