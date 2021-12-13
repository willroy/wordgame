local function splitString(inpstr) 
  local list = {}
  for str in string.gmatch(inpstr, "%S+") do
    table.insert(list, str)
  end
  return list
end

local function dirLookup(dir)
  local listLookup = {}
  local files = love.filesystem.getDirectoryItems(dir)
  for k, file in ipairs(files) do
      listLookup[#listLookup+1] = file
  end
  return listLookup
end

local lists = dirLookup("/data/")
local loaded_list = {}
local mixed_list = {}
local background = love.graphics.newImage("/assets/background.png")
local good = love.graphics.newImage("/assets/good.png")
local meh = love.graphics.newImage("/assets/eh.png")
local bad = love.graphics.newImage("/assets/sad.png")
local clickcounter = 0
local guess1txt
local guess2txt
local guess1num = {}
local guess2num = {}
local wronganswers = 0
local score = 0
local finished = false
local menu = true
local last_pos = {0, 0}

function loadFile(filenum)
  if lists[filenum] == null then return false end
  finished = false
  menu = false
  loaded_list = {}
  local mixed1 = {}
  local mixed2 = {}
  for line in love.filesystem.lines("/data/"..lists[filenum]) do
    local output = {}
    for i in line:gmatch('[^"]+') do  
      output[#output + 1] = i
    end 
    loaded_list[#loaded_list+1] = {output[1], output[2]}
    mixed1[#mixed1+1] = output[1]
    mixed2[#mixed2+1] = output[2]
  end
  for i = 1, #mixed1 do
    local j, k = math.random(i, #mixed1), math.random(i, #mixed1)
    mixed1[j], mixed1[k] = mixed1[k], mixed1[j]
  end
  for i = 1, #mixed2 do
    local j, k = math.random(i, #mixed2), math.random(i, #mixed2)
    mixed2[j], mixed2[k] = mixed2[k], mixed2[j]
  end
  for i=1,#loaded_list do mixed_list[i] = {mixed1[i], mixed2[i]} end
end

function getScore()
  score = 0
  for i=1,#mixed_list do 
    if mixed_list[i][1] == "" then score = score + 1 end
  end
end

function checkanswer()
  local success = false
  for i=1,#loaded_list do
    if guess1txt == loaded_list[i][1] then
      if guess2txt == loaded_list[i][2] then
        for a=1,#mixed_list do
          if mixed_list[a][1] == loaded_list[i][1] then 
            mixed_list[a][1] = "" 
            success = true
          end
          if mixed_list[a][2] == loaded_list[i][2] then 
            mixed_list[a][2] = ""  
            success = true
          end
        end
      end
    elseif guess1txt == loaded_list[i][2] then
      if guess2txt == loaded_list[i][1] then
        for a=1,#mixed_list do
          if mixed_list[a][1] == loaded_list[i][1] then 
            mixed_list[a][1] = ""  
            success = true
          end
          if mixed_list[a][2] == loaded_list[i][2] then 
            mixed_list[a][2] = ""  
            success = true
          end
        end
      end
    end
  end
  if success == false then wronganswers = wronganswers + 1 end
end

function resetGuess()
  guess1txt = ""
  guess2txt = ""
  guess1num = {}
  guess2num = {}
end

function resetGame()
  wronganswers = 0
  loaded_list = {}
  mixed_list = {}
  clickcounter = 0
  guess1txt = ""
  guess2txt = ""
  guess1num = {}
  guess2num = {}
end

function matchDraw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(background, 0, 0)
  love.graphics.setColor(0, 0, 0)
  if #lists > 0 and menu then
    local count = 1
    for i=1,#lists do
      love.graphics.print(lists[i], 30, 31*count+20)
      count = count + 1
    end
  end
  if menu == false and finished == false then
    if #mixed_list > 0 then
      local count = 1
      for i=1,#mixed_list do
        love.graphics.setColor(0.3, 1, 0.3)
        if #guess1num > 0 and guess1num[2] == true then love.graphics.rectangle("line", 220, (guess1num[1])*31+20, 100, 25) end
        if #guess1num > 0 and guess1num[2] ~= true then love.graphics.rectangle("line", 5, (guess1num[1])*31+20, 100, 25) end
        if #guess2num > 0 and guess1num[2] == true then love.graphics.rectangle("line", 220, (guess2num[1])*31+20, 100, 25) end
        if #guess2num > 0 and guess1num[2] ~= true then love.graphics.rectangle("line", 5, (guess2num[1])*31+20, 100, 25) end
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(mixed_list[i][1], 5, 31*count+20)
        love.graphics.print(mixed_list[i][2], 220, 31*count+20)
        count = count + 1
      end
    end
    if wronganswers == 1 then love.graphics.print(wronganswers.." mistake", 5, 700)
    else love.graphics.print(wronganswers.." mistakes", 5, 700) end
  end
  if finished then
    love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
    love.graphics.rectangle("fill", 200, 15, 525, 775)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Score: "..score.." / "..#mixed_list, 5, 50)
    love.graphics.print("Mistakes: "..wronganswers, 5, 75)
    love.graphics.setColor(1, 1, 1)
    if score < (#mixed_list/2) then love.graphics.draw(bad, 5, 200) 
    elseif score < #mixed_list then love.graphics.draw(meh, 5, 200) 
    elseif score == #mixed_list then love.graphics.draw(good, 5, 200) end
  end
end

function matchTouchpressed(id, x, y, dx, dy, pressure )
  last_pos[1] = x
  last_pos[2] = y
  if menu then
    resetGame()
    loadFile(math.floor(((y-20)/31) + 0.5))
  end
  if finished then
    finished = false
    menu = true
  end
  if menu == false and finished == false then
    if wronganswers < 6 then
      if x > 5 and y > 31+20 then
        local clicked
        if mixed_list[(math.floor(((y-20)/31) + 0.5))] ~= null then
          if x < 245 then clicked = mixed_list[(math.floor(((y-20)/31) + 0.5))][1] end 
          if x > 245 then clicked = mixed_list[(math.floor(((y-20)/31) + 0.5))][2] end
          local num = (math.floor(((y-20)/31) + 0.5))
          if mixed_list[(math.floor(((y-20)/31) + 0.5))][1] ~= "" and x < 245 or
             mixed_list[(math.floor(((y-20)/31) + 0.5))][2] ~= "" and x > 245 then
            if clickcounter == 0 then
              guess1txt = clicked
              guess1num = {num, (x > 245)}
            elseif clickcounter == 1 then 
              guess2txt = clicked 
              guess2num = {num, (x > 245)}
              if tostring(guess1num[2]) == tostring(guess2num[2]) then
                clickcounter = -1
                resetGuess()
              end
            end
            clickcounter = clickcounter + 1
          else
            clickcounter = 0
            resetGuess()
          end
        end
      end
      if clickcounter == 2 then
        checkanswer()
        if wronganswers > 5 then
          getScore()
          finished = true
        end
        clickcounter = 0
        resetGuess()
      end
    end
    getScore()
    if score == 20 and x > 220 then
      finished = true
      clickcounter = 0
      resetGuess()
    end
  end
end

function matchKeypressed( key, code )
    if key == "escape" then menu = true end
end