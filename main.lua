require("Player")
require("Hole")
require("Crystal")
require("Meteor")
require("Babby")

-- Constants
WIDTH  = 512
HEIGHT = 384
MAPWIDTH = 4000
MAPHEIGHT = 4000
MAPRADIUS = 2000
WAVE_TIME = 40 --seconds
SCALE = 2
HOLE_PARTICLES = 64
CRYSTAL_RESPAWN_TIME = 16 --seconds
HALFDIST = math.sqrt(math.pow(WIDTH/2,2)+math.pow(HEIGHT/2,2))
MMX = WIDTH*SCALE-220
MMY = 20
MMW = 200
MMOFFX = MMW/MAPWIDTH
MMOFFY = MMW/MAPHEIGHT

-- Variables
function love.load()
	math.randomseed(os.time())
	love.graphics.setMode(WIDTH*SCALE,HEIGHT*SCALE,false)
	love.graphics.setBackgroundColor(5,5,5)
	newGame()
end

function newGame()
	p = Player.create(MAPWIDTH/2,MAPHEIGHT/2)
	holes = {}
	crystals = {}
	meteors = {}
	babbies = {}
	next_wave = WAVE_TIME/2
	next_crystal = CRYSTAL_RESPAWN_TIME
	energy = 100
	gamestate = 0 -- 0 = normal, 1 = lost in space, 2 = babbies dead
	addBlackHoles(8)
	addCrystals(5)
	addBabbies()
	loadResources()
end

