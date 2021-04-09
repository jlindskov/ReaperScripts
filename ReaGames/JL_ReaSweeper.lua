-- @description ReaSweeper
-- @version 1.0.2
-- @author Jeppe Emil Lindskov
-- @about
--   # ReaSweeper
--   MineSweeper now available in Reaper


-- GLOBAL Variables ------------------------------

BoardSizeX = 500
BoardSizeY = 1000
score = 0

gridWidth = 20
gridHeight = 15
cellHeight = 30
cellwidth = 30
numberOfMines = 25
flaggedMines = numberOfMines
gameEnded = false
gameWon = false
prevInput = 0
selectedCell = nil
grid = {}
startTime = os.time() 
currentTime = 0
firstSelection = true


-- Cell Class ---------------------------------  

Cell = {x = 0, y = 0, width = 25, heigth = 25, mine = false, isRevealed = false, isFlagged = false, index ={x = 0, y = 0}, neighborMines = 0, cantBeMine = false}
  
  
function Cell:Draw()
  gfx.r = 0
  gfx.b = 0
  gfx.g = 0
  gfx.rect(self.x, self.y ,self.width, self.height)
 
  if self.isRevealed == true then
  gfx.r = 0.7 
  gfx.b = 0.7
  gfx.g = 0.7
  gfx.rect(self.x + 1, self.y + 1 ,self.width, self.height -1)
  elseif self.isFlagged == true then
  gfx.r = 1 
  gfx.b = 0
  gfx.g = 1
  gfx.rect(self.x + 1, self.y + 1 ,self.width, self.height -1)
  else
    if self == selectedCell then 
    gfx.r = 0.3 
    gfx.b = 0.3
    gfx.g = 0.3
    else
    gfx.r = 0.5
    gfx.b = 0.5
    gfx.g = 0.5
    end
    gfx.rect(self.x + 1, self.y + 1 ,self.width, self.height -1)
  end
 
if self.neighborMines > 0 and self.isRevealed == true then
  gfx.r = 0 
  gfx.b = 0
  gfx.g = 0
  
  gfx.x = self.x +10
  gfx.y = self.y + 5
  gfx.setfont(1,"Arial", 20)
  gfx.drawnumber(self.neighborMines,0)
end
 
 
 if self.mine == true and self.isRevealed == true then
 
 if gameWon == true then 
 
 gfx.r = 0
 gfx.b = 0
 gfx.g = 1
 else 
 gfx.r = 1 
 gfx.b = 0
 gfx.g = 0
 end
  gfx.rect(self.x + 1, self.y + 1 ,self.width, self.height -1)
  
  gfx.r = 0 
  gfx.b = 0
  gfx.g = 0
  gfx.x = self.x +10
  gfx.y = self.y + 5
  gfx.setfont(1,"Arial", 20)
  gfx.drawstr("B") 

  end
end  


function Cell:new(o)
  o = o or {}
  setmetatable(o,self)
  self.__index = self 
  return o
end



function FlagForNoMines(index)

grid[index.x][index.y].cantBeMine = true

end
---------------------------------------------------

function RevealCell(index)
    
  -- If neighbourMines = 0 for the touched cell then
  -- we reveal the neighbour cells as well using a 
  -- recursive call to this function.
  
if firstSelection == true then

  markNeighbourCells(index.x - 1, index.x + 1, index.y - 1, index.y + 1) 
  CreateMines()
  firstSelection = false 
    

end
  
  
  grid[index.x][index.y].isRevealed = true
  if grid[index.x][index.y].mine == true then
  RevealGameBoard()
  gameEnded = true
    return
  end
    if grid[index.x][index.y].neighborMines == 0 then
      inNeighbourCells(index.x - 1, index.x + 1, index.y - 1, index.y + 1, function(x, y) 
          if not grid[x][y].isRevealed and not grid[x][y].mine and not grid[x][y].flagged then
              RevealCell({x = x, y = y})
          end
    end)
    end
end

