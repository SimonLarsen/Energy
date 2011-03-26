Crystal = {}

function Crystal.create(x,y)
	local self = {}
	self.x = x
	self.y = y
	self.dir = math.random()*2*math.pi
	return self
end

function addCrystals(n)
	for i=1,n do
		local rdist = 500+math.random(MAPRADIUS-500)
		local rangle = math.random()*2*math.pi
		local x = MAPWIDTH/2+math.cos(rangle)*rdist
		local y = MAPHEIGHT/2+math.sin(rangle)*rdist
		local crystal = Crystal.create(x,y)
		table.insert(crystals,crystal)
	end
end
