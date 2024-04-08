import controlP5.*;
import processing.net.*;
import ddf.minim.*;

Minim minim;
AudioPlayer player;
ControlP5 cp5;
Knob knob;
Slider velocitySlider;
Chart myChart;
Toggle toggle;
AudioPlayer go_sound;
AudioPlayer slow_sound;
AudioPlayer left_sound;
AudioPlayer right_sound;
AudioPlayer chacha;

PImage go_sign;
PImage slow_sign;
PImage left_sign;
PImage right_sign;
PImage dance;
int control_strategy = 1;
int tag_recognised = -1;
boolean pidMode = false;
boolean isRunning = false;
boolean theValue = false;
boolean obstacle_detected = false;
float ref_speed = 0; // units in m/s, speed sent to arduino
float maxVelocity = 10; // units in m/s,max val can be changed
float measured_speed = 0; // speed for gauge
float distance_traveled = 0;
float distance_from_object = 0;
float tag_mode = 2;
String IP = "192.168.4.1";
int PORT = 80;
JSONObject json;
PFont tnrFont;

Client myClient = new Client(this,IP,PORT);

/////////////
 //Set Up//
////////////


void setup() {
  
  size(1400, 600);
  
  minim= new Minim(this);
  
  go_sound = minim.loadFile("mk64_racestart.mp3");
  slow_sound = minim.loadFile("hey-hey-slow-down.mp3");
  left_sound = minim.loadFile("turnleft.mp3");
  right_sound = minim.loadFile("turnright.mp3");
  chacha = minim.loadFile("CHA-CHA-SLIDE.mp3");
 
  go_sign = loadImage("GO_SIGN.jpg");
  slow_sign = loadImage("SLOW_SIGN.jpg");
  left_sign = loadImage("LEFT_SIGN.jpg");
  right_sign = loadImage("RIGHT_SIGN.jpg");
  dance = loadImage("dance.jpeg");
  
    if (slow_sign == null) {
    println("Failed to load image. Please check the file path.");
  }
  
    if (go_sign == null) {
    println("Failed to load image. Please check the file path.");
  }
  
  //tag(tag_recognised);
  
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
     .setPosition(325, 50)
     .setSize(200, 100)
     .setFont(createFont("Times New Roman",30))
     .setColorForeground(color(255,0,0));
  
  // Velocity Slider
  velocitySlider = cp5.addSlider("Speed")
     .setPosition(50, 500)
     .setSize(325, 60)
     .setFont(createFont("Times New Roman",20))
     .setRange(0, maxVelocity) // Set the range of the slider
     .setValue(ref_speed);      // Set the initial value*/
    
  //Chart 
    myChart = cp5.addChart("dataflow")
               .setPosition(575, 175)
               .setSize(400, 300)
               .setRange(0, maxVelocity)
               .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               .setStrokeWeight(1.5)
               //.setResolution(1)
               .setColorCaptionLabel(color(40))
               ;
    
  myChart.addDataSet("incoming");
  myChart.setData("incoming", new float[100]);
  
  myChart.addDataSet("secondVariable");
  myChart.setData("secondVariable", new float[100]);
  
  myChart.setColors("incoming", color( 255, 0,0)); // Red for the first variable
  myChart.setColors("secondVariable", color(255, 255, 0)); // Blue for the second variable
  
// Manual Override Button
cp5.addButton("Manual Override")
    .setValue(0)
    .setPosition(575, 50)
    .setSize(300, 100)
    .setFont(createFont("Times New Roman", 30))
    .setColorForeground(color(255, 255, 0))
    .onRelease(new CallbackListener() {  // Add a callback listener for the button
      public void controlEvent(CallbackEvent event) {
        pidMode = !pidMode;  // Toggle the PID mode state
        setPID();
      }
    });
}

/////////////
  //Draw//
////////////

void draw() {
  background(0);
  
  

   drawLegend();
   
  // Display the current state of the buggy
  fill(255);
  textSize(25);
  text("Buggy is " + (isRunning ? "Running" : "Stopped") + ".", 50, 200);
  text("Buggy " + (obstacle_detected ? "sees an obstacle! and it is " + distance_from_object + "cm from the object" : "does not see an obstacle in its path") +".",50, 450);
  //text("Velocity: " + velocity, 50, 180);
  text("Buggy has travelled " + distance_traveled+" cm"+".", 50,300);

  text("Buggy has a measured speed of  " + measured_speed+" m/s"+".", 50,350);

  if (pidMode) {
    text("Manual Override is ON", 50, 400);  
  } else {
    text("Manual Override OFF", 50, 400);
  }

  text("Current mode of control: " + control_strategy , 50 ,250);

       if(frameCount % 60 == 0) {
    pingBuggy();
         myChart.push("secondVariable", ref_speed);
         myChart.push("incoming", measured_speed);
         //tag(tag_mode);
        
  }
  
  drawChartAxesWithTicks(575, 175, 400, 300, maxVelocity);
  
  tag(tag_recognised);


}


