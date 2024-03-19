import processing.net.*;
import controlP5.*;
import processing.net.*;

ControlP5 cp5;
Knob knob;
Slider velocitySlider;
boolean isRunning = false;
float ref_speed = 1; // units in m/s, speed sent to arduino
float maxVelocity = 5; // units in m/s,max val can be changed
float measured_speed = 0; // speed for gauge
float distance_traveled = 0;
float distance_from_object = 0;
String IP = "192.168.4.1";
int PORT = 80;
JSONObject json;

Client myClient = new Client(this,IP,PORT);

void startBuggy() {
  json = new JSONObject();
  json.setString("command", "start");
  myClient.write(json.toString());
}

void stopBuggy() {
  json = new JSONObject();
  json.setString("command", "stop");
  myClient.write(json.toString());
}

void setSpeed(float ref_speed){
  json = new JSONObject();
  json.setString("command", "setSpeed");
  json.setFloat("speed",ref_speed);
  myClient.write(json.toString());
}


boolean obstacle_detected = false;

void pingBuggy() {
  json = new JSONObject();

  json.setString("command","ping");
  myClient.write(json.toString());
  
  json = parseJSONObject(myClient.readString());
  if(json == null) {
    println("WiFi's Screwed!!");
    return;
  }
  println(json);
  obstacle_detected = json.getBoolean("obstacle_detected");
  distance_traveled = json.getFloat("distance_traveled");
  distance_from_object = json.getFloat("distance_from_object");
  measured_speed = json.getFloat("measured_speed");
  //println(update);

updateKnobValue()
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
     
  // Stop Button   
  cp5.addButton("Stop")
     .setValue(0)
     .setPosition(350, 50)
     .setSize(200, 100)
     .setFont(createFont("Times New Roman",30))
     .setColorForeground(color(255,0,0));
  
  // Velocity Slider
  velocitySlider = cp5.addSlider("Speed")
     .setPosition(50, 450)
     .setSize(325, 60)
     .setFont(createFont("Times New Roman",20))
     .setRange(0, 1) // Set the range of the slider
     .setValue(ref_speed);      // Set the initial value*/
     
  // Vecloicty reader
   knob = cp5.addKnob("measured speed (m/s)")
      .setRange(0,maxVelocity)
      .setValue(measured_speed)
      .setFont(createFont("Times New Roman",20))
      .setPosition(650,150)
      .setRadius(125)
      .setNumberOfTickMarks(10)
      .setTickMarkLength(4)
      .snapToTickMarks(true)
      .setColorForeground(color(0,255,0))
      .setColorActive(color(0,255,0));
     
}

void draw() {
  background(0);
  
  // Display the current state of the buggy
  fill(255);
  textSize(30);
  text("Buggy is " + (isRunning ? "Running" : "Stopped") + ".", 50, 250);
  text("Buggy " + (obstacle_detected ? "sees an obstacle! and it is a distance " + distance_from_object + "cm" : "does not see an obstacle in its path") +".",50, 300);
  //text("Velocity: " + velocity, 50, 180);
  text("Buggy has travelled " + distance_traveled+" cm"+".", 50,350);
  if(frameCount % 60 == 0) {
    pingBuggy();
  }

}


void updateKnobValue() {
  // Update the value of the knob based on measured_speed
  knob.setValue(measured_speed);
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

// Callback function for the velocity slider


void Speed(float value) {
  setSpeed(value);
}