function CreateCell(i,j,x,y)
  local cell = Cell:new()
  cell.x = x
  cell.y = y
  cell.index = {x = i, y = j}
  cell.width = cellwidth
  cell.height = cellHeight
  cell.mine = false
  cell.isRevealed = false
  cell.neighborMines = 10
  cell.isFlagged = false
  cell.cantBeMine = false
  return cell
end


function DrawGrid()
    
  -- Iterate through the grid matrix and draw each cell
  for i = 1, gridWidth do
    for j = 1, gridHeight do
        grid[i][j]:Draw()
    end
  end

end


function RevealGameBoard()
    for i = 1, gridWidth do
      for j = 1, gridHeight do
          grid[i][j].isRevealed = true
      end
    end
end 


function DrawSidePanel()

  
  --Panel BG
  gfx.r = 0.6 
  gfx.b = 0.6
  gfx.g = 0.6
  gfx.rect( BoardSizeX - 200, 15, 190, 200)
  gfx.x = BoardSizeX - 195
  gfx.y = 20
  gfx.r = 0 
  gfx.b = 0
  gfx.g = 0
  
  --Bomb Calculation
  gfx.setfont(1,"Arial", 30)
  gfx.drawstr("Bombs " .. tostring(flaggedMines).."/"..tostring(numberOfMines))
  
  --Timer
  gfx.x = BoardSizeX - 195
  gfx.y = 50
  
  if gameEnded == false then 
  currentTime = os.difftime(os.time(), startTime)
  end
  gfx.drawstr("Time: "..tostring(currentTime)) 
  
  gfx.x = BoardSizeX - 195
  gfx.y = 100
  gfx.setfont(1,"Arial", 25)
  
  if gameEnded == true then 
  
    if gameWon == true then 
      gfx.drawstr("GAME WON! :D") 
    else
      gfx.drawstr("GAME LOST! x(") 
    end
  end
end


function ResetTimer()
currentTime = 0
startTime = os.time()
end


function inNeighbourCells(startX, endX, startY, endY, closure)
  for i = math.max(startX, 1), math.min(endX, gridWidth) do
      for j = math.max(startY, 1), math.min(endY, gridHeight) do
          closure(i, j)
      end
  end
end

function markNeighbourCells(startX, endX, startY, endY)
  for i = math.max(startX, 1), math.min(endX, gridWidth) do
      for j = math.max(startY, 1), math.min(endY, gridHeight) do
      grid[i][j].cantBeMine = true
          --closure(i, j)
      end
  end
end


function countMines(index)
    
  local mineNum = 0
    inNeighbourCells(index.x - 1, index.x + 1, index.y - 1, index.y + 1, 
        function(x, y) if grid[x][y].mine then mineNum = mineNum + 1 end
        end)
    return mineNum
end


function CreateGrid()

  local baseX =  gridWidth
  local y =  gridHeight
  local x = baseX

  for i = 1, gridWidth do
    grid[i] = {}     -- create a new row
      for j = 1, gridHeight do
        grid[i][j] = CreateCell(i, j, x, y)
        x = x + cellHeight
        BoardSizeX = x
      end
    x = baseX
    y = y + cellwidth  
    BoardSizeY = y
  end
  BoardSizeY = BoardSizeY + 10
  BoardSizeX = BoardSizeX +210
  
 -- CreateMines()
    
  for i = 1, gridWidth do
    for j = 1, gridHeight do
      grid[i][j].neighborMines = countMines(grid[i][j].index)
    end
  end
end


function CreateMines()

  for i = 1, numberOfMines do
      local mineX, mineY
        repeat
          mineX = math.random(1, gridWidth)
          mineY = math.random(1, gridHeight)
        until grid[mineX][mineY].mine == false or grid[mineX][mineY].cantBeMine == false     -- we dont want to duplicate mine location
        grid[mineX][mineY].mine = true
  end
  
  for i = 1, gridWidth do
     for j = 1, gridHeight do
       grid[i][j].neighborMines = countMines(grid[i][j].index)
     end
   end


end


function RenderBG()
  gfx.r = 0.3
  gfx.r = 0.3
  gfx.b = 0.3
  gfx.g = 0.3 
  gfx.rect(0,0,BoardSizeX,BoardSizeY)
