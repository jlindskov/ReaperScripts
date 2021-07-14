-- @description ReaSnek
-- @version 1.0.2
-- @author Jeppe Emil Lindskov
-- @about
--   # ReaSnek
--   Classic Snake, now available in Reaper!


-- GLOBAL Variables ------------------------------

BoardSizeX = 1000
BoardSizeY = 700
PlayerSpeed_Start = 10
PlayerSpeec_Accel = 0.1 -- how fast shall the speed accelerated after each fruit
prevInputValue = 1
prevInputDir = "X"
currentDir = 0
fruitList = {}
noFruits = false
Dir = nil
score = 0


-- Vector2 Class-------------------------------

Vector2 = {x = 0,y = 0, width = 20, height = 20}

function Vector2:new(o)
o = o or {}
setmetatable(o,self)
self.__index = self
return o
end

-- Player Class --------------------------------

Player = {x = 0, y = 0,width = 20,heigth = 20, dead = false, snakePos = {}, snakeBodySize = 0,}

function Player:Draw()
  gfx.r = 1
  gfx.b = 0
  gfx.g = 1
  gfx.rect(self.x,self.y,self.width,self.heigth)

end
  
-- Fruit Class ---------------------------------  

Fruit = {x = 25, y = 0, width = 25,heigth = 25, dead = false}
  
  
function Fruit:Draw()

  if self.dead == false then
    gfx.r = 1
    gfx.b = 0
    gfx.g = 0
    gfx.rect(self.x, self.y,self.width, self.heigth)
  end
end

function Fruit:new(o)
o = o or {}
setmetatable(o,self)
self.__index = self
return o

end


-------------------------------------------------

function CheckForInput()
  char = gfx.getchar()
  if char~=0 then AAA=char end
  
  if Player.dead == true then
      if char == 32 then 
          PlayerSpeed = PlayerSpeed_Start
          SpawnPlayer()
      end
  end
  
  if char == 100 or char == 1919379572.0 then
   return 1, true, "X"
  end 
  
  if char == 97 or char == 1818584692 then 
   return -1, true, "X"
  end
  
 if char == 119 or char == 30064 then
  return -1, true, "Y"
 end 
 
  if char == 115 or char == 1685026670.0 then 
  return 1, true, "Y"
  end
  
if char == 27 then 
      gfx.quit()
  else
    return 0 ,false, nil 
  end
end

function KillPlayer()

 Player.dead = true
 
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
 

function Update()

  -- Check input and handle it correctly
  inputValue,wasInput, inputDir = CheckForInput()
  
  -- If player is dead just bail out
  if Player.dead == true then 
    return 
  end 
  
  -- If input is opposite, do nothing... 

  if inputDir == prevInputDir and inputVaule ~= prevInputValue then 
    inputValue = prevInputValue
  end
  
  -- If user is not pressing the right key or no key
  if wasInput == false then 
    inputValue = prevInputValue
    inputDir = prevInputDir
  end
  
  
  -- Store previous location so that tail updates correctly
  local vector = Vector2:new()
  vector.x = Player.x
  vector.y = Player.y
  -- Make the collision size small so we dont collide with our selves
  vector.width = 1
  vector.height = 1
  table.insert(Player.snakePos,1,vector)
  
  
  -- Move the head of the snake
  if inputDir == "X" then
    Player.x = Player.x + PlayerSpeed * inputValue
    if inputValue == 1 then 
       Dir = "Right"
    else inputValue = -1
        Dir = "Left"
    end
    prevInputValue = inputValue
    prevInputDir = inputDir
  end
  
  if inputDir == "Y" then 
    Player.y = Player.y + PlayerSpeed * inputValue
    
    if inputValue == 1 then 
      Dir = "Down"
    else inputValue = -1
      Dir = "Up"
    end
    prevInputValue = inputValue
    prevInputDir = inputDir
  end
  
  -- Move the tail portion 
  Xcount = tablelength(Player.snakePos)
  if Xcount >= Player.snakeBodySize +1 then 
      -- If we have more prev position entries that we have tail we remove the oldest one
      table.remove(Player.snakePos, Xcount)
  end
  
  -- Check if we are out of bounds
  CheckBounds()
  
  -- Check if we are overlapping a fruit 
  CheckFruitOverlap(Player.x, Player.y, Player.width, Player.heigth,fruitList)

  -- Check if we are overlapping our tail  
for i,v in ipairs (Player.snakePos) do

  -- Kinda big hack to make sure we dont collide with the first two points
  if i ~= 1 and i ~= 2 then 
    isInside = CheckTailOverLap(Player.x, Player.y, Player.width, Player.heigth, v)
      if isInside then
        KillPlayer()
      end
    end
  end
end



function CheckBounds()
  
  if Player.x >= BoardSizeX -25 then
    KillPlayer()
  end
  
  if Player.x <= 0 +2  then
    KillPlayer()
  end
  
  if Player.y >= BoardSizeY -25 then
   KillPlayer()
  end
  
  if Player.y <= 0 +2 then 
     KillPlayer()
  end
  
