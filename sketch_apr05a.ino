//#include <Keyboard.h>

// defines pins numbers
const int trigPin = 13;
const int echoPin = 12;
const int led = 10;
const int pushbutton_0=2;
const int pushbutton_1=3;

char ch;

// defines variables
long duration;
int distance;

void setup() {
pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
pinMode(echoPin, INPUT);

pinMode(led,OUTPUT);// Sets the echoPin as an Input
Serial.begin(9600); // Starts the serial communication
pinMode(pushbutton_0,OUTPUT);
pinMode(pushbutton_1,OUTPUT);

}

void loop() {
// Clears the trigPin
digitalWrite(trigPin, LOW);
delayMicroseconds(2);

// Sets the trigPin on HIGH state for 10 micro seconds
digitalWrite(trigPin, HIGH);
delayMicroseconds(10);
digitalWrite(trigPin, LOW);

// Reads the echoPin, returns the sound wave travel time in microseconds
duration = pulseIn(echoPin, HIGH);

// Calculating the distance
distance= duration*0.034/2;

// Prints the distance on the Serial Monitor



if(distance<=4)
{
  digitalWrite(led,HIGH);
  //Serial.println("1");
  
}
else
{
  digitalWrite(led,LOW);
  //Serial.println("0");
}


if (Serial.available() > 0) 
{
  ch=Serial.read();
  Serial.println(ch);
  if(ch=='c')
  {
    digitalWrite(pushbutton_0,HIGH);
    delay(1000);
    digitalWrite(pushbutton_0,LOW);
  }

  if(ch=='d')
  {
    digitalWrite(pushbutton_1,HIGH);
    delay(1000);
    digitalWrite(pushbutton_1,LOW);
  }
}
//delay(1000);
}