end

function RenderGFX()
  RenderBG()
  DrawGrid()
  DrawSidePanel()
  
end


function GetCell(x,y)

  for i = 1, gridWidth do
        for j = 1, gridHeight do
        if grid[i][j].x < x and x < grid[i][j].x + grid[i][j].width 
        and grid[i][j].y < y and y < grid[i][j].y + grid[i][j].height then
          return grid[i][j]
        end
      end
  end
  return nil
end

 lb_down = function() return gfx.mouse_cap&1 == 1 end
 rb_down = function() return gfx.mouse_cap&2 == 2 end
 last_LMB_state = false
 last_RMB_state = false
 
 function OnMouseDown(x, y, lmb_down, rmb_down)
   -- LMB clicked
   if not rmb_down and lmb_down and last_LMB_state == false then
    last_LMB_state = true
    cell = GetCell(gfx.mouse_x,gfx.mouse_y)
    selectedCell = cell
   end
   -- RMB clicked
   if not lmb_down and rmb_down and last_RMB_state == false then
     last_RMB_state = true
    cell = GetCell(gfx.mouse_x,gfx.mouse_y)
    selectedCell = cell
   end
 end
 
 
function OnMouseUp(x, y, lmb_down, rmb_down)
  if not lmb_down and last_LMB_state then
    last_LMB_state = false 
    --cell = GetCell(gfx.mouse_x,gfx.mouse_y)
    cell = selectedCell
  if cell ~= nil then
       RevealCell(cell.index)
  end

end

  if not rmb_down and last_RMB_state then
    last_RMB_state = false
    --cell = GetCell(gfx.mouse_x,gfx.mouse_y)
    cell = selectedCell
    if cell ~= nil then
      if  cell.isFlagged == false then
        cell.isFlagged = true
        flaggedMines = flaggedMines - 1
        else
        cell.isFlagged = false
        flaggedMines = flaggedMines + 1
        end
      end
   end
 selectedCell = nil
end


function CheckWinCondition()

unopenedCells = 0 


 for i = 1, gridWidth do
    for j = 1, gridHeight do
    if grid[i][j].isRevealed == false or grid[i][j].isFlagged then 
        unopenedCells = unopenedCells + 1
      end
    end
  end

  if unopenedCells == numberOfMines then 
     gameWon = true
     gameEnded = true
     RevealGameBoard()
    
  end 
end

function GetMouseInput()
  
  local LB_DOWN = lb_down()           -- Get current left mouse button state
  local RB_DOWN = rb_down() 
  
  if (LB_DOWN and not RB_DOWN) or (RB_DOWN and not LB_DOWN) then   -- LMB or RMB pressed down?
    if (last_LMB_state == false and not RB_DOWN) or (last_RMB_state == false and not LB_DOWN) then
      OnMouseDown(mx, my, LB_DOWN, RB_DOWN)
    end
  elseif not LB_DOWN and last_RMB_state or not RB_DOWN and last_LMB_state then
      OnMouseUp(mx, my, LB_DOWN, RB_DOWN)
  end
end
 
 
function MainLoop()

 -- Update()
  GetMouseInput()

  RenderGFX()
  CheckWinCondition()
  
  -- Loop hack
  if gfx.getchar() >= 0 then 
    reaper.defer(MainLoop)
  end 
  
end

function Init()

  retval,retvalCSV  = reaper.GetUserInputs("Welcome To ReaSweeper", 3, "Grid Width:,Grid Height:,Mines:", "10,15,15")
  if retval ~= false then
  gridWidth, gridHeight, numberOfMines = string.match(retvalCSV, "([^,]+),([^,]+),([^,]+)")
  gridWidth = tonumber(gridWidth)
  gridHeight = tonumber(gridHeight)
  numberOfMines = tonumber(numberOfMines)
  flaggedMines = numberOfMines
  CreateGrid()
  screen = gfx.init("ReaSweeper" ,BoardSizeX, BoardSizeY, 0,1000,500)
  ResetTimer()
  MainLoop()
  end
end

------------------------------------------------------------------------------------ 

Init()
