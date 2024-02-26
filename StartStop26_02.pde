import processing.net.*;

import controlP5.*;
import processing.net.*;

ControlP5 cp5;
boolean isRunning = false;
float velocity = 0.0;
float maxVelocity = 10.0; // Maximum velocity of the buggy
String IP = "192.168.4.1";
int PORT = 80;

Client myClient = new Client(this,IP,PORT);

void startBuggy() {
  myClient.write("start\n");
}

void stopBuggy() {
  myClient.write("stop\n");
}

//int currentUpdate = ;
boolean obstacle_detected = false;

void pingBuggy() {
  int update = -1;
  myClient.write("ping\n");
  update = myClient.read();
  switch(update) {
    case 1:
      obstacle_detected = true;
      break;
    case 0:
      obstacle_detected = false;
      break;
    default:
      println("WiFi's screwed!!!");
  }
  //println(update);
}

void setup() {
  
  size(800, 600);
  cp5 = new ControlP5(this);
  
  // Start Button
  cp5.addButton("Start")
     .setValue(0)
     .setPosition(200, 200)
     .setSize(200, 100)
     .setFont(createFont("Times New Roman",15)); 
     
  cp5.addButton("Stop")
     .setValue(0)
     .setPosition(500, 200)
     .setSize(200, 100)
     .setFont(createFont("Times New Roman",15));
  
  // Velocity Slider
  /*cp5.addSlider("setVelocity")
     .setPosition(500, 200)
     .setSize(200, 40)
     .setRange(0, maxVelocity) // Set the range of the slider
     .setValue(velocity);      // Set the initial value*/
     
}

void draw() {
  background(255);
  
  // Display the current state of the buggy
  fill(0);
  textSize(20);
  text("Buggy is " + (isRunning ? "Running" : "Stopped"), 50, 150);
  text("Buggy " + (obstacle_detected ? "sees obstacle!" : "does not see shit!"), 50, 400);
  //text("Velocity: " + velocity, 50, 180);
  if(frameCount % 60 == 0) {
    pingBuggy();
  }
  
}

// Callback function for the start-stop button
void Start(int value) {
  isRunning = true;
  startBuggy();
}

void Stop(int value) {
 isRunning = false;
  stopBuggy();
}


/*// Callback function for the velocity slider
void setVelocity(float value) {
  velocity = value;
}*/