end 



function IsPointInsideBox(x,y,col)

  isXInside = x>= col.x and x <= col.x + col.width
  isYInside = y>= col.y and y <= col.y + col.height
  
  if isXInside and isYInside == true then 
    return true  
  else
    return false
  end

end


function CheckFruitOverlap(x,y,width,heigth,collisions)

for i,v in ipairs (fruitList) do
  if v.dead == false or v.dead == nil then
    topLeftCol = IsPointInsideBox(x,y,v)
    topRightCol = IsPointInsideBox(x + width,y,v)
    botLeftCol = IsPointInsideBox(x, y + heigth,v)
    botRightCol = IsPointInsideBox(x + width, y + heigth, v)
    if topLeftCol or topRightCol or botLeftCol or botRightCol then 
      -- for i = 1 ,10 do    
      FruitCollected(v)
      -- end
      return true 
    else 
      return false
    end
  end
end
end


function CheckTailOverLap(x,y,width,heigth,collisions)

  -- The -2 is to give a tiny amount of leeway so we dont collide when going close to us self. 

  topLeftCol = IsPointInsideBox(x,y,collisions)
  topRightCol = IsPointInsideBox(x + width - 2 ,y,collisions)
  botLeftCol = IsPointInsideBox(x, y + heigth -2 ,collisions)
  botRightCol = IsPointInsideBox(x + width -2, y + heigth, collisions)
  
  if topLeftCol or topRightCol or botLeftCol or botRightCol then 
    return true 
  else 
    return false
  end
end



function FruitCollected(fruit)
fruit.dead = true
Player.snakeBodySize = Player.snakeBodySize + 1
score = score + 100
PlayerSpeed=PlayerSpeed+PlayerSpeec_Accel 
end



function SpawnPlayer()
Player.x = 500
Player.y = 500
Player.dead = false
Player.snakeBodySize = 0
Player.snakePos = {}

CreateFruit()
score = 0

end

-- Pre create fruits 
function CreateFruit()

for i = 1, 4 do 
local f = Fruit:new()

fruitList = {}

f.x = 10
f.y = 0
f.height = 20 
f.width = 20
f.dead = true
table.insert(fruitList,f)
end


end


-- Spawn fruit at a random location
function SpawnFruit()

  local selFruit = nil
  
  for i,v in ipairs(fruitList)do
    if v.dead == true then 
    v.x = math.random(25,BoardSizeX - 25)
    v.y = math.random(25,BoardSizeY - 25)
    v.dead = false
    break
    
    end
  end
end

function DrawMenu()
  
  gfx.r = 1
  gfx.b = 0
  gfx.g = 1


  gfx.x = 330
  gfx.y = 250
  gfx.setfont(1,"Arial", 100)
  gfx.drawstr("ReaSnek")
  
  gfx.setfont(1,"Arial", 50)
  
  gfx.x = 425
  gfx.y = 400
  gfx.drawstr("Score: ")
  
  gfx.r = 1
  gfx.b = 0
  gfx.g = 0
  
  gfx.drawnumber(score,0)
  
  gfx.r = 1
  gfx.b = 0
  gfx.g = 1
  
  gfx.x = 315
  gfx.y = gfx.h-200
  gfx.drawstr("Press space to play")
  
  gfx.setfont(1,"Arial", 25)
  gfx.x = 700
  gfx.y = gfx.h - 100
  gfx.drawstr("WASD or Arrows to move")

end


function RenderGFX()

  -- Render Player 
  Player:Draw()


  -- Render trail
  gfx.r = 0
  gfx.b = 1
  gfx.g = 1
  for i,v in ipairs (Player.snakePos) do
      gfx.rect(v.x, v.y ,20,20)
  end
  
  -- see if we have any active fruit. 
  local counter = 0
  for i,v in ipairs (fruitList) do
    if v.dead == false then 
    v:Draw()
    counter = counter + 1
    end
  end
  
  -- Spawn a fruit if not fruit is visible
  if counter == 0 then
   SpawnFruit()
  end
  
  -- If we are dead, show menu 
  if Player.dead == true then
    DrawMenu()
  end
  
  
end



function MainLoop()

  Update()
  RenderGFX()
  
  -- Loop hack
  if gfx.getchar() >= 0 then 
    reaper.defer(MainLoop)
  end 
  
end

function Init()
  Viewport={reaper.my_getViewport(0,0,0,0,0,0,0,0,false)}
  Viewport[3]=(Viewport[3]-BoardSizeX)/2
  Viewport[4]=(Viewport[4]-BoardSizeY)/2
  screen = gfx.init("ReaSnek" ,BoardSizeX, BoardSizeY, 0,Viewport[3],Viewport[4]) 
    Player.dead = true; 
  GameStarted = true 
end

------------------------------------------------------------------------------------ 

Init()
MainLoop()
