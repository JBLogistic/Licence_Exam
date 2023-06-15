#include <SoftwareSerial.h>
#include <Adafruit_AMG88xx.h>
Adafruit_AMG88xx amg;

SoftwareSerial bluetooth(10, 11); // RX, TX

#define echoPin1 2
#define trigPin1 3
#define echoPin2 4
#define trigPin2 5
#define echoPin3 6
#define trigPin3 7
#define motorPin1 8
#define motorPin2 9
#define ARRAYSIZE = 64
float sensorArray = [  23.1, 23.2, 23.4, 23.6, 23.7, 23.8, 23.9, 24.0,
                23.2, 23.4, 23.6, 23.8, 24.0, 24.1, 24.2, 24.3,
                23.4, 23.6, 23.8, 24.0, 24.2, 24.3, 24.4, 24.5,
                23.6, 23.8, 24.0, 24.2, 24.4, 24.5, 24.6, 24.7,
                23.7, 24.0, 24.2, 24.4, 24.5, 24.6, 24.7, 24.8,
                23.8, 24.1, 24.3, 24.5, 24.6, 24.7, 24.8, 24.9,
                23.9, 24.2, 24.4, 24.6, 24.7, 24.8, 24.9, 25.0,
                24.0, 24.3, 24.5, 24.7, 24.8, 24.9, 25.0, 25.1];


void setup() {
  Serial.begin(9600);
  pinMode(trigPin1, OUTPUT);
  pinMode(echoPin1, INPUT);
  pinMode(trigPin2, OUTPUT);
  pinMode(echoPin2, INPUT);
  pinMode(trigPin3, OUTPUT);
  pinMode(echoPin3, INPUT);
  pinMode(motorPin1, OUTPUT);
  pinMode(motorPin2, OUTPUT);
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, LOW);
  //hc-05
  bluetooth.begin(9600);
  
}

void loop() {
  digitalWrite(motorPin2, HIGH);
  digitalWrite(motorPin1, HIGH);
  int distanceForward = Distance(trigPin1,echoPin1);
  int distanceLeft =10;// Distance(trigPin2,echoPin2);
  int distanceRight =11;// Distance(trigPin3,echoPin3);
  for (int i = 0; i < ARRAYSIZE; i++) {
    bluetooth.print(sensorArray[i]);
    if (i < ARRAYSIZE - 1) {
      bluetooth.print(",");
    }
  }
  bluetooth.println();
  Serial.print(distanceForward);
  if(distanceForward >= 20){
     movementForward(motorPin1,motorPin2); 
     return;
   }
   else{
      if(distanceLeft > distanceRight){
         movementLeft(motorPin1,motorPin2);
         delay(250);
         return;
     }
     else{
         movementRight(motorPin1,motorPin2);
         delay(250);
         return;
      }
   }
}
int Distance(int trigPin, int echoPin){
  int distance;
  long duration;
     // Clears the trigPin condition
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(2);
  // Sets the trigPin HIGH (ACTIVE) for 10 microseconds
  digitalWrite(trigPin, LOW);
  delayMicroseconds(10);
  digitalWrite(trigPin, HIGH);
  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echoPin, LOW);
  // Calculating the distance
  distance = duration * 0.034 / 2;
  return distance;
}
void movementForward(int motorPinA, int motorPinB){
     digitalWrite(motorPinA, LOW);
     digitalWrite(motorPinB, LOW);
}
void movementRight(int motorPinA, int motorPinB){
     digitalWrite(motorPinA, HIGH);
     digitalWrite(motorPinB, LOW);
     delay(250);
     digitalWrite(motorPinA, LOW);
     digitalWrite(motorPinB, LOW);
}
void movementLeft(int motorPinA, int motorPinB){
     digitalWrite(motorPinA, LOW);
     digitalWrite(motorPinB, HIGH);
     delay(250);
     digitalWrite(motorPinA, LOW);
     digitalWrite(motorPinB, LOW);
}
