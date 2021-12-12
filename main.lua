editor = require("/src/match")

function love.load()
  love.window.setMode(1300, 800)
  love.graphics.setBackgroundColor(1,1,1)
  font = love.graphics.newFont('assets/font.ttf', 20)
  love.graphics.setFont(font)
  math.randomseed(os.time())
  io.stdout:setvbuf("no")
end

function love.draw()
  matchDraw()
end

function love.mousepressed(x, y, button, istouch)
  matchMousepressed(x, y, button, istouch)
end

function love.keypressed(key, code)
  matchKeypressed(key, code)
end