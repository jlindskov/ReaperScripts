-- @description ReaBird
-- @version 1.0.2
-- @author Jeppe Emil Lindskov
-- @about
--   # Reabird
--   Flappybird clone now available in Reaper!


-- GLOBAL Variables ------------------------------

BoardSizeX = 500
BoardSizeY = 1000
PlayerSpeed = 0
GameSpeed = 4
PillarGap = 250
score = 0
Pillars = {}
deltaTime = 0
prevTime = 0
pillarSpawnTimer = 100
speedMultiplier = 1
randomSpawn = 0

-- Vector2 Class-------------------------------

Vector2 = {x = 0,y = 0, width = 20, height = 20}

function Vector2:new(o)
o = o or {}
setmetatable(o,self)
self.__index = self
return o
end


-- Player Class --------------------------------

Player = {x = 0, y = 0,width = 20,heigth = 20, dead = false}

function Player:Draw()
  gfx.r = 1
  gfx.b = 0
  gfx.g = 1
  gfx.rect(BoardSizeX/2,self.y,self.width,self.heigth)
end


-- Pillar Class ---------------------------------  

Pillar = {x = 0, y = 0, yEnd = 0,  width = 50, heigth = 0, scored = false}
  
  
function Pillar:Draw()
  gfx.r = 0
  gfx.b = 1
  gfx.g = 0
  --gfx.rect(self.x, self.yEnd ,self.width, self.heigth)
 
 gfx.rect(self.x, self.y ,self.width, self.height)
 gfx.rect(self.x, self.yEnd ,self.width, self.height + 100000)
  --gfx.rect(self.x, self.y2 ,self.width, self.heigth)
  
end  

function Pillar:new(o)
o = o or {}
setmetatable(o,self)
self.__index = self 
return o

end



function CreatePillar()

local p = Pillar:new()
  
p.x = BoardSizeX
p.y = 0
p.width = 20
p.scored = false
p.height = BoardSizeY/10 + math.random(0,500)

p.yEnd = p.height + PillarGap + math.random(-100,0)
table.insert(Pillars,p)
end

function ClearPillars()
for k,v in pairs(Pillars) do Pillars[k]=nil end

pillarSpawnTimer = 100 
end


function SpawnPlayer()
speedMultiplier = 1
Player.x = BoardSizeX/2
Player.y = 500
Player.dead = false
score = 0

CreatePillar()

end 

function IsPointInsideBox(x,y,col)

  isXInside = x>= col.x and x <= col.x + col.width
  --isYInside = y>= col.y and y <= col.y + col.height
  
  if isXInside then -- and isYInside == true then 
    KillPlayer()
    return true 
  else
    return false
  end

end


function CheckForInput()
  char = gfx.getchar()
  
  if Player.dead == true and char == 32 then
      ClearPillars()
       SpawnPlayer()
  end
  
  if Player.dead == false and char == 32 then
   return -1, true, "Y"
  end 
  
  
if char == 27 then 
      gfx.quit()
  else
    return 0 ,false, nil 
  end
end 


function CheckBounds()
  
  if Player.y >= BoardSizeY -25 then
   KillPlayer()
  end
  
  if Player.y <= 0 -100 then 
     Player.y = -100
  end
  
end 

function CheckPillarOverLap(x,y,width,heigth)

for i,v in ipairs (Pillars) do
  topLeftCol = IsPointInsideBox(x,y,v)
  topRightCol = IsPointInsideBox(x + width,y,v)
  botLeftCol = IsPointInsideBox(x, y + heigth,v)
  botRightCol = IsPointInsideBox(x + width, y + heigth, v)
end


end


function IsPointInsideBox(x,y,col)

  isXInside = x>= col.x and x <= col.x + col.width
  isYInside = y>= col.y and y <= col.y + col.height
  isYEndInside = y>= col.yEnd and y <= col.yEnd + col.height
  
  if isXInside and isYInside == true then 
    KillPlayer()
    
  end
  if isYEndInside and isXInside then 
    KillPlayer() 
  end

end


function KillPlayer()

 Player.dead = true
 
end

function MovePillars()

  for i,v in ipairs (Pillars) do
    v.x =  v.x - GameSpeed * speedMultiplier
    
    if v.x < Player.x+Player.width and v.scored == false then 
      speedMultiplier = speedMultiplier + 0.1
      score = score + 1
      v.scored = true
  
    end
    
    if v.x < 0 - Pillar.width then
    table.remove(Pillars,1)
    end
  end
end


function DrawMenu()
  
  gfx.r = 1
  gfx.b = 0
  gfx.g = 1


  gfx.x = 85
  gfx.y = 250
  gfx.setfont(1,"Arial", 100)
  gfx.drawstr("ReaBird")
  
  gfx.setfont(1,"Arial", 50)
  
  gfx.x = 175
  gfx.y = 400
  gfx.drawstr("Score: ")
  
  gfx.r = 1
  gfx.b = 0
  gfx.g = 0
  
  gfx.drawnumber(score,0)
  
  gfx.r = 1
  gfx.b = 0
  gfx.g = 1
  
  gfx.x = 65
  gfx.y = 600
  gfx.drawstr("Press space to play")
  
  gfx.setfont(1,"Arial", 25)
  gfx.x = 125
  gfx.y = 950
  gfx.drawstr("Tap Space To Move Up")

end
 


function RenderGFX()

  gfx.r = 0.3
  gfx.r = 0.3
  gfx.b = 0.3
  gfx.g = 0.3

  gfx.rect(0,0,BoardSizeX,BoardSizeY)

  -- Render Player 
  Player:Draw()

  for i,v in ipairs (Pillars) do
    v:Draw()
  end
  
  if Player.dead == false then 
      gfx.r = 1
      gfx.b = 0
      gfx.g = 1
      gfx.x = 200
      gfx.y = 10
      gfx.setfont(1,"Arial", 40)
      gfx.drawstr("Score: ")
      gfx.drawnumber(score,0)
  end
  
  
  -- If we are dead, show menu 
  if Player.dead == true then
    DrawMenu()
  end
  
  
end

function Update()

  inputValue,wasInput, inputDir = CheckForInput()
  
  if Player.dead == true then
     return 
   end 
   
   Player.y = Player.y + PlayerSpeed * -.6

   PlayerSpeed = PlayerSpeed - 3 
   
  if inputDir == "Y" then 
      PlayerSpeed = 25
  end
  
  
  if pillarSpawnTimer < 0 then 
    CreatePillar()
    pillarSpawnTimer = 100
  end
  
  pillarSpawnTimer = pillarSpawnTimer - 1
  
  
  MovePillars()
  CheckBounds()
  CheckPillarOverLap(Player.x,Player.y,Player.width,Player.heigth)
  

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
  screen = gfx.init("ReaBird" ,BoardSizeX, BoardSizeY, 0,Viewport[3], Viewport[4]) 
  Player.dead = true
  GameStarted = true 
end

------------------------------------------------------------------------------------ 

Init()
MainLoop()
