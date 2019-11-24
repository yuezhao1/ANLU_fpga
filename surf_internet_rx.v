module surf_internet_rx(
    input              		clk,
    input              		rst_n,
    input   [7:0]      		data_rx,
	input					rx_int,//当uart_rx模块接收完对方的数据后，传给uart_tx,此为标志位，标志uart_tx要开始工作
		
	output					flag_en_1,
	output	reg	[7:0]		addr_daohang_data,	
	output  reg [92:0] 		data_rx_end_internet
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
//					//
//	检测分段距离  	//
//	            	//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

parameter length = 11; //更方便地更改状态长度

parameter [length-1 : 0]                         //one-hot code
                S_IDLE    = 11'b0000_0000_001,
                S_State1  = 11'b0000_0000_010,
                S_State2  = 11'b0000_0000_100,
                S_State3  = 11'b0000_0001_000,
                S_State4  = 11'b0000_0010_000,
				S_State5  = 11'b0000_0100_000,
                S_State6  = 11'b0000_1000_000,
				S_State7  = 11'b0001_0000_000,				
                S_State8  = 11'b0010_0000_000,
                S_State9  = 11'b0100_0000_000,				
				S_State10 = 11'b1000_0000_000;

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
          if (data_rx_r == 8'h64 && nege_edge)//d   
            n_state = S_State1;
          else 
            n_state = S_IDLE;
        S_State1 :
          if (data_rx_r == 8'h69 && nege_edge)//i
            n_state = S_State2;
          else 
            n_state = S_State1;
        S_State2 :
          if (data_rx_r == 8'h73 && nege_edge)//s
            n_state = S_State3;
          else  
            n_state = S_State2;
        S_State3 :
          if (data_rx_r == 8'h74 && nege_edge)//t
            n_state = S_State4;
          else 
            n_state = S_State3;
        S_State4 :
          if (data_rx_r == 8'h61 && nege_edge)//a
            n_state = S_State5;
          else 
            n_state = S_State4; 
		S_State5 :
          if (data_rx_r == 8'h6e && nege_edge)//n		distance":
            n_state = S_State6;
          else 
            n_state = S_State5;
		S_State6 :
          if (data_rx_r == 8'h63 && nege_edge)//c		
            n_state = S_State7;
          else 
            n_state = S_State6;			
		S_State7 :
          if (data_rx_r == 8'h65 && nege_edge)//e
            n_state = S_State8;
          else 
            n_state = S_State7;			
		S_State8 :
          if (data_rx_r == 8'h22 && nege_edge)//"
            n_state = S_State9;
          else 
            n_state = S_State8;	
		S_State9 :
          if (data_rx_r == 8'h3a && nege_edge)//:
            n_state = S_State10;
          else 
            n_state = S_State9;		
		S_State10 :
		  if (data_rx_r && nege_edge)
            n_state = S_IDLE;
          else 
            n_state = S_IDLE;
        default :
            n_state = S_IDLE;
    endcase 
end

 
reg         detected_o;
//状态机输出output logic
always @ (posedge clk or negedge rst_n) begin   
	if(!rst_n) begin
		detected_o <= 1'b0;
		end
	else if( c_state == S_State10) begin
		detected_o <= 1'b1;
		end
	else begin
		detected_o <= 1'b0;
		end
	end
	
///检测到上升沿信号后持续输出高电平
	reg [5:0] num; //包传到哪个数据了
	reg	start_reg;
	reg timeout;
always@(posedge clk)
   start_reg <= detected_o;

	reg [7:0] count;
always@(posedge clk or negedge rst_n) begin
   if (!rst_n)
		timeout <= 0;
   else if(start_reg == 0 && detected_o ==1)//检测上升沿的
		timeout <= 1;
   else if(count == 8'd85)                  //count记,的
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


	
	always@(posedge clk or negedge rst_n)             //count加——逗号与逗号之间  num加——各个数据每一个字
	begin
		if(!rst_n)
			count <= 7;
		else if(data_pickup_r==8'h2C && nege_edge)
			count <= count + 1;
		else if(start_reg == 0 && detected_o ==1)
			count <= 0;
		else
			count <= count;
	end

		//-------------------------------------------------------	
//判断包头，确定开始，以及识别号
	always@(posedge	clk	or	negedge	rst_n)
	begin
		if(!rst_n)	
			num	<= 4'd0;
		else if( start_reg == 0 && detected_o ==1 )	
			num <= 0;
//		else if( data_pickup_r==8'h2C && nege_edge )	
//			num <= 4'd1;
		else if( (timeout && nege_edge) || (timeout && start_reg))				
			num <= num + 1'b1;
		else	
			num <= num;
	end


	//-----------------------------------------------------
//根据标识位分类给寄存器赋值	
	reg	[79:0]	Latitude;		//纬度
	reg	[87:0]	longitude;		//经度
	reg	[23:0]	distance_1;	//距离
	always@(posedge	clk	or	negedge	rst_n)begin
		if(!rst_n)	begin
			Latitude <= 0;						
			longitude <= 0;						
			distance_1 <= 24'b0000_0000_0000_0000_1111_1111;
		end                                                           
		else if(count == 8'd0 && nege_edge && data_pickup_r!=8'h2C && data_pickup_r >= 8'h30 && data_pickup_r <= 8'h39)begin              
			case(num)
				4'd1:	distance_1[23:16] <= data_pickup_r;                     
				4'd2:	distance_1[15:8] <= data_pickup_r;
				4'd3:	distance_1[7:0] <= data_pickup_r;
			default:;	
			endcase
		end
		else if(count == 8'd3&&nege_edge&& data_pickup_r!=8'h2C)begin          //维度
			case(num)
				4'd1:	Latitude[39:32] <= data_pickup_r;
				4'd2:	Latitude[31:24] <= data_pickup_r;
				4'd3:	Latitude[23:16] <= data_pickup_r;
				4'd4:   Latitude[15:8] 	<= data_pickup_r;
				4'd5:	Latitude[7:0]  	<= data_pickup_r;	
			default:;
			endcase
		end
		else begin
			if(count == 8'd5 && nege_edge && data_pickup_r != 8'h2C)begin      //经度
			case(num)
				4'd1:	longitude[39:32] <= data_pickup_r;
				4'd2:	longitude[31:24] <= data_pickup_r;
				4'd3:	longitude[23:16] <= data_pickup_r;
				4'd4:	longitude[15:8]  <= data_pickup_r;
				4'd5:   longitude[7:0]   <= data_pickup_r;	
			default:;
			endcase
			end	
		end
	end			
	
reg	[8:0]	distance;
	
	always @(posedge clk)
	begin
		if(data_pickup_r == 8'h2c && num == 3)	//距离为2位十进制
		distance <= distance_1[19:16]*10 + distance_1[11:8];
		else								//距离为3位十进制
		distance <= distance_1[19:16]*100 + distance_1[11:8]*10 + distance_1[3:0];
	end	
		
	


 
reg		[23:0]		b0;
reg		[23:0]		b1;
reg		[23:0]		b2;
reg		[23:0]		b3;
reg		[23:0]		b4;
reg		[23:0]		b5;
reg		[23:0]		b6;
reg		[23:0]		b7;

always @(posedge clk or negedge rst_n)
	if(!rst_n)
	begin
	b0 <= 24'd0;
	b1 <= 24'd0;
	b2 <= 24'd0;
	b3 <= 24'd0;
	b4 <= 24'd0;
	b5 <= 24'd0;
	b6 <= 24'd0;
	b7 <= 24'd0;
	end
	else begin
	b0 <= distance_1;
	b1 <= b0;
	b2 <= b1;
	b3 <= b2;
	b4 <= b3;
    b5 <= b4;
    b6 <= b5;
    b7 <= b6;
	end
	
reg		flag;
always @(*)
	begin
	if( (b7 - b6) == 0  && distance >= 18 && distance <= 227 && num == 3)
	flag = 1;
	else
	flag = 0;
	end
	
	

	
	wire [7:0]	c;
	
	assign c = flag ? distance[7:0] : 8'd0;
	
	wire [7:0]	d;
	assign d = (c > 200) ? c+5 : c;
	
reg		g0;
reg     g1;

	
always @(posedge clk or negedge rst_n)
	if(!rst_n)
	begin
	g0 <= 1'b0;
	g1 <= 1'b0;
	end
	else 
	begin
	g0 <= flag;
	g1 <= g0;
	end
	
wire	flag_posedge;
wire	flag_negedge;	
	
assign flag_posedge= (g0 && ~g1)? 1 : 0;	
assign flag_negedge= (~g0 && g1)? 1 : 0;
	
reg		[7:0]		cnt;	
	
	
always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		cnt <= 8'b0;
		else if(flag_negedge)
		cnt <= 8'b0;
		else if(cnt == 51)
		cnt <= cnt;
		else if(flag)
		cnt <= cnt + 1;
		else
		cnt <= cnt;
	end
	
	
//存ram信号
assign flag_en = (cnt == 50)?1:0;
	
	
		

	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
//				//
//	检测转向角  //
//	            //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



	
parameter length_1 = 12; //更方便地更改状态长度

parameter [length_1-1 : 0]                         //one-hot code
                S_IDLE_1_1		= 12'b0000_0000_0001,
                S_State1_1		= 12'b0000_0000_0010,
                S_State2_1		= 12'b0000_0000_0100,
                S_State3_1		= 12'b0000_0000_1000,
                S_State4_1		= 12'b0000_0001_0000,
				S_State5_1		= 12'b0000_0010_0000,
                S_State6_1		= 12'b0000_0100_0000,
				S_State7_1		= 12'b0000_1000_0000,				
                S_State8_1		= 12'b0001_0000_0000,
                S_State9_1		= 12'b0010_0000_0000,				
				S_State10_1		= 12'b0100_0000_0000,
				S_State11_1		= 12'b1000_0000_0000;		
				

reg [length_1-1 : 0] c_state_1;
reg [length_1-1 : 0] n_state_1;
//三段式状态机
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c_state_1 <= S_IDLE_1_1; // reset低电平复位        
    end
    else begin
        c_state_1 <= n_state_1; //next state logic
    end
end

always @(*) begin   //state register
    case(c_state_1)
        S_IDLE_1_1   : 
          if (data_rx_r == 8'h64 && nege_edge)//d   
            n_state_1 = S_State1_1;
          else 
            n_state_1 = S_IDLE_1_1;
        S_State1_1 :
          if (data_rx_r == 8'h69 && nege_edge)//i
            n_state_1 = S_State2_1;
          else 
            n_state_1 = S_State1_1;
        S_State2_1 :
          if (data_rx_r == 8'h72 && nege_edge)//r
            n_state_1 = S_State3_1;
          else  
            n_state_1 = S_State2_1;
        S_State3_1 :
          if (data_rx_r == 8'h65 && nege_edge)//e
            n_state_1 = S_State4_1;
          else 
            n_state_1 = S_State3_1;
        S_State4_1 :
          if (data_rx_r == 8'h63 && nege_edge)//c
            n_state_1 = S_State5_1;
          else 
            n_state_1 = S_State4_1; 
		S_State5_1 :
          if (data_rx_r == 8'h74 && nege_edge)//t		
            n_state_1 = S_State6_1;
          else 
            n_state_1 = S_State5_1;
		S_State6_1 :
          if (data_rx_r == 8'h69 && nege_edge)//i		
            n_state_1 = S_State7_1;
          else 
            n_state_1 = S_State6_1;			
		S_State7_1 :
          if (data_rx_r == 8'h6f && nege_edge)//o
            n_state_1 = S_State8_1;
          else 
            n_state_1 = S_State7_1;		
		S_State8_1 :
          if (data_rx_r == 8'h6e && nege_edge)//n
            n_state_1 = S_State9_1;
          else 
            n_state_1 = S_State8_1;	
		S_State9_1 :
          if (data_rx_r == 8'h22 && nege_edge)//"
            n_state_1 = S_State10_1;
          else 
            n_state_1 = S_State9_1;	
		S_State10_1 :
          if (data_rx_r == 8'h3a && nege_edge)//:
            n_state_1 = S_State11_1;
          else 
            n_state_1 = S_State10_1;		
		S_State11_1 :
		  if (data_rx_r && nege_edge)
            n_state_1 = S_IDLE_1_1;
          else 
            n_state_1 = S_IDLE_1_1;
        default :
            n_state_1 = S_IDLE_1_1;
    endcase 
end



reg         		detected_o_1;
//状态机输出output logic
always @ (posedge clk or negedge rst_n) begin   
	if(!rst_n) begin
		detected_o_1 <= 1'b0;
		end
	else if( c_state_1 == S_State11_1) begin
		detected_o_1 <= 1'b1;
		end
	else begin
		detected_o_1 <= 1'b0;
		end
	end
	
///检测到上升沿信号后持续输出高电平
	reg [5:0] num_1; //包传到哪个数据了
	reg	start_reg_1;
	reg timeout_1;
always@(posedge clk)
   start_reg_1 <= detected_o_1;

	reg [7:0] count_1;
always@(posedge clk or negedge rst_n) begin
   if (!rst_n)
		timeout_1 <= 0;
   else if(start_reg_1 == 0 && detected_o_1 ==1)//检测上升沿的
		timeout_1 <= 1;
   else if(count_1 == 8'd85)                  //count_1记,的
		timeout_1 <= 0;
   else
		timeout_1 <= timeout_1;
	end
/////	



	reg	[7:0]	data_pickup_r_1;//用来提取接收传过来的data_rx	
//将rx接来的数据存下来
	always@(posedge	clk or negedge rst_n)begin
		if(!rst_n)	begin
			data_pickup_r_1 <= 8'd0;
		end
		else if(timeout_1) begin
			data_pickup_r_1 <= data_rx_r;               //此时已经是传完direction": 后面传的均为数据
		end
	end


	
	always@(posedge clk or negedge rst_n)             //count加——逗号与逗号之间  num加——各个数据每一个字
	begin
		if(!rst_n)
			count_1 <= 7;
		else if(data_pickup_r_1==8'h2C && nege_edge)
			count_1 <= count_1 + 1;
		else if(start_reg_1 == 0 && detected_o_1 ==1)
			count_1 <= 0;
		else
			count_1 <= count_1;
	end

		//-------------------------------------------------------	
//判断包头，确定开始，以及识别号
	always@(posedge	clk	or	negedge	rst_n)
	begin
		if(!rst_n)	
			num_1	<= 4'd0;
		else if( start_reg_1 == 0 && detected_o_1 ==1 )	
			num_1 <= 0;
//		else if( data_pickup_r_1==8'h2C && nege_edge )	
//			num_1 <= 4'd1;
		else if((timeout_1 && nege_edge) || (timeout_1 && start_reg_1))				
			num_1 <= num_1 + 1'b1;
		else	
			num_1 <= num_1;
	end


	
	
	
	reg	[3:0]		direction;	

always@(posedge	clk	or	negedge	rst_n)begin
	if(!rst_n)						
		direction <= 8'b0;                                                         
	else if(count_1 == 8'd0 && nege_edge && data_pickup_r!=8'h2C && data_pickup_r >= 8'h30 && data_pickup_r <= 8'h39)             
		case(num_1)
			4'd1:	direction <= data_pickup_r[3:0];                     
		default:	direction <= 4'b0;	
		endcase
	end
	

	
always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)	
		data_rx_end_internet <= 93'b0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0;
		else if(flag)
		data_rx_end_internet[92:85] <= d;
		else if(num_1 == 2)
		data_rx_end_internet[83:80] <= direction;
		else
		data_rx_end_internet <= data_rx_end_internet;
	end	
	
	
reg		[7:0]		cnt_1;	
	
	
always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		cnt_1 <= 8'b0;
		else if(num_1 == 3)
		cnt_1 <= 8'b0;
		else if(cnt_1 == 51)
		cnt_1 <= cnt_1;
		else if(num_1 == 2)
		cnt_1 <= cnt_1 + 1;
		else
		cnt_1 <= cnt_1;
	end
		
//存ram信号
assign flag_en_1 = (cnt_1 == 50)?1:0;	


always @(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
	addr_daohang_data <= 8'b0;
	else if(cnt_1 == 50 )
	addr_daohang_data <= addr_daohang_data + 1'b1;
	else
	addr_daohang_data <= addr_daohang_data;
	end	
	
endmodule
