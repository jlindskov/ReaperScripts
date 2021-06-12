-- @description TicTacToe
-- @version 1.0.1
-- @author Jeppe Emil Lindskov
-- @about
--   # TicTacToe
--   TicTacToe made using reapers tracks and items


-------------------------------------------------------------------------------------

function Zoom()

reaper.Main_OnCommand(40635, 0)
reaper.SelectAllMediaItems( 0, false )
reaper.SelectAllMediaItems( 0, true )
reaper.Main_OnCommand(41622, 0) -- View: Toggle zoom to selected items+
reaper.SelectAllMediaItems( 0, false )

end

----------------------------------------------------------------------------------------
function ChooseLetter()

while(_name ~= "X" and _name ~= "O")
  do
 retval, _name = reaper.GetUserInputs("X or O", 1, "Do you want to be X or O?", "")
  if retval == false then
    return
    end
    if _name == "x"then
      _name = "X"
    end
    
    if _name == "o" then
      _name = "O"
    end
end
  return _name
end

----------------------------------------------------------------------------------------

function CreateBoard()
   i = 3
   mediaStart = 0
   mediaEnd = 5

   board = {}
   clip = 1

  trackCount = reaper.CountTracks(0)

  while trackCount > 0 do
    track = reaper.GetTrack(0, 0)
    reaper.DeleteTrack( track )
    trackCount = trackCount - 1
    end

  trackCount = reaper.CountTracks(0)

  while(trackCount < i)
    do
    reaper.InsertTrackAtIndex(0, false)
    trackCount = reaper.CountTracks(0)
     track = reaper.GetTrack(0, 0)
    currentMediaItems = reaper.CountTrackMediaItems(track)
    while(currentMediaItems < i)
      do
     -- board[clip] = reaper.CreateNewMIDIItemInProj(track, mediaStart,mediaEnd,false )
     midiClip = reaper.CreateNewMIDIItemInProj(track, mediaStart,mediaEnd,false )
     table.insert(board,midiClip)
      mediaStart = mediaStart + 5
      mediaEnd = mediaEnd + 5
      currentMediaItems = reaper.CountTrackMediaItems(track)
      clip = clip + 1
      end
  
    mediaStart = 0
    mediaEnd = 5
    end
  
  local count=1
  for i=reaper.CountTracks(0)-1, 0, -1 do
    track = reaper.GetTrack(0, i)
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "Field: "..count.." "..(count+1).." "..(count+2), true)
    count=count+3
  end

  return board
end


--------------------------------------------------------------------------

function GetNames(Pname)

  blue = reaper.ColorToNative(0,0,255)|0x1000000
  red = reaper.ColorToNative(255,0,0)|16777216
  
  if name == "X" then
     _playerName = "X"
     playerColor = red
     _computerName = "O"
     computerColor = blue
  else
    _playerName = "O"
    playerColor = blue
    _computerName = "X"
    computerColor = red
  end
  
  return _playerName, _computerName
end

-----------------------------------------------------------------------------
function IsSpaceFree(_board, _move)
 take = reaper.GetActiveTake(playingBoard[_move])
local check = ""
  retval, check = reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME", check ,false)
  if check == "" then
    return true
  else
    return false
  end
  
  
  --return check == ""
end

------------------------------------------------------------------------------

function PaintTracks(_board, pColor,_Move)

takeToColor = reaper.GetActiveTake(playingBoard[_Move])
corlorSet= reaper.SetMediaItemTakeInfo_Value(takeToColor, "I_CUSTOMCOLOR", pColor);

end


------------------------------------------------------------------------------

function GetPlayerInput(_board)

playermove = ""

--spaceIsFree = false
while(playermove ~= 1 and playermove ~= 2 and playermove ~= 3  and playermove ~= 4  and playermove ~= 5  and playermove ~= 6  and playermove ~= 7  and playermove ~= 8  and playermove ~= 9)
  do
  retval, playermove = reaper.GetUserInputs("X or O", 1, "Select Number 1 - 9, cancel to forfeit","")
  playermove = tonumber(playermove)
  if retval == false then
    EndGame()
  end
end

moveInt = tonumber(playermove)

if IsSpaceFree(_board, moveInt) == false then
  reaper.ShowMessageBox("Board is occupied!!","", 0)
  GetPlayerInput()
  end

return moveInt
end

--------------------------------------------------------------------------------


function MakeMove(_board, letter, _move)

--reaper.ShowConsoleMsg(_move)
  moveTake = reaper.GetActiveTake(playingBoard[_move])
  reaper.GetSetMediaItemTakeInfo_String(moveTake,"P_NAME", letter ,true)

end

-------------------------------------------------------------------------------

function IsBoardFull(_board)
for i = 1,9 do
if IsSpaceFree(_board,i) then
  return false
end
end


return true
end

--------------------------------------------------------------------------------
function GetLetter(_board, _move)

  tk = reaper.GetActiveTake(playingBoard[_move])
  letter = 0
  retval, check = reaper.GetSetMediaItemTakeInfo_String(tk,"P_NAME", letter ,false)
  return check
