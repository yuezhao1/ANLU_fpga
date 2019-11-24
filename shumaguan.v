module shumaguan( jishu,jiaodu,clk,smg_duan,smg_wei,dp,rst,licheng1
    );
	input [60:0] jishu;
	  input [9:0]jiaodu;
	  input clk;
	  input rst;
	  output reg [6:0] smg_duan;
	  output reg [3:0] smg_wei;
	  output reg  dp;
      output  [7:0]licheng1;
 reg [1:0] s;
	 reg [3:0] digit;
	 wire [3:0] aen;
	 
	 parameter t1=18'd250000;
	 reg [17:0] cnt6;
	 
	 assign aen=4'b1111;
	 
	 always@(posedge clk or negedge rst)
	 begin
	    if(rst==0) begin
		    cnt6<=0;
		 end
		 else if(cnt6==t1-1) begin
		    cnt6<=0;
		 end
		 else begin
		    cnt6<=cnt6+1;
		 end
	 end
	 
	reg [60:0]jishu_dis;
	reg [60:0] jishu_reg1;
	reg [60:0] jishu_reg2;
	reg [7:0]a;
	reg [3:0]b;
	reg [3:0]c;
	reg [3:0]d;
	assign change =  (jishu_reg1 == jishu_reg2)?0:1;
	
	always@(posedge clk or negedge rst)
	begin
		if(!rst)
		begin
			jishu_reg1 <= 39'b0;
			jishu_reg2 <= 39'b0;
		end
		else 
		begin
			jishu_reg1 <= jishu;
			jishu_reg2 <= jishu_reg1;
		end
	end
	
	always@(posedge clk or negedge rst)
	begin
		if(!rst)
		begin
			jishu_dis <= 39'd0;
			a <= 4'd0;
			b <= 4'd0;
			c <= 4'd0;
			d <= 4'd0;
		end
		else if(change)
		begin
			a <= 4'd0;
			b <= 4'd0;
			c <= 4'd0;
			d <= 4'd0;
			jishu_dis <= jishu;
		end
		else  
		   begin
			if(jishu_dis >= 20'd1000000)//if(jishu_dis >= 16'd1000)
			begin
				jishu_dis <= jishu_dis - 20'd1000000;
				a <= a + 1;
			end
		else 
			if(jishu_dis >= 17'd100000)//if(jishu_dis >= 16'd100)
			begin
				jishu_dis <= jishu_dis - 17'd100000;
				b <= b + 1;
			end	
		else 
			if(jishu_dis >= 14'd10000)//if(jishu_dis >= 16'd10)
			begin
				jishu_dis <= jishu_dis - 14'd10000;
				c <= c + 1;
			end
		else 
			if(jishu_dis >= 10'd1000)//if(jishu_dis >= 16'd1)
			begin
				jishu_dis <= jishu_dis - 10'd1000;
				d <= d + 1;
			end
		else
			begin
				a <= a;
				b <= b;
				c <= c;
				d <= d;
				jishu_dis <= jishu_dis;
			end
			end
			
	end

	assign  licheng1= d*1+c*10+b*100+a*1000;
	 always@(*)
	 begin
	    case(s)
		0: digit=d;//  0: digit=jiaodu[3:0];//0: digit=d;
		1: digit=c;//  1: digit=jiaodu[7:4];//1: digit=c;
		2: digit=b;//  2: digit=jiaodu[9:8];//2: digit=b;
		3: digit=a;//  3: digit=1'b0;		 //3: digit=a;
		 default: digit=a;//default: digit=jiaodu[3:0];
		 endcase
	 end
	 
	 //7段解码器
	 always@(*)
	 begin
	    case(digit)
	    0: smg_duan=7'b0000001;
		 1: smg_duan=7'b1001111;
		 2: smg_duan=7'b0010010;
		 3: smg_duan=7'b0000110;
		 4: smg_duan=7'b1001100;
		 5: smg_duan=7'b0100100;
		 6: smg_duan=7'b0100000;
		 7: smg_duan=7'b0001111;
		 8: smg_duan=7'b0000000;
		 9: smg_duan=7'b0000100;
		 'ha: smg_duan=7'b0001000;
		 'hb: smg_duan=7'b1100000;
		 'hc: smg_duan=7'b0110001;
		 'hd: smg_duan=7'b1111110;
		 'he: smg_duan=7'b0110000;
		 'hf: smg_duan=7'b1111111;//空白
		 default:smg_duan=7'b1111111;
		 endcase
	 end
	 
	 //数字选择
	 always@(*)
	 begin
	    smg_wei=4'b1111;
		 if(aen[s]==1)
		    smg_wei[s]=0;
	 end
	 
	 //2位计数器
	 always@(posedge clk or negedge rst)
	 begin
	    if(rst==0) begin
		    s<=0;
			 dp<=1;
		 end	 
		 else if(cnt6==t1-1) begin
		   s<=s+1;
			if(s==1) begin
			   dp<=0;
			end
			else begin
			   dp<=1;
		   end
	    end
		 else begin
		   s<=s;
		 end
	 end



endmodule
