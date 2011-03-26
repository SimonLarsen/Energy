Player = { }

function Player.create(x,y)
	local self = {}
	self.x = x
	self.y = y
	self.xspeed = 0
	self.yspeed = 0
	self.dir = 0
	self.gogopowerrangers = false
	self.frame = 0
	return self
end

function Player.update(self,dt)
	-- Handle keyboard input
	self.gogopowerrangers = false
	if love.keyboard.isDown('a') then self.dir = self.dir - dt*P_ROTACC end
	if love.keyboard.isDown('d') then self.dir = self.dir + dt*P_ROTACC end
	if love.keyboard.isDown('w') then
		self.xspeed = self.xspeed + math.cos(self.dir)*P_ACC
		self.yspeed = self.yspeed + math.sin(self.dir)*P_ACC
		self.gogopowerrangers = true
		energy = energy-2*dt
	end
	-- Apply pull from nearby black holes
	for i,v in ipairs(holes) do
		local xdist = self.x-v.x
		local ydist = self.y-v.y
		local dist = math.sqrt(math.pow(xdist,2)+math.pow(ydist,2))
		if dist < math.pow(v.r,2) then
			adist = math.pow(v.r,2) - dist
			xeffect = xdist/dist*adist*dt
			yeffect = ydist/dist*adist*dt
			self.xspeed = self.xspeed - xeffect
			self.yspeed = self.yspeed - yeffect
		end
	end
	-- Check collision with crystals
	for i,v in ipairs(crystals) do
		if math.pow(self.x-v.x,2)+math.pow(self.y-v.y,2) < 220 then
			table.remove(crystals,i)
			energy = energy+25
			if energy > 100 then energy = 100 end
		end
	end
	-- Move 
	self.x = self.x + self.xspeed * dt
	self.y = self.y + self.yspeed * dt
	-- Check player boundaries
	if self.x-16 < 0 then
		self.x = 16
		self.xspeed = math.abs(self.xspeed)
	end
	if self.x+16 > MAPWIDTH then
		self.x = MAPWIDTH-16	
		self.xspeed = -math.abs(self.xspeed)
	end
	if self.y-16 < 0 then
		self.y = 16
		self.yspeed = math.abs(self.yspeed)
	end
	if self.y+16 > MAPHEIGHT then
		self.y = MAPHEIGHT-16
		self.yspeed = -math.abs(self.yspeed)
	end
	self.frame = (self.frame + 10*dt) % 2
end

function Player.draw(self)
	love.graphics.setColor(255,255,255,255)
	if self.gogopowerrangers == false then
		quad = love.graphics.newQuad(0,0,32,32,96,96)
	else
		quad = love.graphics.newQuad((math.floor(self.frame)+1)*32,0,32,32,96,96)
	end
	love.graphics.drawq(imgPlayer,quad,self.x,self.y,self.dir,1,1,16,16)
end
