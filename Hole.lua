Hole = {}

function Hole.create(x,y,r,particles)
	local self = {}
	self.x = x
	self.y = y
	self.r = r
	self.particles = particles
	return self
end

function Hole.update(self,dt)
	-- Don't update holes outside the screen
	if math.sqrt(math.pow(p.x-self.x,2)+math.pow(p.y-self.y,2)) > HALFDIST+math.pow(self.r,2) then
		return
	end

	for ip,p in ipairs(self.particles) do
		p.angle = p.angle + 2*dt
		if p.angle > 2*math.pi then p.angle = 0 end
		p.dist = p.dist - 100*dt
		if p.dist < 0 then
			p.dist = math.pow(self.r,2)
			p.angle = math.random()*2*math.pi
		end
	end
end

function Hole.draw(self)
	-- Don't draw holes outside the screen
	if math.sqrt(math.pow(p.x-self.x,2)+math.pow(p.y-self.y,2)) > HALFDIST+math.pow(self.r,2) then
		return
	end

	local scale = self.r/16
	for ip,p in ipairs(self.particles) do
		local px = self.x + math.cos(p.angle)*p.dist
		local py = self.y + math.sin(p.angle)*p.dist
		love.graphics.rectangle("fill",px-1,py-1,2,2)
	end
	love.graphics.setLineWidth(5)
	love.graphics.setColor(0,0,0,255)
	love.graphics.circle("fill",self.x,self.y,self.r,32)
	love.graphics.setColor(255,255,255,255)
	love.graphics.circle("line",self.x,self.y,self.r,32)
end

function addBlackHoles(n)
	for i=1,n do
		local rdist = 750+math.random(MAPRADIUS-750)
		local rangle = math.random()*2*math.pi
		local x = MAPWIDTH/2+math.cos(rangle)*rdist
		local y = MAPHEIGHT/2+math.sin(rangle)*rdist
		local r = math.random(10)+10
		local particles = {}
		for p=1,math.sqrt(2*rdist) do
			local particle = {}
			particle.dist = math.random()*math.pow(r,2)
			particle.angle = math.random()*2*math.pi
			table.insert(particles,particle)
		end
		h = Hole.create(x,y,r,particles)
		table.insert(holes,h)
	end
end
