// Chris Finck 2016

class Game
{
   private boolean m_isPaused = false;
   boolean IsPaused() { return m_isPaused;}
   void SetPaused(boolean paused) { m_isPaused = paused;}
}

class Box
{
  float x = 0;
  float y = 0;
  float w = 0;
  float h = 0;
  
  Box(float tX, float tY, float tW, float tH)
  {
    x = tX;
    y = tY;
    w = tW;
    h = tH;
  }
}

class Physics
{
  float friction = 0.25;
  
  float ApplyFriction(float s)
  {
    if (s == 0.0)
    {
      return 0.0;
    }
    if (s > 0.0)
    {
      return max(s - friction, 0.0);
    }
    if (s < 0.0)
    {
      return min(s + friction, 0.0);
    }
      
    return 0.0;
  }
  
  boolean CheckCollision(Box a, Box b)
  {
    float aLeft = a.x;
    float aRight = a.x + a.w;
    float aTop = a.y;
    float aBottom =  a.y + a.h;
    
    float bLeft = b.x;
    float bRight = b.x + b.w;
    float bTop = b.y;
    float bBottom =  b.y + b.h;

    if(aRight < bLeft)
      return false;
    if(aLeft > bRight)
      return false;
    if(aTop > bBottom)
      return false;
    if(aBottom < bTop)
      return false;
    
    return true;

/*
    // Check collision on the left for a
    println((aLeft > bLeft) + ", " + (aLeft < bRight) + ", " + (aTop > bTop && aTop < bBottom) + " or " + (aBottom > bTop && aBottom < bBottom));
    if (aLeft >= bLeft && aLeft <= bRight && ((aTop >= bTop && aTop <= bBottom) || (aBottom >= bTop && aBottom <= bBottom)))
      return true;
    // Check collision on the right for a
    if (aRight < bRight && aRight > bLeft && ((aTop > bTop && aTop < bBottom) || (aBottom > bTop && aBottom < bBottom)))
      return true;
    
    return false;
*/
  }
}
Physics physics;

class BaseObject
{
  float x = 0.0;
  float y = 0.0;
  int w = 0;
  int h = 0;
  float hSpeed = 0.0;
  float vSpeed = 0.0;
  float hAccel = 0.0;
  float vAccel = 0.0;
  float maxHSpeed = -1.0;
  float maxVSpeed = -1.0;
  private PImage tex;
  
  float GetX() { return x;}
  float GetY() { return y;}
  
  Box GetBox() { return new Box(x, y, w, h);}
  
  void SetTexture(PImage t)
  {
    tex = t;
    w = tex.width;
    h = tex.height;
  }
  PImage GetTexture() {return tex;}
  
  void SetPos(float fX, float fY)
  {
    x = fX;
    y = fY;
  }
  
  void Draw()
  {
   if (tex.width != -1 && tex.height != -1)
   {
     imageMode(CORNER);
     image(tex, x, y);
   }
  }
  
  float[] ThinkMove()
  {
    float[] thinkPos = new float[2];
    thinkPos[0] = x;
    thinkPos[1] = y;
    //float thinkHSpeed = hSpeed;
    //if (maxHSpeed > 0)
    //{
    //  if (thinkHSpeed > maxHSpeed)
    //  {
    //    thinkHSpeed = maxHSpeed;
    //  }
    //  else if (thinkHSpeed < -maxHSpeed)
    //  {
    //    thinkHSpeed = -maxHSpeed;
    //  }
    //}
    hSpeed = physics.ApplyFriction(hSpeed);
    vSpeed = physics.ApplyFriction(vSpeed);
    thinkPos[0] = thinkPos[0] + hSpeed; 
    thinkPos[1] = thinkPos[1] + vSpeed;
    return thinkPos;
  }
  
