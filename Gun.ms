
bullet = new Sprite
bullet.image = file.loadImage("./assets/bullet.png")

bullet.target = null
bullet.speed = 35
bullet.dir = null
bullet.delete = null
bullet.damage = null

bullet.init = function(dam=1)
	super.init

	self.damage = dam

	self.scale = 1

	self.target = new Vec2
	self.target.x = self.x
	self.target.y = self.y

	
	self.localBounds.width *= 2
	self.localBounds.height *= 0.7

	p = new Vec2
	p.x = self.x 
	p.y = self.y

	angle = p.angleTo([self.x - self.dir.x, self.y - self.dir.y])

	self.rotation = angle

	self.delete = false
	self.startTimer 1, "delete", true

	bullets.push self
	SPD.sprites.push self
end function

bullet.update = function(dt)
	if false then
		p = new Part
		p.x = self.x + rnd * 32 - 16
		p.y = self.y + rnd * 32 - 16
		p.scale = 1 + rnd
		p.color = [100+rnd*40-20,100+rnd*40-20,100+rnd*40-20]
		p.speed = 0

		p.init 0.1
	end if

	self.target.x += self.speed * self.dir.x
	self.target.y += self.speed * self.dir.y

	//UID.fillRect self.worldBounds.x - self.worldBounds.width/2, self.worldBounds.y-self.worldBounds.height/2,self.worldBounds.width,self.worldBounds.height, color.green

	self.x = merp.lerp(self.x, self.target.x, self.speed * dt)
	self.y = merp.lerp(self.y, self.target.y, self.speed * dt)

	if self.worldBounds.overlaps(FLOOR.worldBounds) then self.destroy(true)

	if self.x < -64 then self.destroy
	if self.x > 1000 then self.destroy
	if self.y < -64 then self.destroy
	if self.y > 700 then self.destroy

	if self.delete then self.destroy
end function

bullet.destroy = function(p=false)
	if p then particleBurst self.x, self.y

	self.localBounds = null
	bullets.removeVal self
	SPD.sprites.removeVal self
end function

gun = new Sprite

gun.x = 480
gun.y = 320

gun.scale = [1,1]

gun.image = file.loadImage("./assets/weapon.png")

gun.target = null
gun.offset = null

gun.init = function
	self.offset = new Vec2
	self.offset.y = -20

	self.x = self.target.x
	self.y = self.target.y

	super.init
	
	updatedSprites.push self
	SPD.sprites.push self
end function

gun.update = function(dt)
	if self.target != null then
		self.x = self.target.x + self.offset.x
		self.y = self.target.y + self.offset.y
	end if

	p = new Vec2
	p.x = self.x
	p.y = self.y

	self.rotation = p.angleTo([mouse.x, mouse.y])

	scl = 0.7

	if mouse.x < self.x then
		self.scale = [scl, -scl]
	else
		self.scale = [scl, scl]
	end if

end function

gun.destroy = function
	updatedSprites.removeVal self
	SPD.sprites.removeVal self
end function