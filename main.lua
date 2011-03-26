require("Player")
require("Hole")
require("Crystal")
require("Meteor")

-- Constants
WIDTH  = 512
HEIGHT = 384
MAPWIDTH = 4000
MAPHEIGHT = 4000
MAPRADIUS = 2000
SCALE = 2
P_ACC = 4
P_ROTACC = 3
HOLE_PARTICLES = 64
CRYSTAL_RESPAWN_TIME = 20 --seconds
HALFDIST = math.sqrt(math.pow(WIDTH/2,2)+math.pow(HEIGHT/2,2))
MMX = WIDTH*SCALE-220
MMY = 20
MMW = 200
MMOFFX = MMW/MAPWIDTH
MMOFFY = MMW/MAPHEIGHT

-- Variables
p = Player.create(MAPWIDTH/2,MAPHEIGHT/2-100)
holes = {}
crystals = {}
meteors = {}
energy = 100

function love.load()
	math.randomseed(os.time())
	love.graphics.setMode(WIDTH*SCALE,HEIGHT*SCALE,false)
	love.graphics.setBackgroundColor(5,5,5)
	addBlackHoles(10)
	addCrystals(5)
	loadResources()
	table.insert(meteors,Meteor.create(MAPWIDTH/2,MAPHEIGHT/2,0))
end

function love.update(dt)
	-- Update black hole particles
	for	i,h in ipairs(holes) do
		Hole.update(h,dt)
	end
	-- Update crystal rotation
	for i,v in ipairs(crystals) do
		v.dir = v.dir + dt
	end
	-- Update meteors
	for i,v in ipairs(meteors) do
		Meteor.update(v,dt)
		if v.x-16 < 0 or v.x+16 > MAPWIDTH
		or v.y-16 < 0 or v.y+16 > MAPHEIGHT then
			table.remove(meteors,i)
		end
	end
	-- Update player
	Player.update(p,dt)
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(SCALE)
	love.graphics.translate(WIDTH/2-p.x,HEIGHT/2-p.y)
	love.graphics.setColor(255,255,255,255)

	-- Draw planet
	love.graphics.draw(imgPlanet,MAPWIDTH/2-100,MAPHEIGHT/2-100)
	-- Draw black holes
	love.graphics.setLineStyle("rough")
	love.graphics.setColor(255,255,255,255)
	for i,v in ipairs(holes) do
		Hole.draw(v)
	end
	-- Draw crystals
	for	i,v in ipairs(crystals) do
		love.graphics.draw(imgCrystal,v.x,v.y,v.dir,1,1,16,16)
	end
	-- Draw borders
	love.graphics.setColor(0,0,0,255)
	love.graphics.setLineWidth(100)
	love.graphics.circle("line",MAPWIDTH/2,MAPHEIGHT/2,MAPRADIUS,64)
	love.graphics.setColor(0,0,0,255)
	love.graphics.circle("line",MAPWIDTH/2,MAPHEIGHT/2,MAPRADIUS,64)
	-- Draw player
	Player.draw(p)
	-- Draw meteors
	for i,v in ipairs(meteors) do
		quad = love.graphics.newQuad(v.sprite*32,0,32,32,64,64)
		love.graphics.drawq(imgMeteor,quad,v.x,v.y,v.dir)
	end
	-- Draw mini map
	love.graphics.pop()
	love.graphics.setColor(0,0,0,200)
	love.graphics.circle("fill",MMX+100,MMY+100,MMW/2,32)
	for	i,v in ipairs(holes) do
		love.graphics.setColor(255,255,255,255)
		love.graphics.circle("fill",MMX+v.x*MMOFFX,MMY+v.y*MMOFFY,3,4)
		love.graphics.setColor(0,0,0,255)
		love.graphics.circle("fill",MMX+v.x*MMOFFX,MMY+v.y*MMOFFY,2,4)
	end
	love.graphics.setColor(50,130,220,255)
	for	i,v in ipairs(crystals) do
		love.graphics.circle("fill",MMX+v.x*MMOFFX,MMY+v.y*MMOFFY,2,4)
	end
	love.graphics.setColor(150,205,110,255)
	love.graphics.circle("fill",MMX+MMW/2,MMY+MMW/2,5,4)
	love.graphics.setColor(20,160,240,255)
	love.graphics.circle("fill",MMX+p.x*MMOFFX-1,MMY+p.y*MMOFFY-1,3,4)
	-- Draw energy bar
	love.graphics.setColor(0,0,0,200)
	love.graphics.rectangle("fill",20,HEIGHT*SCALE-48,408,28)
	love.graphics.setColor(90,200,80,255)
	love.graphics.rectangle("fill",24,HEIGHT*SCALE-44,energy*4,20)
end

function loadResources()
	imgPlayer = love.graphics.newImage("gfx/player.png")
	imgPlayer:setFilter("nearest","nearest")
	imgPlanet = love.graphics.newImage("gfx/planet.png")
	imgPlanet:setFilter("nearest","nearest")
	imgCrystal = love.graphics.newImage("gfx/crystal.png")
	imgCrystal:setFilter("nearest","nearest")
	imgMeteor = love.graphics.newImage("gfx/meteor.png")
	imgMeteor:setFilter("nearest","nearest")
end
