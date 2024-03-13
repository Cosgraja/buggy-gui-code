import processing.net.*;

import controlP5.*;
import processing.net.*;

ControlP5 cp5;
Knob knob;
boolean isRunning = false;
float velocity = 0.0;
float maxVelocity = 10.0; // Maximum velocity of the buggy
float distance_traveled = 0;
float dist_f_ob = 0;
String IP = "192.168.4.1";
int PORT = 80;
JSONObject json;

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
  json = new JSONObject();

  myClient.write("ping\n");
  json = parseJSONObject(myClient.readString());
  if(json == null) {
    println("WiFi's Screwed!!");
    return;
  }
  println(json);
  obstacle_detected = json.getBoolean("obstacle_detected");
  distance_traveled = json.getFloat("distance_traveled");
  dist_f_ob = json.getFloat("dist_f_ob");
  velocity = json.getFloat("velocity");
  //println(update);
}

PFont tnrFont;

void setup() {
  
  size(1000, 600);
  
  tnrFont = createFont("Times New Roman",40);
  textFont(tnrFont);
  cp5 = new ControlP5(this);
  
  // Start Button
  cp5.addButton("Start")
     .setValue(0)
     .setPosition(50, 50)
     .setSize(200, 100)
     .setFont(createFont("Times New Roman",30))
     .setColorForeground(color(0,255,0));
     
  cp5.addButton("Stop")
     .setValue(0)
     .setPosition(350, 50)
     .setSize(200, 100)
     .setFont(createFont("Times New Roman",30))
     .setColorForeground(color(255,0,0));
  
  // Velocity Slider
  cp5.addSlider("setVelocity")
     .setPosition(50, 400)
     .setSize(325, 60)
     .setFont(createFont("Times New Roman",30))
     .setRange(0, maxVelocity) // Set the range of the slider
     .setValue(velocity);      // Set the initial value*/
     
  // Vecloicty reader
   knob = cp5.addKnob("speed")
      .setRange(0,10)
      .setValue(velocity)
      .setFont(createFont("Times New Roman",30))
      .setPosition(700,175)
      .setRadius(125)
      .setNumberOfTickMarks(10)
      .setTickMarkLength(4)
      .snapToTickMarks(true)
      .setColorForeground(color(255))
      //.setColorBackground(color(0, 160, 100))
      .setColorActive(color(255,0,0))
      .setDragDirection(Knob.HORIZONTAL);
     
}

void draw() {
  background(0);
  
  // Display the current state of the buggy
  fill(255);
  textSize(30);
  text("Buggy is " + (isRunning ? "Running" : "Stopped") + ".", 50, 250);
  text("Buggy " + (obstacle_detected ? "sees an obstacle! and it is a distance" + dist_f_ob + "cm" : "does not see an obstacle in its path") +".",50, 300);
  //text("Velocity: " + velocity, 50, 180);
  text("Buggy has travelled " + distance_traveled+" cm"+".", 50,350);
  if(frameCount % 60 == 0) {
    pingBuggy();
  }
  
}

void setVelocity(float value) {
  // Update the value of the knob when the slider value changes
  knob.setValue(value);
}
