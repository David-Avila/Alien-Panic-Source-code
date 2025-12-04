enemy = new Sprite
enemy.image = file.loadImage("./assets/ph.png")

enemy.scale = [1, 1]

walkAnim = file.loadImage("./assets/enemy_walk.png")
deadAnim = file.loadImage("./assets/enemy_death.png")

enemy.walkFrames = []

enemy.animSpeed = 0.09

enemy.nextFrame = false

enemy.currentFrame = 0
enemy.vel = null
enemy.gravity = 48

for i in range(0, 9)
	enemy.walkFrames.push walkAnim.getImage(128 * i, 0, 128, 128)
end for

enemy.deadFrames = []

for i in range(0, 9)
	enemy.deadFrames.push deadAnim.getImage(128 * i, 0, 128, 128)
end for

enemy.speed = 3

enemy.hp = 2
enemy.dead = null
enemy.target = null

enemy.init = function
	super.init

	self.dead = false

	self.target = new Vec2
	self.target.x = self.x
	self.target.y = self.y

	self.dir = new Vec2
	self.vel = new Vec2


	self.localBounds.width = 90	
	self.localBounds.height = 90

	self.currentFrame = 0
	self.startTimer self.animSpeed, "nextFrame", true

	if self.x < 0 then self.dir.x = 1
	if self.x > 960 then self.dir.x = -1

	enemies.push self
	SPD.sprites.push self
end function

enemy.update = function(dt)
	if self.nextFrame then
		self.currentFrame += 1

		if self.dead and self.currentFrame == 5 then enemyDead.play 0.7

		if self.currentFrame >= self.deadFrames.len then 
			self.currentFrame = 0

			if self.dead then
				self.destroy
				return
			end if
		end if

		if self.dead then
			self.image = self.deadFrames[self.currentFrame]
		else
			self.image = self.walkFrames[self.currentFrame]
		end if 

		self.startTimer self.animSpeed, "nextFrame", true
		self.nextFrame = false
	end if

	if self.dead then return

	//UID.fillRect self.worldBounds.x - self.worldBounds.width/2, self.worldBounds.y-self.worldBounds.height/2,self.worldBounds.width,self.worldBounds.height, color.green

	if self.dir.x > 0 then
		if self.x > 910 then self.dir.x = -1
	else
		if self.x < 50 then self.dir.x = 1
	end if

	self.target.x += self.speed * self.dir.x

	self.x = merp.lerp(self.x, self.target.x, self.speed * dt)
	self.y += self.vel.y

	self.scale = [sign(self.dir.x), 1]

	for b in bullets
		if b.worldBounds.overlaps(self.worldBounds) then

			p = new Part
			p.x = self.x
			p.y = self.y

			t = "-" + b.damage
			p.image = textToImage(t, 2)

			p.dir = new Vec2
			p.dir.x = 0
			p.dir.y = 1

			p.speed = 5

			p.init 0.3

			self.hp -= b.damage
			b.destroy true
		end if
	end for

	if self.worldBounds.overlaps(FLOOR.worldBounds) then
		self.y = FLOOR.y + FLOOR.worldBounds.height - 16
		self.vel.y = 0
	else
		collided = false

		for p in PLATS
			if self.worldBounds.overlaps(p.worldBounds) then
				self.vel.y = 0
				collided = true
				self.y = p.y + p.worldBounds.height + 14
			end if
		end for

		if not collided then
			self.vel.y -= self.gravity * dt
		end if
	end if

	if self.hp <= 0 then 
		self.dead = true
		self.currentFrame = 0
	end if
end function

enemy.destroy = function
	enemies.removeVal self
	SPD.sprites.removeVal self
end function
