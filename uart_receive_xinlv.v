module uart_receive_xinlv(
	input	clk,
	input	rst_n,
	input	clk_bps,//clk_bps控制的反馈的拍子
	input	data_rx,//接收数据
	output	reg	rx_int,//反馈信号，正常接收信号反馈“1”，接收结束停止接收反馈“0”。
	output	[7:0]	data_tx,//接收到数据后发送个uart_tx
	output	reg	bps_start	//开始检测到uart_rx接受完数据了，启动clk_bps模块，调节时钟
    );
	
//-------------------------
reg	[1:0]	rx;

always@(posedge	clk	or	negedge	rst_n)begin
	if(!rst_n)	rx <= 2'b11;
	else	begin
		rx[0]	<=	data_rx;
		rx[1]	<=	rx[0];
	end
end
wire	nege_edge;
	assign nege_edge= rx[1]	&	~rx[0];//检测下降沿

reg	[3:0]num;

always@(posedge	clk	or	negedge	rst_n)begin
	if(!rst_n)	begin	
		bps_start <= 1'b0;	
		rx_int <= 1'b0;
	end
	else	if(nege_edge)begin
		bps_start <= 1'b1;
		rx_int <= 1'b1;
	end
	else if(num == 4'd10)begin
		bps_start <= 1'b0;	
		rx_int <= 1'b0;
	end
end

reg	[7:0]	rx_data_temp_r;//当前数据接收寄存器
reg	[7:0]	rx_data_r;//用来锁存数据
always@(posedge	clk	or	negedge	rst_n)begin
	if(!rst_n)	begin	
		rx_data_r	<= 8'd0;
		rx_data_temp_r	<= 8'd0;
		num <= 4'd0;
	end
	else	if(rx_int)begin
		if(clk_bps)begin
			num <= num + 1'b1;
			case(num)
				4'd1: rx_data_temp_r[0] <= data_rx;	//锁存第0bit
				4'd2: rx_data_temp_r[1] <= data_rx;	//锁存第1bit
				4'd3: rx_data_temp_r[2] <= data_rx;	//锁存第2bit
				4'd4: rx_data_temp_r[3] <= data_rx;	//锁存第3bit
				4'd5: rx_data_temp_r[4] <= data_rx;	//锁存第4bit
				4'd6: rx_data_temp_r[5] <= data_rx;	//锁存第5bit
				4'd7: rx_data_temp_r[6] <= data_rx;	//锁存第6bit
				4'd8: rx_data_temp_r[7] <= data_rx;	//锁存第7bit
				default: ;
			endcase
		end
		else if(num == 4'd10)begin
			rx_data_r	<=rx_data_temp_r;
			num <= 4'd0;
		end
	end
end

assign	data_tx = rx_data_r;

endmodule
