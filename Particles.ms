import "Vec2"
import "listUtil"
import "spriteControllers"

mt = @spriteControllers.moveTowards

globals.Part = new Sprite
Part.image = file.loadImage("particle.png")
Part.x = 0
Part.y = 0

Part.speed = 150
Part.dir = null
Part.applyGravity = false
Part.gravity = -240
Part.randomize = true
Part.alpha = 255
Part.vel= null
Part.despawnTime = 0
Part.onTime = false
Part.color = null
Part.instances = []

Part.disp = null
Part.factor = null

Part.init = function(duration = 1, disp=4)
	self.despawnTime = time + duration
	
	self.factor = self.alpha / (duration * 60)

	self.disp = disp

	Part.instances.push self
	updatedSprites.push self
	display(4).sprites.push self
end function

Part.update = function(dt)
	if time > self.despawnTime then 
		self.destroy
	end if
	
	if self.color != null then
		self.tint = color.rgba(self.color[0], self.color[1], self.color[2], self.alpha)
	else
		self.tint = color.rgba(255,255,255,self.alpha)
	end if

	if self.dir != null then
		self.x += self.dir.x * self.speed
		self.y += self.dir.y * self.speed
	end if

	if not self.onTime then
		self.alpha -= self.factor
		if self.alpha <= 0 then self.destroy
	end if
end function

Part.clear = function
	for p in Part.instances
		p.destroy
	end for
end function

Part.destroy = function
	Part.instances.removeVal self
	updatedSprites.removeVal self
	display(self.disp).sprites.removeVal self
end function