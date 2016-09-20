// Chris Finck 2016

class Game
{
   private boolean m_isPaused = false;
   boolean IsPaused() { return m_isPaused;}
   void SetPaused(boolean paused) { m_isPaused = paused;}
   
   float tickrate = 64.0;
   float currentTick = 0;
   
   float GetTicks()
   {
     return millis(); /// tickrate;
   }
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
  float friction = 0.75;
  float gravity = 1;
  
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
  
  float ApplyGravity(float s)
  {
    return s + gravity;
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
  boolean doGravity = true;
  private PImage tex;
  
  boolean visible = true;
  int z = 0;
  
  boolean isFalling = false;
  
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
   if (visible)
   {
     if (tex.width != -1 && tex.height != -1)
     {
       imageMode(CORNER);
       image(tex, x, y);
     }
   }
  }
  
  float[] ThinkMove()
  {
    float[] thinkPos = new float[2];
    thinkPos[0] = x;
    thinkPos[1] = y;
    hSpeed = physics.ApplyFriction(hSpeed);
    vSpeed = physics.ApplyGravity(vSpeed);
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
    
    isFalling = true;
    // Check for collisions on player
    
    float[] thinkPos = ThinkMove();
    float[] bestPos = thinkPos;
    boolean hColFinal = false;
    boolean vColFinal = false;
    
    int hDirection = 0;
    if (hSpeed == 0)
      hDirection = 0;
    else if (abs(hSpeed) == hSpeed)
      hDirection = 1;
    else if (abs(hSpeed) != hSpeed)
      hDirection = -1;
      
    int vDirection = 0;
    if (vSpeed == 0)
      vDirection = 0;
    else if (abs(vSpeed) == vSpeed)
      vDirection = 1;
    else if (abs(vSpeed) != vSpeed)
      vDirection = -1;
            
    for (BaseObject tempObj : OBJECTS)
    {
      if (tempObj != this)
      {
        float[] tempPos = new float[2];
        
        boolean hCollision = false;
        boolean vCollision = false;
        if (physics.CheckCollision(new Box(thinkPos[0], y, w, h), tempObj.GetBox()))
          hCollision = true;
        if (physics.CheckCollision(new Box(x, thinkPos[1], w, h), tempObj.GetBox()))
          vCollision = true;
        if (hCollision == false && vCollision == false && physics.CheckCollision(new Box(thinkPos[0], thinkPos[1], w, h), tempObj.GetBox()))
        {
          hCollision = true;
          vCollision = true;
        }
        if (hCollision)
          hColFinal = true;
        if (vCollision)
          vColFinal = true;
        
        if (hCollision)
        {
          // HORIZONTAL COLLISIONS
          arrayCopy(thinkPos, tempPos);
          if (tempPos[0] > x)
          {
            while (tempPos[0] > x)
            {
              if(physics.CheckCollision(new Box(tempPos[0], y, w, h), tempObj.GetBox()))
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
              if(physics.CheckCollision(new Box(tempPos[0], y, w, h), tempObj.GetBox()))
                tempPos[0]++;
              else
                break;
            }
            if (tempPos[0] > x)
              tempPos[0] = x;
          }
          //arrayCopy(tempPos, thinkPos);
          // Adjust stopping position of object
          if (hDirection == 1)
            bestPos[0] = min(floor(tempPos[0]), bestPos[0]);
          else if (hDirection == -1)
            bestPos[0] = max(ceil(tempPos[0]), bestPos[0]);
          //else
          //  thinkPos[0] = round(tempPos[0]);
            
          //print("x: " + thinkPos[0] + ", ");
        }
        
        if (vCollision)
        {
          // VERTICAL COLLISIONS  
          if (vDirection == 1 || vDirection == 0)
            isFalling = false;
          
          arrayCopy(thinkPos, tempPos);
          if (tempPos[1] > y)
          {
            while (tempPos[1] > y)
            {
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
              if(physics.CheckCollision(new Box(thinkPos[0], tempPos[1], w, h), tempObj.GetBox()))
                tempPos[1]++;
              else
                break;
            }
            if (tempPos[1] > y)
              tempPos[1] = y;
          }
          //arrayCopy(tempPos, thinkPos);
          // Adjust stopping position of object
          if (vDirection == 1)
            bestPos[1] = min(floor(tempPos[1]), bestPos[1]);
          else if (vDirection == -1)
            bestPos[1] = max(ceil(tempPos[1]), bestPos[1]);
          //else
          //  thinkPos[1] = round(tempPos[1]);
          
          //println("y: " + thinkPos[1]);
          //Pause();
        }
      }
    }
    if (hColFinal)
      hSpeed = 0;
    if (vColFinal)
      vSpeed = 0;
    SetPos(bestPos[0], bestPos[1]);
  }
}

