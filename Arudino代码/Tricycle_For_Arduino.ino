#include <Servo.h>
#include <PinChangeInt.h>    //外部中断
#include <MsTimer2.h>        //定时中断
//#include <SoftwareSerial.h>
//SoftwareSerial Serial(11, A2); // RX, TX
/////////TB6612驱动引脚////
//#define AIN1 11
//#define AIN2 5
#define AIN1 10
#define AIN2 9
#define BIN1 6
#define BIN2 3
#define SERVO 9
/////////编码器引脚////////
#define ENCODER_L 8  //编码器采集引脚 每路2个 共4个
#define DIRECTION_L 4
#define ENCODER_R 7
#define DIRECTION_R 2
#define key1 12
#define key2 13
/////////按键引脚////////
//#define KEY 18
//#define T 0.156f
//#define L 0.1445f
//#define pi 3.1415926

volatile long Velocity_L, Velocity_R ;   //左右轮编码器数据
int Velocity_Left, Velocity_Right = 0 ;   //左右轮速度
float Velocity_KP =10 , Velocity_KI = 1, Velocity = 0, turn =0;
unsigned char Flag_Stop = 0; //停止标志位
float Target_A, Target_B;

int sensorValue = 0;

void (* resetFunc) (void) = 0;// Reset func

//心率*************************************************

#include <Wire.h>
#include "MAX30105.h"

#include "heartRate.h"

MAX30105 particleSensor;

const byte RATE_SIZE = 4; //Increase this for more averaging. 4 is good.
byte rates[RATE_SIZE]; //Array of heart rates
byte rateSpot = 0;
long lastBeat = 0; //Time at which the last beat occurred

float beatsPerMinute;
int beatAvg;

//****************************************************

void get_key(void)
{
  if(digitalRead(key1) == HIGH && digitalRead(key2) == LOW)
    {turn =2 ;Velocity=-7;}
  else if(digitalRead(key1) == LOW && digitalRead(key2) == HIGH)
    {turn = -2;Velocity=-7;}
  else if(digitalRead(key1) == HIGH && digitalRead(key2) == HIGH)
    {turn = 0;Velocity=-7;}
  else if(digitalRead(key1) == LOW && digitalRead(key2) == LOW)
    {turn = 0;Velocity=0;}
}

/**************************************************************************
函数功能：赋值给PWM寄存器 作者：平衡小车之家
入口参数：PWM
**************************************************************************/
void Set_Pwm(int motora, int motorb) {
  if (motora >= 0)       analogWrite(AIN1, motora), digitalWrite(AIN2, LOW); //赋值给PWM寄存器
  else                 digitalWrite(AIN2, HIGH), analogWrite(AIN1, 255 + motora); //赋值给PWM寄存器

  if (motorb >= 0)        digitalWrite(BIN2, LOW), analogWrite(BIN1, motorb); //赋值给PWM寄存器
  else                  analogWrite(BIN1,255 + motorb), digitalWrite(BIN2, HIGH); //赋值给PWM寄存器
}
/**************************************************************************
函数功能：异常关闭电机
入口参数：电压
返回  值：1：异常  0：正常
/**************************************************************************/
unsigned char  Turn_Off() {
  byte temp;
  if (Flag_Stop == 1) { //Flag_Stop置1或者电压太低关闭电机
    temp = 1;
    digitalWrite(AIN1, LOW);  //电机驱动的电平控制
    digitalWrite(AIN2, LOW);  //电机驱动的电平控制
    digitalWrite(BIN1, LOW);  //电机驱动的电平控制
    digitalWrite(BIN2, LOW);  //电机驱动的电平控制
  }
  else      temp = 0;
  return temp;
}
/**************************************************************************
函数功能：小车运动数学模型
入口参数：速度和转角
//**************************************************************************/
void Kinematic_Analysis(float velocity, float turn) {
    Target_A=velocity+turn; 
    Target_B=velocity-turn;                                                                          //后轮差速
}

/**************************************************************************
函数功能：增量PI控制器
入口参数：编码器测量值，目标速度
返回  值：电机PWM
根据增量式离散PID公式
pwm+=Kp[e（k）-e(k-1)]+Ki*e(k)+Kd[e(k)-2e(k-1)+e(k-2)]
e(k)代表本次偏差
e(k-1)代表上一次的偏差  以此类推
pwm代表增量输出
在我们的速度控制闭环系统里面，只使用PI控制
pwm+=Kp[e（k）-e(k-1)]+Ki*e(k)
**************************************************************************/
int Incremental_PI_A (int Encoder,int Target)
{   
   static float Bias,Pwm,Last_bias;
   Bias=Encoder-Target;                                  //计算偏差
   Pwm+=Velocity_KP*(Bias-Last_bias)+Velocity_KI*Bias;   //增量式PI控制器
   if(Pwm>255)Pwm=255;                                 //限幅
   if(Pwm<-255)Pwm=-255;                                 //限幅
   Last_bias=Bias;                                       //保存上一次偏差 
   return Pwm;                                           //增量输出
}
int Incremental_PI_B (int Encoder,int Target)
{   
   static float Bias,Pwm,Last_bias;
   Bias=Encoder-Target;                                  //计算偏差
   Pwm+=Velocity_KP*(Bias-Last_bias)+Velocity_KI*Bias;   //增量式PI控制器
   if(Pwm>255)Pwm=255;                                 //限幅
   if(Pwm<-255)Pwm=-255;                                 //限幅  
   Last_bias=Bias;                                       //保存上一次偏差 
   return Pwm;                                           //增量输出
}

