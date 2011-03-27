Meteor = {}

METEOR_SPEED = 125

function Meteor.create(x,y,dir)
	local self = {}
	self.x = x
	self.y = y
	self.dir = dir
	self.sprite = math.random(2)-1
	self.xspeed = 0
	self.xspeed = 0
	self.speed = METEOR_SPEED+math.random(41)-11
	self.beenGrabbed = false
	return self
end

function Meteor.update(self,dt)
	-- Update speed
	self.xspeed = math.cos(self.dir)*dt*self.speed
	self.yspeed = math.sin(self.dir)*dt*self.speed

	-- Apply force from any nearby black holes
	for i,v in ipairs(holes) do
		local xdist = self.x-v.x
		local ydist = self.y-v.y
		local dist = math.sqrt(math.pow(xdist,2)+math.pow(ydist,2))
		if dist < 10 then
			auWoop:play()
			return false
		elseif dist < math.pow(v.r,2) then
			local adist = math.pow(v.r,2) - dist
			local xeffect = xdist/dist*adist*dt
			local yeffect = ydist/dist*adist*dt
			self.xspeed = self.xspeed - xeffect
			self.yspeed = self.yspeed - yeffect
		end
	end

	self.x = self.x+self.xspeed
	self.y = self.y+self.yspeed
	return true
end

function spawnMeteorWave()
	local edge = math.random()*2*math.pi
	local dir = edge+math.pi

	for i=1,math.random(3)+1 do
		local cedge = edge + math.random()/5-0.125
		local cx = MAPWIDTH/2+math.cos(cedge)*0.99*MAPRADIUS
		local cy = MAPHEIGHT/2+math.sin(cedge)*0.99*MAPRADIUS
		local meteor = Meteor.create(cx,cy,dir)
		table.insert(meteors,meteor)
	end
end