  void Update()
  {
    // Cap speed
    if (maxHSpeed > 0)
    {
      if (hSpeed > maxHSpeed)
      {
        hSpeed = maxHSpeed;
      }
      else if (hSpeed < -maxHSpeed)
      {
        hSpeed = -maxHSpeed;
      }
    }
    if (maxVSpeed > 0)
    {
      if (vSpeed > maxVSpeed)
      {
        vSpeed = maxVSpeed;
      }
      else if (vSpeed < -maxVSpeed)
      {
        vSpeed = -maxVSpeed;
      }
    }
    
    // Check for collisions on player
    float[] thinkPos = ThinkMove();
    for (BaseObject tempObj : OBJECTS)
    {
      if (tempObj != this && physics.CheckCollision(new Box(thinkPos[0], thinkPos[1], w, h), tempObj.GetBox()))
      {
        println("Collision!");
        float[] tempPos = new float[2];
        
        boolean hCollision = false;
        boolean vCollision = false;
        if (physics.CheckCollision(new Box(thinkPos[0], y, w, h), tempObj.GetBox()))
          hCollision = true;
        else if (physics.CheckCollision(new Box(x, thinkPos[1], w, h), tempObj.GetBox()))
          vCollision = true;
        else
        {
          hCollision = true;
          vCollision = true;
        }
        
        if (hCollision)
        {
          // HORIZONTAL COLLISIONS
          int hDirection;
          if (abs(hSpeed) == hSpeed)
            hDirection = 1;
          else if (abs(hSpeed) != hSpeed)
            hDirection = -1;
          else
            hDirection = 0;
          hSpeed = 0;
          arrayCopy(thinkPos, tempPos);
          if (tempPos[0] > x)
          {
            while (tempPos[0] > x)
            {
              println("Tiny Collision!");
              if(physics.CheckCollision(new Box(tempPos[0], thinkPos[1], w, h), tempObj.GetBox()))
                tempPos[0]--;
              else
                break;
            }
            if (tempPos[0] < x)
              tempPos[0] = x;
          }
          else
          {
            while (tempPos[0] < x)
            {
              println("Tiny Collision!");
              if(physics.CheckCollision(new Box(tempPos[0], thinkPos[1], w, h), tempObj.GetBox()))
                tempPos[0]++;
              else
                break;
            }
            if (tempPos[0] > x)
              tempPos[0] = x;
          }
          arrayCopy(tempPos, thinkPos);
          // Adjust stopping position of object
          if (hDirection == 1)
            thinkPos[0] = floor(thinkPos[0]);
          else if (hDirection == -1)
            thinkPos[0] = ceil(thinkPos[0]);
        }
        
        if (vCollision)
        {
          // VERTICAL COLLISIONS  
          int vDirection = 0;
          if (abs(vSpeed) == vSpeed)
            vDirection = 1;
          else if (abs(vSpeed) != vSpeed)
            vDirection = -1;
          else
            vDirection = 0;
          vSpeed = 0;
          arrayCopy(thinkPos, tempPos);
          if (tempPos[1] > y)
          {
            while (tempPos[1] > y)
            {
              println("Tiny Collision!");
              if(physics.CheckCollision(new Box(thinkPos[0], tempPos[1], w, h), tempObj.GetBox()))
                tempPos[1]--;
              else
                break;
            }
            if (tempPos[1] < y)
              tempPos[1] = y;
          }
          else
          {
            while (tempPos[1] < y)
            {
              println("Tiny Collision!");
              if(physics.CheckCollision(new Box(thinkPos[0], tempPos[1], w, h), tempObj.GetBox()))
                tempPos[1]++;
              else
                break;
            }
            if (tempPos[1] > y)
              tempPos[1] = y;
          }
          arrayCopy(tempPos, thinkPos);
          // Adjust stopping position of object
          if (vDirection == 1)
            thinkPos[1] = floor(thinkPos[1]);
          else if (vDirection == -1)
            thinkPos[1] = ceil(thinkPos[1]);
        }
      }
    }
    SetPos(thinkPos[0], thinkPos[1]);
  }
}

class Player extends BaseObject
{
  float jumpSpeed = 10.0;
  
  void MoveLeft()
  {
      hSpeed = hSpeed - hAccel;
  }
  
  void MoveRight()
  {
    hSpeed = hSpeed + hAccel;
  }
  
  void MoveUp()
  {
    vSpeed = vSpeed - vAccel;
  }
  
  void MoveDown()
  {
    vSpeed = vSpeed + vAccel;
  }
  
  void Draw()
  {
    stroke(255, 0, 0);
    rectMode(CORNER);
    rect(x, y, w, h);
  }
  
  void Update()
  {
    super.Update();
  }
}

class Wall extends BaseObject
{
  void Draw()
  {
    stroke(0);
    rectMode(CORNER);
    rect(x, y, w, h);
  }
}

class Key
{
  int kCode = -1;
  boolean wasPressed = false;
  boolean pressed = false;
  boolean held = false;
  boolean released = false;
  
  String name = "";
  String pFunc = "";
  String hFunc = "";
  String rFunc = "";
  
  Key()
  {
    kCode = -1;
  }
  
  Key(int code)
  {
    kCode = code;
  }
  
  void SetKey(String n, int c)
  {
    name = n;
    kCode = c;
  }
}