function love.update(dt)
	-- Update black hole particles
	for	i,h in ipairs(holes) do
		Hole.update(h,dt)
	end
	-- Update babbies
	babby_frame = (babby_frame+2*dt)%2
	for i,v in ipairs(babbies) do
		if v.alive == false then
			table.remove(babbies,i)
		else
			Babby.update(v,dt)
		end
	end
	if #babbies == 0 then
		gamestate = 2
	end
	-- Update crystal rotation
	for i,v in ipairs(crystals) do
		v.dir = v.dir + dt
	end
	-- Update crystal spawns
	next_crystal = next_crystal - dt
	if next_crystal < 0 then
		addCrystals(1)
		next_crystal = CRYSTAL_RESPAWN_TIME
	end
	-- NOTE: METEORS MUST BE UPDATED BEFORE PLAYER
	-- Update meteors
	for i,v in ipairs(meteors) do
		local status = Meteor.update(v,dt)
		if v.x-16 < 0 or v.x+16 > MAPWIDTH
		or v.y-16 < 0 or v.y+16 > MAPHEIGHT then
			table.remove(meteors,i)
		end
		if status == false then
			table.remove(meteors,i)
		end
		-- if meteor has been grabbed, check collision with other meteors
		if v.beenGrabbed == true then
			for	im,vm in ipairs(meteors) do
				if i ~= im and
				math.pow(v.x-vm.x,2)+math.pow(v.y-vm.y,2) < 400 then
					if i == p.grabbed or im == p.grabbed then
						auExplosion:play()
						p.grabbed = nil
						p.hook = 0
					end
					vm.x = -100
					v.x = -100
					break
				end
			end
		end
	end
	-- Update wave timer
	next_wave = next_wave - dt
	if math.floor(next_wave) == 2 then
		auAlarm:play()
	elseif next_wave < 0 then
		spawnMeteorWave()
		next_wave = WAVE_TIME
	end
	-- Update player
	Player.update(p,dt)
	energy = energy-0.75*dt
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(SCALE)
	love.graphics.translate(WIDTH/2-p.x,HEIGHT/2-p.y)
	love.graphics.setColor(255,255,255,255)
	love.graphics.setLineStyle("rough")

	-- Draw black holes
	love.graphics.setColor(255,255,255,255)
	for i,v in ipairs(holes) do
		Hole.draw(v)
	end
	-- Draw planet
	love.graphics.draw(imgPlanet,MAPWIDTH/2-100,MAPHEIGHT/2-100)
	-- Draw babbies
	for i,v in ipairs(babbies) do
		Babby.draw(v)
	end
	-- Draw crystals
	for	i,v in ipairs(crystals) do
		love.graphics.draw(imgCrystal,v.x,v.y,v.dir,1,1,16,16)
	end
	-- Draw borders
	love.graphics.setLineWidth(100)
	love.graphics.setColor(0,0,0,255)
	love.graphics.circle("line",MAPWIDTH/2,MAPHEIGHT/2,MAPRADIUS,64)
	love.graphics.setColor(10,10,10,255)
	love.graphics.circle("line",MAPWIDTH/2,MAPHEIGHT/2,MAPRADIUS+5,64)
	love.graphics.setColor(20,20,20,255)
	love.graphics.circle("line",MAPWIDTH/2,MAPHEIGHT/2,MAPRADIUS+15,64)
	love.graphics.setColor(30,30,30,255)
	love.graphics.circle("line",MAPWIDTH/2,MAPHEIGHT/2,MAPRADIUS+20,64)
	-- Draw player
	Player.draw(p)
	-- Draw meteors
	for i,v in ipairs(meteors) do
		quad = love.graphics.newQuad(v.sprite*32,0,32,32,64,64)
		love.graphics.drawq(imgMeteor,quad,v.x,v.y,v.dir,1,1,16,16)
	end
	-- Draw mini map
	love.graphics.pop()
	drawMinimap()
	-- Draw energy bar
	love.graphics.setColor(0,0,0,200)
	love.graphics.rectangle("fill",20,HEIGHT*SCALE-48,408,28)
	if energy > 0 then
		love.graphics.setColor(90,200,80,255)
		love.graphics.rectangle("fill",24,HEIGHT*SCALE-44,energy*4,20)
	end
	if gamestate == 1 then
		love.graphics.setColor(0,0,0,200)
		love.graphics.rectangle("fill",0,0,WIDTH*SCALE,HEIGHT*SCALE)
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf("You were lost in space...\nPress R to restart",WIDTH/2,HEIGHT+32,WIDTH,"center")
	elseif gamestate == 2 then
		love.graphics.setColor(0,0,0,200)
		love.graphics.rectangle("fill",0,0,WIDTH*SCALE,HEIGHT*SCALE)
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf("You've failed to protect your children...\nPress R to restart",WIDTH/2,HEIGHT+32,WIDTH,"center")
	end
end

function drawMinimap()
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
	love.graphics.setColor(110,70,25,255)
	for i,v in ipairs(meteors) do
		love.graphics.circle("fill",MMX+v.x*MMOFFX,MMY+v.y*MMOFFY,2,4)
	end
	love.graphics.setColor(150,205,110,255)
	love.graphics.circle("fill",MMX+MMW/2,MMY+MMW/2,5,4)
	love.graphics.setColor(20,160,240,255)
	love.graphics.circle("fill",MMX+p.x*MMOFFX-1,MMY+p.y*MMOFFY-1,3,4)
end

function love.keypressed(k)
	if k == 'r' then
		newGame()
	end
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
	imgBabby = love.graphics.newImage("gfx/babby.png")
	imgBabby:setFilter("nearest","nearest")

	auNoise = love.audio.newSource("sfx/noise.ogg","stream")
	auNoise:setLooping(true)
	love.audio.play(auNoise)
	auPickup = love.audio.newSource("sfx/powerup.wav","static")
	auWoop = love.audio.newSource("sfx/woop.wav","static")
	auAlarm = love.audio.newSource("sfx/alarm.wav","static")
	auExplosion = love.audio.newSource("sfx/explosion.wav","static")
	auGrab = love.audio.newSource("sfx/grab.wav","static")
	auBabby = love.audio.newSource("sfx/babby.wav","static")

	messageFont = love.graphics.newFont(32)
	love.graphics.setFont(messageFont)
end
