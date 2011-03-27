-- TODO: Add ability to push meteors by using shift+w
P_ACC = 4
P_ROTACC = 4

Player = { }

function Player.create(x,y)
	local self = {}
	self.x = x
	self.y = y
	self.xspeed = 0
	self.yspeed = 0
	self.dir = 0
	self.gogopowerrangers = 0 -- rocket power state
	self.hook = 0
	self.grabbed = nil
	return self
end

function Player.update(self,dt)
	-- Hook coords for later use
	local hx = self.x+math.cos(self.dir)*self.hook
	local hy = self.y+math.sin(self.dir)*self.hook 
	-- Check if meteor has been destroyed somehow
	if meteors[self.grabbed] == nil then
		self.grabbed = nil
	end
	-- Handle keyboard input
	self.gogopowerrangers = 0
	if love.keyboard.isDown('a') then self.dir = self.dir - dt*P_ROTACC end
	if love.keyboard.isDown('d') then self.dir = self.dir + dt*P_ROTACC end
	if love.keyboard.isDown('w') and energy > 0 then
		self.gogopowerrangers = 1
		self.xspeed = self.xspeed + math.cos(self.dir)*P_ACC
		self.yspeed = self.yspeed + math.sin(self.dir)*P_ACC
		energy = energy-2*dt
		if love.keyboard.isDown("lshift") then
			self.gogopowerrangers = 2
			self.xspeed = self.xspeed + math.cos(self.dir)*P_ACC*2
			self.yspeed = self.yspeed + math.sin(self.dir)*P_ACC*2
			energy = energy-8*dt
		end
	end
	if love.keyboard.isDown(' ') then
		if self.hook == 0 then self.hook = 0.1
			auGrab:stop()
			auGrab:play()
		end
	else
		if self.grabbed ~= nil then
			meteors[self.grabbed].speed = math.sqrt(math.pow(self.xspeed,2)+math.pow(self.yspeed,2))
			meteors[self.grabbed].dir = self.dir
			self.grabbed = nil
		end
		self.hook = 0
	end
	-- update hook
	if self.hook > 0 then
		self.hook = self.hook + 350*dt
	end
	if self.hook > 150 then self.hook = 150 end
	-- Check if meteor is grabbed
	if self.grabbed == nil and self.hook > 0 then
		for i,v in ipairs(meteors) do
			local dist = math.pow(hx-v.x,2)+math.pow(hy-v.y,2)
			if dist < 400 then
				self.grabbed = i
				meteors[i].beenGrabbed = true
				break
			end
		end
	elseif meteors[self.grabbed] ~=nil then
		meteors[self.grabbed].x = hx
		meteors[self.grabbed].y = hy
		meteors[self.grabbed].dir = self.dir
	end
	-- Apply pull from nearby black holes
	local min_dist = MAPWIDTH
	for i,v in ipairs(holes) do
		local xdist = self.x-v.x
		local ydist = self.y-v.y
		local dist = math.sqrt(math.pow(xdist,2)+math.pow(ydist,2))
		if dist < min_dist then min_dist = dist end
		if dist < math.pow(v.r,2) then
			local adist = math.pow(v.r,2) - dist
			local xeffect = xdist/dist*adist*dt
			local yeffect = ydist/dist*adist*dt
			self.xspeed = self.xspeed - xeffect
			self.yspeed = self.yspeed - yeffect
		end
	end
	-- Adjust volume of black hole noise
	local vol = 0
	if min_dist < MAPWIDTH/4 then
		vol = 1-(min_dist/(MAPWIDTH/4))
	end
	auNoise:setVolume(vol)

	-- Check collision with crystals
	for i,v in ipairs(crystals) do
		if math.pow(self.x-v.x,2)+math.pow(self.y-v.y,2) < 500 then
			table.remove(crystals,i)
			auPickup:play()
			energy = energy+25
			if energy > 100 then energy = 100 end
		end
	end
	-- Move 
	self.x = self.x + self.xspeed * dt
	self.y = self.y + self.yspeed * dt
	-- Check dist from center of map
	local cdist = math.sqrt(math.pow(MAPWIDTH/2-p.x,2)+math.pow(MAPHEIGHT/2-p.y,2))
	if cdist > MAPRADIUS then
		gamestate = 1
		energy = 0
	end
	-- Check player boundaries
	--[[
	if self.x-16 < 0 then
		self.x = 16
		self.xspeed = 0.2*math.abs(self.xspeed)
	end
	if self.x+16 > MAPWIDTH then
		self.x = MAPWIDTH-16	
		self.xspeed = 0.2*-math.abs(self.xspeed)
	end
	if self.y-16 < 0 then
		self.y = 16
		self.yspeed = 0.2*math.abs(self.yspeed)
	end
	if self.y+16 > MAPHEIGHT then
		self.y = MAPHEIGHT-16
		self.yspeed = 0.2*-math.abs(self.yspeed)
	end
	--]]
end

function Player.draw(self)
	local hx = self.x+math.cos(self.dir)*self.hook
	local hy = self.y+math.sin(self.dir)*self.hook
	love.graphics.setColor(0,0,0,255)
	love.graphics.setLineWidth(5)
	love.graphics.line(self.x,self.y,hx,hy)
	love.graphics.setColor(128,128,128,255)
	love.graphics.setLineWidth(1)
	love.graphics.line(self.x,self.y,hx,hy)

	love.graphics.setColor(255,255,255,255)
	if self.hook > 10 then
		local quad = love.graphics.newQuad(0,32,8,8,96,96)
		love.graphics.drawq(imgPlayer,quad,hx,hy,self.dir,1,1,4,4)
	end
	local quad = love.graphics.newQuad(self.gogopowerrangers*32,0,32,32,96,96)
	love.graphics.drawq(imgPlayer,quad,self.x,self.y,self.dir,1,1,16,16)
end
