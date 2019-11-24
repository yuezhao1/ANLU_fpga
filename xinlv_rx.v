module xinlv_rx(
    input              			clk,
    input              			rst_n,
    input   	[7:0]      		data_rx,
	input						rx_int,//当uart_rx模块接收完对方的数据后，传给uart_tx,此为标志位，标志uart_tx要开始工作
		
	output	reg	[7:0]			xinlv//
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
          if (data_rx_r == 8'h42 && nege_edge)//B  
            n_state = S_State1;
          else 
            n_state = S_IDLE;
        S_State1 :
          if (data_rx_r == 8'h50 && nege_edge)//P
            n_state = S_State2;
          else 
            n_state = S_State1;
        S_State2 :
          if (data_rx_r == 8'h4d && nege_edge)//M
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
		else if(num == 3)
			num <= 0;
		else if( start_reg == 0 && detected_o ==1 )	
			num <= 0;
		else if( (timeout && nege_edge) || (timeout && start_reg))				
			num <= num + 1'b1;
		else	
			num <= num;
	end	
	
	
	reg		[15:0]		xinlv_ascii;
	
	always@(posedge	clk	or	negedge	rst_n)begin
		if(!rst_n)
			xinlv_ascii <= 16'b0000_0000_1111_1111;                                                       
		else if(nege_edge && data_pickup_r >= 8'h30 && data_pickup_r <= 8'h39)begin              
			case(num)
				4'd1:	xinlv_ascii[15:8] <= data_pickup_r;                     
				4'd2:	xinlv_ascii[7:0] <= data_pickup_r;
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
			else if(num == 2)
			cnt <= cnt + 1;
			else
			cnt <= 6'b0;
		end
	
	wire	flag_distance;
	//取红外距离值使能
	assign	flag_distance = (cnt == 50)?1:0;
	
	reg		[7:0]			xinlv_10jinzhi;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
		xinlv_10jinzhi <= 8'b0;
		else if(num == 3)
		xinlv_10jinzhi <= xinlv_ascii[11:8]*10 + xinlv_ascii[3:0];
		else				
		xinlv_10jinzhi <= xinlv_10jinzhi;
	end	
		
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
		xinlv <= 8'b0;
		else if( xinlv_10jinzhi >= 60 && xinlv_10jinzhi <= 90)
		xinlv <= xinlv_10jinzhi;
		else
		xinlv <= xinlv;		
		end
	
endmodule

