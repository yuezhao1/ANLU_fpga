module hongwai_rx(
    input              			clk,
    input              			rst_n,
    input   	[7:0]      		data_rx,
	input						rx_int,//当uart_rx模块接收完对方的数据后，传给uart_tx,此为标志位，标志uart_tx要开始工作
		
	output	reg	[1:0]			flag_tu_ao//10凸起 01凹陷
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

parameter length = 4; //更方便地更改状态长度

parameter [length-1 : 0]                         //one-hot code
                S_IDLE    = 11'b0001,
                S_State1  = 11'b0010,
                S_State2  = 11'b0100,
                S_State3  = 11'b1000;

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
          if (data_rx_r == 8'h41 && nege_edge)//A   
            n_state = S_State1;
          else 
            n_state = S_IDLE;
        S_State1 :
          if (data_rx_r == 8'h42 && nege_edge)//B
            n_state = S_State2;
          else 
            n_state = S_State1;
        S_State2 :
          if (data_rx_r == 8'h43 && nege_edge)//C
            n_state = S_State3;
          else  
            n_state = S_State2;
		S_State3 :
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
	else if( c_state == S_State3) begin
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

always@(posedge clk or negedge rst_n) begin
   if (!rst_n)
		timeout <= 0;
   else if(start_reg == 0 && detected_o ==1)//检测上升沿的
		timeout <= 1;
   else
		timeout <= timeout;
	end



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

	
//-------------------------------------------------------	
//判断包头，确定开始，以及识别号
	always@(posedge	clk	or	negedge	rst_n)
	begin
		if(!rst_n)	
			num	<= 4'd0;
		else if(num == 4)
			num <= 0;
		else if( start_reg == 0 && detected_o ==1 )	
			num <= 0;
		else if( (timeout && nege_edge) || (timeout && start_reg))				
			num <= num + 1'b1;
		else	
			num <= num;
	end	
	
	
	reg		[23:0]		hongwai_distance;
	
	always@(posedge	clk	or	negedge	rst_n)begin
		if(!rst_n)
			hongwai_distance <= 24'b0000_0000_0000_0000_1111_1111;                                                       
		else if(nege_edge && data_pickup_r >= 8'h30 && data_pickup_r <= 8'h39)begin              
			case(num)
				4'd1:	hongwai_distance[23:16] <= data_pickup_r;                     
				4'd2:	hongwai_distance[15:8] <= data_pickup_r;
				4'd3:	hongwai_distance[7:0] <= data_pickup_r;
			default:;	
			endcase
		end
	end
	
	
	reg		[5:0]		cnt;
	//打50拍
	always@(posedge	clk	or	negedge	rst_n)
		begin
			if(!rst_n)	
			cnt <= 6'b0;
			else if(num == 1)
			cnt <= 6'b0;
			else if(cnt == 51)
			cnt <= cnt;
			else if(num == 3)
			cnt <= cnt + 1;
			else
			cnt <= 6'b0;
		end
	
	wire	flag_distance;
	//取红外距离值使能
	assign	flag_distance = (cnt == 50)?1:0;
	
	reg		[8:0]			distance;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
		distance <= 9'b0;
//		else if(nege_edge &&(num == 1 || num == 2 || num == 3))	//距离为3位十进制
		else if(num == 4)
		distance <= hongwai_distance[19:16]*100 + hongwai_distance[11:8]*10 + hongwai_distance[3:0];
		else				
		distance <= distance;
	end	
		

		
		
		
	reg [8:0]	distance_1;
	
	always@(posedge clk)
		distance_1 <= distance;
	
	
	wire		a;
	
	assign a = (distance_1 <= 70 && distance_1 >= 60)?1:0;
	
	
	reg			a0;
	reg			a1;
	reg			a2;
	reg			a3;
	reg			a4;
	reg			a5;
	reg			a6;
	reg			a7;	
	reg			a8;
	reg			a9;
	reg			a10;
	reg			a11;	
	reg			a12;
	reg			a13;
	reg			a14;
	reg			a15;
	reg			a16;
	reg			a17;
	reg			a18;
	reg			a19;
	reg			a20;
	reg			a21;
	
	
	
	always @(posedge clk or negedge rst_n)
		if(!rst_n)begin
			a0	<= 1'b0;
			a1	<= 1'b0;
			a2	<= 1'b0;
			a3	<= 1'b0;
			a4	<= 1'b0;
			a5	<= 1'b0;
			a6	<= 1'b0;
			a7	<= 1'b0;
			a8	<= 1'b0;
			a9  <= 1'b0;
			a10 <= 1'b0;
			a11 <= 1'b0;
			a12	<= 1'b0;
			a13 <= 1'b0;
			a14 <= 1'b0;
			a15 <= 1'b0;
			a16 <= 1'b0;
			a17 <= 1'b0;
			a18 <= 1'b0;
			a19 <= 1'b0;
			a20 <= 1'b0;
			a21 <= 1'b0;
			
			end	
		else	begin
			a0	<=  a;
			a1	<=  a0;
			a2	<=  a1;
			a3	<=  a2;
			a4	<=	a3;	
			a5	<=  a4;	
			a6	<=  a5;	
			a7	<=  a6;	
			a8	<=  a7;	
			a9  <=  a8;	
			a10 <=  a9; 
			a11 <=  a10;
			a12	<=  a11;
			a13	<=  a12;
			a14	<=	a13;	
			a15	<=  a14;	
			a16	<=  a15;	
			a17	<=  a16;	
			a18	<=  a17;	
			a19 <=  a18;	
			a20 <=  a19; 
			a21 <=  a20;
			end	

	wire		b;
	
	assign b = (distance_1 <= 97 && distance_1 >= 82)?1:0;
	
	
	reg			b0;
	reg			b1;
	reg			b2;
	reg			b3;
	
	always @(posedge clk or negedge rst_n)
		if(!rst_n)begin
			b0 <= 1'b0;
			b1 <= 1'b0;
			b2 <= 1'b0;
			b3 <= 1'b0;
			end	
		else	begin
			b0 <=  b;
			b1 <=  b0;
			b2 <=  b1;
			b3 <=  b2;
			end		
	
	wire	aoxian;
	assign aoxian = ((a0 && a1 && a2 && a3 && a4 && a5 && a6 && a7 && a8 && a9 && a10 && a11 && a12 && a13 && a14 && a15 && a16 && a17 && a18 && a19 && a20 && a21 )==1)?1:0;
	
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				flag_tu_ao <= 2'b0;
			else if((b0 && b1 && b2 && b3) == 1)
				flag_tu_ao <= 2'b11;			
			else if(aoxian == 1)//凹陷 01
				flag_tu_ao <= 2'b01;
			else
				flag_tu_ao <= 2'b0;
		end
	
	
	
endmodule

