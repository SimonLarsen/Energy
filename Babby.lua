PLANET_DIST = 100

Babby = {}

babby_frame = 0

function Babby.create(t,angle)
	local self = {}		
	self.t = t
	self.angle = angle
	self.x = MAPWIDTH/2+math.cos(angle)*PLANET_DIST
	self.y = MAPHEIGHT/2+math.sin(angle)*PLANET_DIST
	self.alive = true
	return self
end

function Babby.draw(self)
	if self.alive == true then
		local quad = love.graphics.newQuad(math.floor(babby_frame)*16,self.t*16,16,16,64,64)
		love.graphics.drawq(imgBabby,quad,self.x,self.y,math.pi/2+self.angle,1,1,8,8)
	end
end

function Babby.update(self,dt)
	-- Update position
	self.angle = self.angle + (1-(self.t/10))*dt
	if self.angle > 2*math.pi then self.angle = 0 end
	self.x = MAPWIDTH/2+math.cos(self.angle)*PLANET_DIST
	self.y = MAPHEIGHT/2+math.sin(self.angle)*PLANET_DIST

	-- check collision with meteors 
	for i,v in ipairs(meteors) do
		local dist = math.pow(self.x-v.x,2)+math.pow(self.y-v.y,2)
		if dist < 250 then
			auBabby:stop()
			auBabby:play()
			self.alive = false
		end
	end
end

function addBabbies()
	for i=1,4 do
		local babby = Babby.create(i-1,(i-1)*(math.pi/2))
		table.insert(babbies,babby)
	end
end