/*********函数功能：5ms控制函数 核心代码 作者：平衡小车之家*******/
void control() {
 int Temp, Temp2, Motora, Motorb; //临时变量
  static unsigned char Position_Count,Voltage_Count;  //位置控制分频用的变量
  sei();//全局中断开启
  Velocity_Left = Velocity_L;    Velocity_L = 0;  //读取左轮编码器数据，并清零，这就是通过M法测速（单位时间内的脉冲数）得到速度。
  Velocity_Right = Velocity_R;    Velocity_R = 0; //读取右轮编码器数据，并清零
  Kinematic_Analysis(Velocity,turn);                                   //小车运动学分析   
  Motora = Incremental_PI_A(Target_A, Velocity_Left); //===速度PI控制器
  Motorb = Incremental_PI_B(Target_B, Velocity_Right); //===速度PI控制器
  Set_Pwm(Motora, Motorb); //如果不存在异常，使能电机
  
  get_key();

  //Serial.println("Velocity_Left:");
  //Serial.print(Velocity_Left);
  //Serial.print(",");
  //Serial.println("Velocity_Right:");
  //Serial.println(Velocity_Right);
 if (Temp == 1)Flag_Stop = !Flag_Stop;
}

/***********函数功能：初始化 相当于STM32里面的Main函数 作者：平衡小车之家************/
void setup()   {
  char error;
  pinMode(AIN1, OUTPUT);          //电机控制引脚
  pinMode(AIN2, OUTPUT);          //电机控制引脚，
  pinMode(BIN1, OUTPUT);          //电机速度控制引脚
  pinMode(BIN2, OUTPUT);          //电机速度控制引脚

  pinMode(ENCODER_L, INPUT);       //编码器引脚
  pinMode(DIRECTION_L, INPUT);       //编码器引脚
  pinMode(ENCODER_R, INPUT);        //编码器引脚
  pinMode(DIRECTION_R, INPUT);       //编码器引脚
  
  pinMode(key1, INPUT);
  pinMode(key2, INPUT);
  
  delay(200);                      //延时等待初始化完成
  attachInterrupt(0, READ_ENCODER_R, CHANGE);           //开启外部中断 编码器接口1
  attachPinChangeInterrupt(4, READ_ENCODER_L, CHANGE);  //开启外部中断 编码器接口2

  MsTimer2::set(10, control);       //使用Timer2设置5ms定时中断
  MsTimer2::start();               //中断使能

  
  Serial.begin(9600);           //开启串口
//  Serial.begin(9600);

  //心率*************************************************

  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) //Use default I2C port, 400kHz speed
  {
    Serial.println("MAX30105 was not found. Please check wiring/power. ");
    while (1);
  }
  Serial.println("Place your index finger on the sensor with steady pressure.");

  particleSensor.setup(); //Configure sensor with default settings
  particleSensor.setPulseAmplitudeRed(0x0A); //Turn Red LED to low to indicate sensor is running
  particleSensor.setPulseAmplitudeGreen(0); //Turn off Green LED
  
  //心率*************************************************
}

/******函数功能：主循环程序体*******/
void loop(){
     //Serial.print("Left: ");
     //Serial.println(Velocity_Left);
    // Serial.print("Right: ");
    // Serial.println(Velocity_Right);
    // delay(500);
  sensorValue = analogRead(A0);
  Serial.print("ABC");
  Serial.print(sensorValue);
//心率*************************************************

long irValue = particleSensor.getIR();

  if (checkForBeat(irValue) == true)
  {
    //We sensed a beat!
    long delta = millis() - lastBeat;
    lastBeat = millis();

    beatsPerMinute = 60 / (delta / 1000.0);

    if (beatsPerMinute < 255 && beatsPerMinute > 20)
    {
      rates[rateSpot++] = (byte)beatsPerMinute; //Store this reading in the array
      rateSpot %= RATE_SIZE; //Wrap variable

      //Take average of readings
      beatAvg = 0;
      for (byte x = 0 ; x < RATE_SIZE ; x++)
        beatAvg += rates[x];
      beatAvg /= RATE_SIZE;
    }
  }
  //Serial.print("IR=");
//Serial.print(irValue);
  Serial.print("BPM=");
 // Serial.print(beatsPerMinute);
 // Serial.print(", Avg BPM=");
  Serial.print(beatAvg);

 // if (irValue < 50000)
 //   Serial.print(" No finger?");
  
 // Serial.println();

//心率*************************************************
}

/*****函数功能：外部中断读取编码器数据，具有二倍频功能 注意外部中断是跳变沿触发********/
void READ_ENCODER_L() {
  if (digitalRead(ENCODER_L) == LOW) {     //如果是下降沿触发的中断
    if (digitalRead(DIRECTION_L) == LOW)      Velocity_L--;  //根据另外一相电平判定方向
    else      Velocity_L++;
  }
  else {     //如果是上升沿触发的中断
    if (digitalRead(DIRECTION_L) == LOW)      Velocity_L++; //根据另外一相电平判定方向
    else     Velocity_L--;
  }
}

/*****函数功能：外部中断读取编码器数据，具有二倍频功能 注意外部中断是跳变沿触发********/
void READ_ENCODER_R() {
  if (digitalRead(ENCODER_R) == LOW) { //如果是下降沿触发的中断
    if (digitalRead(DIRECTION_R) == LOW)      Velocity_R++;//根据另外一相电平判定方向
    else      Velocity_R--;
  }
  else {   //如果是上升沿触发的中断
    if (digitalRead(DIRECTION_R) == LOW)      Velocity_R--; //根据另外一相电平判定方向
    else     Velocity_R++;
  }
}