end

--------------------------------------------------------------------------------


function CheckWin(_board, letter) 

local b1 = GetLetter(_board,1)
local b2 = GetLetter(_board,2)
local b3 = GetLetter(_board,3)
local m1 = GetLetter(_board,4)
local m2 = GetLetter(_board,5)
local m3 = GetLetter(_board,6)
local t1 = GetLetter(_board,7)
local t2 = GetLetter(_board,8)
local t3 = GetLetter(_board,9)

if  b1 == letter and b2 == letter and b3 == letter then
  return true
end 

if  m1 == letter and m2 == letter and m3 == letter then
  return true
end 

if  t1 == letter and t2 == letter and t3 == letter then
  return true
end 

if  b1 == letter and m1 == letter and t1 == letter then
  return true
end 

if  b2 == letter and m2 == letter and t2 == letter then
  return true
end 

if  b3 == letter and m3 == letter and t3 == letter then
  return true
end 

if  b1 == letter and m2 == letter and t3 == letter then
  return true
end 

if  b3 == letter and m2 == letter and t1 == letter then
  return true
end 


return false

end

-------------------------------------------------------------------------------

function WhoGoesFirst()

 local r = math.random(0,1)
  if r == 0 then
    return "Computer"
  else
    return "Player"
  end
end
-------------------------------------------------------------------------------

function GetBoardCopy(_board)

local dupeBoard = {}

j = 0

for k, v in pairs(_board) do
  table.insert(dupeBoard,v)
end

return dupeBoard

end
--------------------------------------------------------------------------------

function ChooseRandomMoveFromList(_board, movesList)
local possibleMoves = {}

for k, v in pairs(movesList) do
  if IsSpaceFree(_board,v) then
    table.insert(possibleMoves,v)
    end
end

if #possibleMoves ~= 0 then
 local randomChoice = math.random(1,#possibleMoves)
 return possibleMoves[randomChoice]
end
  
end

--------------------------------------------------------------------------------

function GetComputerMove(_board, _computerLetter)


copy = GetBoardCopy(_board)


for b = 1,9 do

 if IsSpaceFree(copy,b) then
   MakeMove(copy,computerName,b)
   if CheckWin(copy, computerName) then
      return b 
    else 
    MakeMove(copy,"",b)
  end
 end
end


for b = 1,9 do

 if IsSpaceFree(copy,b) then
   MakeMove(copy,playerName,b)
   if CheckWin(copy, playerName) then
      return b 
    else 
    MakeMove(copy,"",b)

   end
  end
end


local cornerMove = ChooseRandomMoveFromList(_board,{1,3,7,9})

if cornerMove ~= nil then
  return cornerMove
end

if IsSpaceFree(playingBoard, 5) then
  return 5
end 
      
return ChooseRandomMoveFromList(_board,{2,4,6,8})
  

end
----------------------------------------------------------------------------------



function Main()

isPlaying = true

while (isPlaying == true) do


  if turn == "Player" then
   local move = GetPlayerInput(playingBoard)
    MakeMove(playingBoard, playerName, move)
    PaintTracks(playingBoard,playerColor,move)
    turn = "Computer"
    
    if CheckWin(playingBoard,playerName) == true then
      reaper.ShowMessageBox("You Win!","", 0)
      isPlaying = false;   
    else
      if IsBoardFull(playingBoard)then
          reaper.ShowMessageBox("It is a tie!","", 0)
          isPlaying = false;
      end
    end
  else
    --move = GetPlayerInput(playingBoard)
   local Cpumove = GetComputerMove(playingBoard, computerName)
    MakeMove(playingBoard, computerName, Cpumove)
    PaintTracks(playingBoard,computerColor,Cpumove)
    turn = "Player"
      if CheckWin(playingBoard,computerName) == true then
        reaper.ShowMessageBox("Computer Wins!","", 0)
        isPlaying = false; 
      else 
        if IsBoardFull(playingBoard)then
            reaper.ShowMessageBox("It is a tie!","", 0)
            isPlaying = false;
        end
      end
  end
end
end

--------------------------------------
reaper.ClearConsole()

if reaper.GetProjExtState(0, "JL", "TicTacToe")=="" then
  reaper.Main_OnCommand(40859, 0)
  reaper.SetProjExtState(0, "JL", "TicTacToe", "exists")
end
--wannaPlay = reaper.ShowMessageBox("Do you want to play?\nWARNING: This will clear your current session, so save your work or make empty project!", "Welcome To Tic Tac Toe", 4)

--if wannaPlay ~= 6 then
--return
--end

name = ChooseLetter()

if name == nil then 
  return
  end
playingBoard = CreateBoard()

playerName, computerName = GetNames(name)
turn = WhoGoesFirst()
Zoom()

reaper.ShowMessageBox(turn.." Starts!","", 0)

function EndGame()
end

Main()


--reaper.defer(Main())









