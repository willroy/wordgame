editor = require("/src/match")

function love.load()
  love.window.setMode(480, 800)
  love.graphics.setBackgroundColor(1,1,1)
  font = love.graphics.newFont('assets/font.ttf', 20)
  love.graphics.setFont(font)
  math.randomseed(os.time())
  io.stdout:setvbuf("no")
end

function love.conf()
  t.externalstorage = true
end

function love.draw()
  matchDraw()
end

function love.touchpressed( id, x, y, dx, dy, pressure )
  matchTouchpressed( id, x, y, dx, dy, pressure )
end

function love.keypressed( key, code )
    matchKeypressed(key, code)
end