class Player extends BaseObject
{
  float jumpSpeed = 20.0;
  color cColor;
  
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
  
  void Jump()
  {
    if (!isFalling)
      vSpeed += -jumpSpeed;
  }
  
  void Draw()
  {
    if (visible)
    {
      stroke(255, 0, 0);
      fill(cColor);
      rectMode(CORNER);
      rect(x, y, w, h);
    }
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
    if (visible)
    {
      stroke(0);
      fill(255);
      rectMode(CORNER);
      rect(x, y, w, h);
    }
  }
}

class Key
{
  int kCode = -1;
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
    case "Jump":
      player.Jump();
      break;
    case "DebugResetPos":
      player.SetPos(width / 2, height / 2);
      player.hSpeed = 0;
      player.vSpeed = 0;
      break;
    case "DebugPrint":
      println("Key Pressed!");
      break;
    default:
      break;
  }
}

void SortObjects()
{
  int lastIndex = 0;
  boolean swaps = false;
  BaseObject tempObj;
  
  for(int i = 0; i < OBJECTS.length; i++)
  {
    for(int j = 0; j < i; j++)
    {
    }
    
  }
}

void Pause()
{
  delay(1000);
  //while (true)
  //{
  //  if (keyPressed)
  //  {
  //    println("Unpaused");
  //    break;
  //  }
  //}
}

void keyPressed() {
  if (keyCode >= 0 && keyCode < KEYS.length)
  {
    KEYS[keyCode].pressed = (KEYS[keyCode].held ? false : true);
    //if (KEYS[keyCode].held)
    //  KEYS[keyCode].pressed = false;
    //else
    //{
    //  println(keyCode);
    //  KEYS[keyCode].pressed = true;
    //}
    
    KEYS[keyCode].held = true;
  }
}

void keyReleased() {
  if (keyCode >= 0 && keyCode < KEYS.length)
  {
    //KEYS[keyCode].pressed = false;
    KEYS[keyCode].held = false;
    KEYS[keyCode].released = true;
  }
}



// Declare globally
Game game;
Key[] KEYS;
BaseObject[] OBJECTS;
Player player;
//PImage img_ball;
Wall wall;
Wall wall2;
Wall floor;

void setup()
{
  size(640, 480);
  background(255);
  
  rectMode(CORNER);
  imageMode(CORNER);
  
  game = new Game();
  
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
  KEYS[87].pFunc = "Jump";
  KEYS[83].hFunc = "MoveDown";
  KEYS[32].pFunc = "DebugResetPos";
  KEYS[10].pFunc = "Pause";
  

  OBJECTS = new BaseObject[4];
  physics = new Physics();
  
  player = new Player();
  OBJECTS[0] = player;
  player.w = 64;
  player.h = 64;
  player.hAccel = 2;
  player.vAccel = 2;
  player.maxHSpeed = 10;
  player.hSpeed = 0;
  player.vSpeed = 0;
  player.maxVSpeed = 20;
  player.cColor = color(0, 0, 0);
  
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
  floor.w = width - 1;
  floor.h = 64;
  
  player.SetPos(width / 2, (height / 2) - 32);

  //img_ball = loadImage("ball.png");
  //player.SetTexture(img_ball);
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
  
  // Clear key presses
  for (Key k : KEYS)
  {
    if (k.pressed && k.kCode != keyCode)
      k.pressed = false;
  }
  
  // Clear key releases
  for (Key k : KEYS)
  {
    if (k.released && k.kCode != keyCode)
      k.released = false;
  }
  
  // Update objects here
  while (game.GetTicks() > game.currentTick)
  {
    if (floor(game.GetTicks()/(1000/game.tickrate)%4) == 0)
    {
      player.cColor = color(red(player.cColor), green(player.cColor), blue(player.cColor) + 1);
    }
    player.Update();
    game.currentTick += 1000/game.tickrate;
  }
  
  // Clear the screen
  background(200);
  
  // Draw things to the screen
  //wall.Draw();
  //wall2.Draw();
  //player.Draw();
  //floor.Draw();
  int[] drawLayers = new int[OBJECTS.length];
  for (int i = 0;i < OBJECTS.length; i++)
  {
    drawLayers[i] = OBJECTS[i].z;
  }
  
  for (BaseObject o : OBJECTS)
  {
    o.Draw();
  }
  //println("pressed: " + KEYS[10].pressed + " held: " + KEYS[10].held + " released: " + KEYS[10].released);
}