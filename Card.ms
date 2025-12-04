effects = ["damage", "firerate", "move_speed"]

cards = []
for ef in effects
	t = "./assets/upgrades/" + ef + ".png"
	cards.push file.loadImage(t)
end for

card = new Sprite

card.id = null
card.scale = SCALE
card.x  = 480

card.startY = 0
card.targetY = 0

card.init = function
	self.image = cards[self.id]
	
	self.targetY = self.y + 700
	self.startY = self.y

	super.init

	self.localBounds = new Bounds
	self.localBounds.width *= 2
	self.localBounds.height /= 2

	SPD.sprites.push self
	updatedSprites.push self
end function

card.update = function(dt)
	
	self.y = merp.lerp(self.y, self.targetY, 25 * dt)

	if self.worldBounds.contains([mouse.x, mouse.y]) then
		self.scale = SCALE + 0.2

		if keyPressed("mouse 0") then
			spawner.rumble(effects[self.id])
		end if
	else
		self.scale = SCALE
	end if

end function

card.destroy = function
	// Start Rumble

	SPD.sprites.removeVal self
end function