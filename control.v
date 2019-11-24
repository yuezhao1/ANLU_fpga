module control(clk,rst,led0,led1,dianji0,dianji2,dianji,led2,led3,flag1
    );
input clk;
input rst;
input led0;//z
input led1;//q
input flag1;
input [1:0]dianji0;
input [1:0]dianji2;
output  reg[1:0]dianji;
output reg led2;
output reg led3;
always@(posedge clk or negedge rst)
if(!rst)
dianji <= 2'd0;
else if(led0==0&&led1==0 && flag1 == 0)
begin
dianji <= dianji0;
led2 <= 1; 
led3 <= 0;
end
else if((led1==1||led0 == 1)&& flag1 ==1 )
begin
dianji <= dianji2;
led3  <= 1;
led2 <= 0;
end
else 
begin
 dianji <= dianji;
 led2 <= 0;
 led3 <= 0;
 end
 
 /*always@(posedge clk or negedge rst)
 if(!rst)
 begin
 led2 <= 0;
 led3 <= 0;
 end
 else if(dianji == dianji0)
 led2 <= 1;
 else if(dianji == dianji2)
 led3 <= 1;
 else 
 begin
 led2 <= 0;
 led3 <= 0;
 end*/
endmodule