void ParseFunction(String function)
{
  switch (function)
  {
    case "MoveLeft":
      player.MoveLeft();
      break;
    case "MoveRight":
      player.MoveRight();
      break;
    case "MoveUp":
      player.MoveUp();
      break;
    case "MoveDown":
      player.MoveDown();
      break;
    case "DebugResetPos":
      player.SetPos(width / 2, height / 2);
      player.hSpeed = 0;
      player.vSpeed = 0;
      break;
    default:
      break;
  }
}

void keyPressed() {
  if (keyCode >= 0 && keyCode < KEYS.length)
  {
    KEYS[keyCode].pressed = KEYS[keyCode].wasPressed ? false : true;
    KEYS[keyCode].held = true;
    KEYS[keyCode].wasPressed = true;
  }
}

void keyReleased() {
  if (keyCode >= 0 && keyCode < KEYS.length)
  {
    KEYS[keyCode].held = false;
    KEYS[keyCode].wasPressed = false;
    KEYS[keyCode].released = true;
  }
}



// Declare globally
Key[] KEYS;
BaseObject[] OBJECTS;
Player player;
PImage img_ball;
Wall wall;
Wall wall2;
Wall floor;

void setup()
{
  size(640, 480);
  background(255);
  
  rectMode(CORNER);
  imageMode(CORNER);
  
  KEYS = new Key[128];
  for (int i = 0; i < KEYS.length; i++)
  {
    KEYS[i] = new Key();
    //println(KEYS[i].pressed + " " + KEYS[i].held + " " + KEYS[i].released);
  }
  
  // Set up keys maybe???
  //KEYS[65].SetKey("a", 65);
  //KEYS[68].SetKey("d", 68);
  
  // Set up bindings
  //To bind: KEYS.[pFunc / hFunc / rFunc] = "FunctionIdentifier";
  KEYS[65].hFunc = "MoveLeft";
  KEYS[68].hFunc = "MoveRight";
  KEYS[87].hFunc = "MoveUp";
  KEYS[83].hFunc = "MoveDown";
  KEYS[32].hFunc = "DebugResetPos";
  

  OBJECTS = new BaseObject[4];
  physics = new Physics();
  
  player = new Player();
  OBJECTS[0] = player;
  player.hAccel = 2;
  player.vAccel = 2;
  player.maxHSpeed = 10;
  player.hSpeed = 0;
  player.vSpeed = 0;
  player.maxVSpeed = 10;
  
  wall = new Wall();
  OBJECTS[1] = wall;
  wall.x = 5 * width / 6;
  wall.y = (height / 2) - 32;
  wall.w = 64;
  wall.h = 64;
  
  wall2 = new Wall();
  OBJECTS[2] = wall2;
  wall2.x = width / 6;
  wall2.y = (height / 2) - 32;
  wall2.w = 64;
  wall2.h = 64;
  
  floor = new Wall();
  OBJECTS[3] = floor;
  floor.x = 0;
  floor.y = 2 * height / 3;
  floor.w = width;
  floor.h = 64;
  
  player.SetPos(width / 2, (height / 2) - 32);

  img_ball = loadImage("ball.png");
  player.SetTexture(img_ball);
}

void draw()
{
  // Poll for mouse input
  //if (mousePressed)
  //{
    
  //}
  //println("pressFunc: " + KEYS[0].pFunc + " holdFunc: " + KEYS[0].hFunc + " releaseFunc: " + KEYS[0].rFunc);
  // Poll for key pressess
  
  // Resolve key presses
  for (int i = 0; i < KEYS.length; i++)
  {
    if (KEYS[i].pFunc != "" && KEYS[i].pressed)
    {
      ParseFunction(KEYS[i].pFunc);
    }
    if (KEYS[i].hFunc != "" && KEYS[i].held)
    {
      ParseFunction(KEYS[i].hFunc);
    }
    if (KEYS[i].rFunc != "" && KEYS[i].released)
    {
      ParseFunction(KEYS[i].rFunc);
    }
  }
  // Clear key releases
  for (Key k : KEYS)
  {
    if (k.released && k.kCode != keyCode)
      k.released = false;
  }
  
  for (BaseObject o : OBJECTS)
  {
    Box temp = o.GetBox();
    //println("(" + temp.x + ", " + temp.y + ") w = " + temp.w + " h = " + temp.h);
  }
  
  // Update objects here
  player.Update();
  
  // Clear the screen
  background(200);
  
  // Draw things to the screen
  wall.Draw();
  wall2.Draw();
  player.Draw();
  floor.Draw();
}