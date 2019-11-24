module gps_rx(
    input               clk,
    input               rst_n,
    input   [7:0]       data_rx,
	input				rx_int,//当uart_rx模块接收完对方的数据后，传给uart_tx,此为标志位，标志uart_tx要开始工作
	output  reg [183:0] data_rx_end,
	output [47:0] ymr_out,
	output reg [71:0]  time_out
);

//-------------------------------------------------------
//每个8位数据接收完整的标志	
	reg	[1:0]	rx_int_r;	
	always@(posedge	clk	or	negedge	rst_n)begin
		if(!rst_n)	begin
			rx_int_r[0]	<=	1'b0;
			rx_int_r[1]	<=	1'b0;
		end
		else	begin
			rx_int_r[0]	<=	rx_int;
			rx_int_r[1]	<=	rx_int_r[0];
		end
	end

	wire	nege_edge	= 	rx_int_r[1]	&	~rx_int_r[0];//下降沿


//---------------------------------------------------
	reg	[7:0]	data_rx_r;//用来接收传过来的data_rx	
//将rx接来的数据存下来
	always@(posedge	clk	or	negedge	rst_n)begin
		if(!rst_n)	begin
			data_rx_r <= 8'd0;
		end
		else	if(nege_edge)begin
			data_rx_r <= data_rx;
		end
	end

reg         detected_o;
parameter length = 7; //更方便地更改状态长度

parameter [length-1 : 0]                         //one-hot code
                S_IDLE   = 7'b0000001,
                S_State1 = 7'b0000010,
                S_State2 = 7'b0000100,
                S_State3 = 7'b0001000,
                S_State4 = 7'b0010000,
				S_State5 = 7'b0100000,
				S_State6 = 7'b1000000;

reg [length-1 : 0] c_state;
reg [length-1 : 0] n_state;
//三段式状态机
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c_state <= S_IDLE; // reset低电平复位        
    end
    else begin
        c_state <= n_state; //next state logic
    end
end

