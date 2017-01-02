// --------------------------------------------
import codeanticode.syphon.*;
import controlP5.*;
import oscP5.*;
import netP5.*;
import punktiert.math.*;
import punktiert.physics.*;
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;
import org.processing.wiki.triangulate.*;

// --------------------------------------------
// Variables globales
PApplet applet;
/*
int screenWidth = 900;
 int screenHeight = 1600;
 */
int screenWidth = 600;
int screenHeight = 800;

float screenRatio = float(screenWidth) / float(screenHeight);

AppConfigs configs;
AppConfig config;

// --------------------------------------------
// link with FaceOSC software
FaceOSC faceOSC;

// --------------------------------------------
// for OSC
OscP5 oscP5;

// --------------------------------------------
// Scenes
SceneManager sceneManager = new SceneManager();

// --------------------------------------------
// Tools
ToolManager toolManager;
ControlP5 cp5;

// --------------------------------------------
// Timing
Timer timer;
float dt = 0.0;


// --------------------------------------------
// Debug
boolean __DEBUG__ = false;
boolean __DEBUG_IMAGES__ = true;
boolean __DEBUG_BOUNDINGS__ = true;
boolean __DEBUG_FEATURES__ = true;
boolean __DEBUG_INFOS__ = true;

String strDebugInfos = "";

// --------------------------------------------
void createConfigs()
{
  configs = new AppConfigs();
  configs.add( new AppConfig("dev", 600, 800, false, 30, 30) );
  configs.add( new AppConfig("mollat", 900, 1600, true, 0, 0) );
}


// --------------------------------------------
void settings () 
{
  println("-- settings()");
  println("- screenRatio = "+screenRatio);

  // Configs
  createConfigs();
  config = configs.select("dev");
  screenRatio = float(config.windowWidth) / float(config.windowHeight);
  
  if (config.bFullscreen)
  {
    fullScreen(P3D);
  }
  else
  {
    size(config.windowWidth, config.windowHeight, P3D);
  }


  PJOGL.profile = 1;
}

// --------------------------------------------
void setup() 
{
  // applet
  applet = this;

  // Libs
  Ani.init(this);

  // osc
  oscP5 = new OscP5(this, 8338);

  // Face osc
  faceOSC = new FaceOSC(this, oscP5);
  faceOSC.setup();

  // Scenes
  sceneManager.add( new SceneDebug("Debug") );
  sceneManager.add( new SceneThibaut("Thibaut_Maxime") );
  sceneManager.add( new SceneLea("Lea_Lea") );
  sceneManager.add( new SceneBenedicte("Benedicte_Alice") );
  sceneManager.add( new SceneEmily("Emily_Anna") );
  sceneManager.add( new SceneAlexis("Alexis_Max") );

  sceneManager.setup();
  sceneManager.select("Debug");

  // Init controls
  initControls(config.controlTabX, config.controlTabY);

  // Timing
  timer = new Timer();
}

// --------------------------------------------
public void draw() 
{    
  dt = timer.dt();

  // Update stuff
  boolean hasNewFrame = faceOSC.updateFrameSyphon();
  faceOSC.update();
  toolManager.update();

  // Draw
  background(0, 0, 0);
  hint(ENABLE_DEPTH_TEST);

  // Scene
  Scene sceneCurrent = sceneManager.getCurrent();
  if (sceneCurrent != null)
  {
    if (hasNewFrame)
      sceneCurrent.onNewFrame();
    sceneCurrent.update();
    sceneCurrent.draw();
  }

  hint(DISABLE_DEPTH_TEST);
  // Debug
  if (__DEBUG__)
  {
    if (__DEBUG_IMAGES__)    faceOSC.drawFaceImages();
    if (__DEBUG_BOUNDINGS__) faceOSC.drawFaceBounding();
    if (__DEBUG_FEATURES__)  faceOSC.drawFaceFeatures();
    if (__DEBUG_INFOS__)     drawDebugInfos();
  }

  // Controls
  cp5.draw();
}

// --------------------------------------------
void drawDebugInfos()
{
  pushStyle();
  pushMatrix();
  translate(toolManager.tabX, height-80-toolManager.tabY);
  fill(255, 200);
  strDebugInfos = "";
  if (sceneManager.getCurrent() != null)
    strDebugInfos += sceneManager.getCurrent().getDebugInfos()+"\n";
  strDebugInfos += "faceOSC.state="+faceOSC.getStateAsString()+ "\nfaceOsc.foundFactor = " + nf(faceOSC.face.getFoundFactor(), 1, 5) + "\nfaceOsc.stateTime="+nf(faceOSC.getStateTime(),1,1);
  text(strDebugInfos, 0, 0);
  popMatrix();
  popStyle();
}

// --------------------------------------------
void oscEvent(OscMessage m) 
{
  if (faceOSC != null)
    faceOSC.parseOSC(m);
}

// --------------------------------------------
void mouseMoved()
{
  Scene sceneCurrent = sceneManager.getCurrent();
  if (sceneCurrent !=null)
    sceneCurrent.mouseMoved();
}

// --------------------------------------------
void mousePressed()
{
  Scene sceneCurrent = sceneManager.getCurrent();
  if (sceneCurrent !=null)
    sceneCurrent.mousePressed();
}

// --------------------------------------------
void keyPressed()
{
  if (key == '0')        sceneManager.select("Debug");
  else if (key == '1')   sceneManager.select("Thibaut_Maxime");
  else if (key == '2')   sceneManager.select("Lea_Lea");
  else if (key == '3')   sceneManager.select("Benedicte_Alice");
  else if (key == '4')   sceneManager.select("Emily_Anna");
  else if (key == '5')   sceneManager.select("Alexis_Max");
  else
  {
    Scene sceneCurrent = sceneManager.getCurrent();
    if (sceneCurrent !=null)
      sceneCurrent.keyPressed();
  }
}