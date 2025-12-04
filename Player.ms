import "Gun"

walkAnim = file.loadImage("./assets/player-walk.png")
idleAnim = file.loadImage("./assets/player-idle.png")
deadAnim = file.loadImage("./assets/player_death.png")

player = new Sprite

player.x = 480
player.y = 260

player.targetX = 480

player.image = file.loadImage("./assets/ph.png")

player.idleFrames = []

for i in range(0, 7)
	player.idleFrames.push idleAnim.getImage(128 * i, 0, 128, 128)
end for

player.walkFrames = []

for i in range(0, 16)
	player.walkFrames.push walkAnim.getImage(128 * i, 0, 128, 128)
end for

player.deadFrames = []

for i in range(0, 11)
	player.deadFrames.push deadAnim.getImage(128 * i, 0, 128, 128)
end for

player.jumpFrames = [file.loadImage("./assets/player-jump.png")]

player.animSpeed = 0.035

player.nextFrame = false

player.currentFrame = 0
player.currentAnim = null

player.scale = [1, 1]

player.moveSpeed = 5

player.moveAccel = 15
player.moveFricc = 10

player.groundAccel = 15
player.groundFricc = 10

player.airAccel = 5
player.airFricc = 2.5

player.canJump = true
player.jumpPower = 15
player.gravity = 48

player.dir = 1
player.vel = new Vec2

player.targetScale = 1
player.tempScale = 1

player.fireRate = 0.2
player.canShoot = true
player.damage = 1

player.invincible = false
player.gun = null

player.hp = 5
player.dead = false

player.dontAnimate = false

player.init = function
	super.init
	
	globals.PLAYER = self

	self.hp = 5

	updatedSprites.push self
	SPD.sprites.push self

	self.currentFrame = 0
	self.currentAnim = self.idleFrames
	self.startTimer self.animSpeed, "nextFrame", true

	self.localBounds = new Bounds
	self.localBounds.width *= 0.5

	g = new Gun.gun
	g.target = self
	g.init

	self.gun = g
end function

player.update = function(dt)
	if self.dontAnimate then return

	if self.dead then 
		if self.currentAnim != self.deadFrames then
			self.currentAnim = self.deadFrames
			self.currentFrame = -1
		end if

		if self.nextFrame then
			self.currentFrame += 1

			if self.currentFrame >= self.currentAnim.len then 
				self.currentFrame = 0
				self.dontAnimate = true
				tran.start @Reload
				return
			end if

			self.image = self.currentAnim[self.currentFrame]

			self.animSpeed = 0.035

			self.startTimer self.animSpeed, "nextFrame", true
			self.nextFrame = false
		end if
		return
	end if

	if self.canJump then
		if abs(self.vel.x) > 1 then
			if self.currentAnim != self.walkFrames then
				self.currentAnim = self.walkFrames
				self.currentFrame = -1
			end if

			if self.nextFrame then
				self.currentFrame += 1

				if self.currentFrame >= self.currentAnim.len then self.currentFrame = 0

				self.image = self.currentAnim[self.currentFrame]

				self.animSpeed = 0.035

				self.startTimer self.animSpeed, "nextFrame", true
				self.nextFrame = false
			end if
		else
			if self.currentAnim != self.idleFrames then
				self.currentAnim = self.idleFrames
				self.currentFrame = -1
			end if

			if self.nextFrame then
				self.currentFrame += 1


				self.animSpeed = 0.04

				if self.currentFrame >= self.currentAnim.len then self.currentFrame = 0

				self.image = self.currentAnim[self.currentFrame]

				self.startTimer self.animSpeed, "nextFrame", true
				self.nextFrame = false
			end if
		end if
	else
		self.currentAnim = self.jumpFrames
		self.currentFrame = -1

		self.image = self.jumpFrames[0]
	end if

	xmov = key.axis("Horizontal")

	if xmov > 0 and self.x >= 950 then 
		xmov = 0
		self.vel.x = 0
		self.x = 950
	end if

	if xmov < 0 and self.x <= 10 then 
		xmov = 0
		self.vel.x = 0
		self.x = 10
	end if

	//UID.fillRect self.worldBounds.x - self.worldBounds.width/2, self.worldBounds.y-self.worldBounds.height/2,self.worldBounds.width,self.worldBounds.height, color.green

	self.dir = sign(mouse.x - self.x)

	if xmov != 0 then
		self.tempScale = sign(xmov)
	end if

	self.targetScale = merp.lerp(self.targetScale, self.tempScale, 10 * dt)
	self.scale = [self.targetScale, 1]


	if not self.invincible then
		self.tint = color.white

		for en in enemies
			if en.worldBounds.overlaps(self.worldBounds) then
				self.invincible = true

				hurt.play 0.5, 0, 1.5

				self.hp -= 1
				self.startTimer 1, "invincible", false

				if self.hp <= 0 then
					self.dead = true
				end if

				shake 10
			end if
		end for
	else
		if frameCount % 2 == 0 then
			self.tint = color.red
		else
			self.tint = color.white
		end if
	end if

	if xmov != 0 then
		self.vel.x = merp.lerp(self.vel.x, xmov * self.moveSpeed, self.moveAccel * dt)
	else
		self.vel.x = merp.lerp(self.vel.x, 0, self.moveFricc * dt)
	end if

	if self.worldBounds.overlaps(FLOOR.worldBounds) then
		self.y = FLOOR.y + FLOOR.worldBounds.height - 8
		self.canJump = true
		self.vel.y = 0

		self.moveAccel = self.groundAccel
		self.moveFricc = self.groundFricc
	else
		self.vel.y -= self.gravity * dt

		self.moveAccel = self.airAccel
		self.moveFricc = self.airFricc
	end if

	if keyPressed("space") and self.canJump then
		self.canJump = false
		self.vel.y = self.jumpPower

		particleBurst self.x, self.y - 32, false, 3
	end if


	self.x += self.vel.x
	self.y += self.vel.y


	if STATE == "waiting" then return


	if keyDown("mouse 0") and self.canShoot then
		//Shoot
		b = new Gun.bullet

		off = new Vec2
		off.x = 48

		off.rotate self.gun.rotation

		b.x = self.gun.x + off.x
		b.y = self.gun.y + off.y

		b.dir = new Vec2
		b.dir.x = 1
		b.dir.y = 0

		shoot.play 0.5, 0, 1 + rnd - 0.4


		if mouse.x < self.gun.x then b.scale = [1, -1]
		
		particleBurst b.x, b.y

		randAngle = self.gun.rotation + rnd * 15 - 7.5

		b.dir.rotate(randAngle)

		b.init self.damage

		shake 2

		self.canShoot = false
		self.startTimer self.fireRate, "canShoot", true
	end if

end function

player.destroy = function
	globals.PLAYER = null

	updatedSprites.removeVal self
	SPD.sprites.removeVal self
end function