always @(*) begin   //state register
    case(c_state)
        S_IDLE   : 
          if (data_rx_r == 8'h24 && nege_edge)//$
            n_state = S_State1;
          else 
            n_state = S_IDLE;
        S_State1 :
          if (data_rx_r == 8'h47 && nege_edge)//G
            n_state = S_State2;
          else 
            n_state = S_State1;
        S_State2 :
          if (data_rx_r == 8'h50  && nege_edge)//P
            n_state = S_State3;
          else  
            n_state = S_State2;
        S_State3 :
          if (data_rx_r == 8'h52 && nege_edge)//R
            n_state = S_State4;
          else 
            n_state = S_State3;
        S_State4 :
          if (data_rx_r == 8'h4D && nege_edge)//M
            n_state = S_State5;
          else 
            n_state = S_State4; 
		S_State5 :
          if (data_rx_r == 8'h43 && nege_edge)//C
            n_state = S_State6;
          else 
            n_state = S_State5;
		S_State6 :
		  if (data_rx_r && nege_edge)
            n_state = S_IDLE;
          else 
            n_state = S_IDLE;
        default :
            n_state = S_IDLE;
    endcase 
end
//4，$GPRMC（推荐定位信息，Recommended Minimum Specific GPS/Transit Data） $GPRMC语句的基本格式如下： $GPRMC,(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)*hh(CR)(LF) (1) UTC时间，hhmmss（时分秒） (2) 定位状态，A=有效定位，V=无效定位 (3) 纬度ddmm.mmmmm（度分） (4) 纬度半球N（北半球）或S（南半球） (5) 经度dddmm.mmmmm（度分） (6) 经度半球E（东经）或W（西经） (7) 地面速率（000.0~999.9节） (8) 地面航向（000.0~359.9度，以真北方为参考基准） (9) UTC日期，ddmmyy（日月年） (10)磁偏角（000.0~180.0度，前导位数不足则补0） (11) 磁偏角方向，E（东）或W（西） (12) 模式指示（A=自主定位，D=差分，E=估算，N=数据无效） 举例如下：  $GPRMC,023543.00,A,2308.28715,N,11322.09875,E,0.195,,240213,,,A*78 
 

//状态机输出output logic
always @ (posedge clk or negedge rst_n) begin   
	if(!rst_n) begin
		detected_o <= 1'b0;
		end
	else if( c_state == S_State6) begin
		detected_o <= 1'b1;
		end
	else begin
		detected_o <= 1'b0;
		end
	end
	
///检测到上升沿信号后持续输出高电平
	reg [3:0] num; //包传到哪个数据了
//	reg			a_flag;	//UTC位置标识位
reg	start_reg;
reg timeout;
always@(posedge clk)
   start_reg <= detected_o;

reg [3:0] count;   
always@(posedge clk or negedge rst_n) begin
   if (!rst_n)
		timeout <= 0;
   else if(start_reg == 0 && detected_o ==1)
       timeout <= 1;
   else if(count == 4'd10)                 //count记,的
       timeout <= 0;
   else
       timeout <= timeout;
	end
/////	

	reg	[7:0]	data_pickup_r;//用来提取接收传过来的data_rx	
//将rx接来的数据存下来
	always@(posedge	clk or negedge rst_n)begin
		if(!rst_n)	begin
			data_pickup_r <= 8'd0;
		end
		else if(timeout) begin
			data_pickup_r <= data_rx_r;               //此时已经是传完$GPRMC，后面传的均为数据
		end
	end

//	reg [3:0] count;
	always@(posedge clk or negedge rst_n)             //count加——逗号与逗号之间  num加——各个数据每一个字
	begin
		if(!rst_n)
			count <= 0;
		else if(data_pickup_r==8'h2C && nege_edge)
			count <= count + 1;
		else if(start_reg == 0 && detected_o ==1)
			count <= 0;
		else
			count <= count;
	end

		//-------------------------------------------------------	
//判断包头，确定开始，以及识别号
	always@(posedge	clk	or	negedge	rst_n)begin
		if(!rst_n)	num	<= 4'd0;
		else 	if(start_reg == 0 && detected_o ==1)	num <= 0;
		else	if(data_pickup_r==8'h2C&&nege_edge )	num <= 4'd1;
		else	if(timeout&&nege_edge)						num <= num + 1'b1;
		else	num <= num;
	end


	//-----------------------------------------------------
//根据标识位分类给寄存器赋值	
	reg	[79:0]	Latitude ;    //纬度
	reg	[87:0]	longitude ;   //经度
	reg	[71:0]	UTC_time ;   //UTC时间
	reg [47:0]	ddmmyy;
	reg [7:0] E_flag;
	reg [7:0] N_flag;
	always@(posedge	clk	or	negedge	rst_n)begin
		if(!rst_n)	begin
			Latitude <= 0;						
			longitude <= 0;						
			UTC_time <= 0;	
			ddmmyy <= 0;
			E_flag <= 0;
			N_flag <= 0;
		end                                                           //$GPRMC,023543.00,A,2308.28715,N,11322.09875,E,0.195,,240213,,,A*78 
		else if(count == 4'd1&&nege_edge&& data_pickup_r!=8'h2C )begin              //时间
			case(num)	
				4'd1:	UTC_time[71:64] <= data_pickup_r;                      // 134104.00 13点41分04秒[3133343130342e3030]
				4'd2:	UTC_time[63:56] <= data_pickup_r;
				4'd3:	UTC_time[55:48] <= data_pickup_r;
				4'd4:	UTC_time[47:40] <= data_pickup_r;
				4'd5:   UTC_time[39:32] <= data_pickup_r;
				4'd6: 	UTC_time[31:24] <= data_pickup_r;
				4'd7:	UTC_time[23:16] <= data_pickup_r;  //小数点
				4'd8:	UTC_time[15:8]  <= data_pickup_r;
				4'd9:	UTC_time[7:0]   <= data_pickup_r;
			default:;	
			endcase
		end
		else if(count == 4'd3&&nege_edge&& data_pickup_r!=8'h2C)begin             //维度
			case(num)
			4'd1:	Latitude[79:72] <= data_pickup_r;//  3             3409.22851  [33342e30393232383531] 9.22851/60  34.1538085
			4'd2:	Latitude[71:64] <= data_pickup_r;//	4
			4'd5:	Latitude[63:56] <= data_pickup_r;//.
			4'd3:	Latitude[55:48] <= data_pickup_r;//0
			4'd4:   Latitude[47:40] <= data_pickup_r;//9
			4'd6:	Latitude[39:32] <= data_pickup_r;//
			4'd7:	Latitude[31:24] <= data_pickup_r;//
			4'd8: 	Latitude[23:16] <= data_pickup_r;//
			4'd9:	Latitude[15:8] <= data_pickup_r;//
			4'd10:	Latitude[7:0]  <= data_pickup_r;//
			default:;
			endcase
		end
		else if(count == 4'd4&&nege_edge&& data_pickup_r!=8'h2C)begin
			N_flag[7:0]  <= data_pickup_r;//N
			end
		else if(count == 4'd5&&nege_edge&& data_pickup_r!=8'h2C)begin      //经度
			case(num)
			4'd1:	longitude[87:80] <= data_pickup_r;//1            10853.63286 [3130382e35333633323836]
			4'd2:	longitude[79:72] <= data_pickup_r;//0
			4'd3:	longitude[71:64] <= data_pickup_r;//8
			4'd6:	longitude[63:56] <= data_pickup_r;//.
			4'd4:   longitude[55:48] <= data_pickup_r;//5
			4'd5:	longitude[47:40] <= data_pickup_r;//3
			4'd7:	longitude[39:32] <= data_pickup_r;  
			4'd8:	longitude[31:24] <= data_pickup_r;   
			4'd9:	longitude[23:16] <= data_pickup_r;
			4'd10:	longitude[15:8]  <= data_pickup_r;
			4'd11:	longitude[7:0]   <= data_pickup_r;
			default:;
			endcase
		end	
		else if(count == 4'd6&&nege_edge&& data_pickup_r!=8'h2C)begin
			E_flag[7:0]  <= data_pickup_r;//E
			end
		else if(count == 4'd9&&nege_edge&& data_pickup_r!=8'h2C)begin
			case(num)                                                    //171019  19年10月17日 [313931303137]
			4'd5:	ddmmyy[47:40] <= data_pickup_r;
			4'd6:	ddmmyy[39:32] <= data_pickup_r;
			4'd3:	ddmmyy[31:24] <= data_pickup_r;
			4'd4:	ddmmyy[23:16] <= data_pickup_r;
			4'd1:	ddmmyy[15:8]  <= data_pickup_r;
			4'd2:	ddmmyy[7:0]   <= data_pickup_r;
			default:;
			endcase  
		end	
	end
	
	assign ymr_out = ddmmyy;
	always@(*)
	begin
		if(E_flag[7:4]==4'b0100)
		 data_rx_end ={N_flag,Latitude,E_flag,longitude};
		else data_rx_end=1'b0;
	end
	always@(*)
	begin
		if(UTC_time[7:4]==4'b0011)
		 time_out =UTC_time;
		else time_out=1'b0;
	end

endmodule