void drawLegend() {
  int legendX = 575 ; // Starting x position of the legend (aligned with the chart)
  int legendY = 300 + 175 + 20; // Starting y position, placed 20 pixels below the chart
  int legendWidth = 20; // Width of the legend color boxes
  int legendHeight = 10; // Height of the legend color boxes
  int spacing = 40; // Spacing between legend items
  
  // Draw the legend for the "incoming" dataset
  fill(255, 0, 0); // Red color for the first variable
  rect(legendX, legendY, legendWidth, legendHeight);
  fill(255); // Set text color to black
  text("Measured Speed", legendX + legendWidth + 5, legendY + legendHeight); // Position the text right to the color box

  // Draw the legend for the "secondVariable" dataset
  fill(255, 255, 0); // Yellow color for the second variable
  rect(legendX , legendY + 20, legendWidth, legendHeight);
  fill(255); // Set text color to black
  text("Reference Speed", legendX + legendWidth + 5, legendY + legendHeight + 20); // Position the text right to the color box
  
}

void drawChartAxesWithTicks(int chartX, int chartY, int chartWidth, int chartHeight, float maxValue) {
  stroke(255);
  int numTicks = 10;  // Number of ticks on the y-axis
  float tickSpacing = chartHeight / (float)numTicks;
  float valueSpacing = maxValue / (float)numTicks;

  // Draw y-axis
  line(chartX, chartY, chartX, chartY + chartHeight);

  // Draw x-axis
  line(chartX, chartY + chartHeight, chartX + chartWidth, chartY + chartHeight);

  // Draw ticks and labels on the y-axis
  for (int i = 0; i <= numTicks; i++) {
    float tickY = chartY + chartHeight - i * tickSpacing;
    line(chartX - 5, tickY, chartX, tickY);  // Draw tick
    fill(255);
    textSize(12);
    text(nf(i * valueSpacing, 0, 2), chartX - 40, tickY + 5);  // Draw tick label
  }
}

//////////////////////////////////
  // Functions For Networking//
/////////////////////////////////


void tag(float tag_mode){
  
  if (tag_mode == -1){
    textSize(25);
    text ("no tag found", 1100, 100);
  }
  
   if (tag_mode ==  3){
    image(go_sign, 1100,100);

    go_sound.play();
   }
   else if (tag_mode == 4){
    image(slow_sign,1100,100);
     
    slow_sound.play();
   }
   else if (tag_mode == 1){
     image(left_sign,1100,100);
     
     left_sound.play();
   }
   else if (tag_mode == 2){
     image(right_sign,1100,100);
     
     right_sound.play();
   }
   
      else if (tag_mode == 5){
     image(dance,1000,100);
     
     chacha.play();
   }
   
   
}

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

void setPID(){
  json = new JSONObject();
  json.setString("command", "setManualOverride");
  json.setBoolean("enabled", pidMode);
  myClient.write(json.toString());
  
}

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
  distance_from_object = distance_from_object*0.73;
  measured_speed = json.getFloat("measured_speed");
  measured_speed = measured_speed * 0.031;
  control_strategy = json.getInt("control_strategy");
  tag_recognised = json.getInt("tag_recognised");
  
  tag(tag_recognised);
  myChart.push("incoming", measured_speed);
}

////////////////////////////
 // Call Back Functions//
///////////////////////////

void controlEvent(ControlEvent event) {
  // Check if the event is from the "Speed" slider
  if (event.isFrom("Speed")) {
    // Update ref_speed with the value from the slider
    ref_speed = event.getValue();
    println("Updated ref_speed: " + ref_speed); // For debugging
  }
}

void Start(int value) {
  isRunning = true;
  startBuggy();
}

void Stop(int value) {
 isRunning = false;
  stopBuggy();
}

void Speed(float value) {
  setSpeed(value);
}

void icon(boolean theValue){
  println("PID is turned on", theValue);
}
