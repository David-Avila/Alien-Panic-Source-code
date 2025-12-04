clear

import "Particles"
import "Objects"
import "Vec2"
import "merp"
import "Input"
import "SpriteTimer"
import "TextToImage"

// Coment on release build
//import "AutoSafe"


updatedSprites = []
bullets = []
enemies = []

PLAYER = null
FLOOR = null
WHEEL = null
PLATS = []

Vec2 = Vec2.Vec2
SCALE = 2

MAXWAVE = 0

STATE = "logo"

SHAKE_X = 0
SHAKE_Y = 0
SHAKE_MAG = 0

shake = function(mag)	
	if mag > SHAKE_MAG then
		globals.SHAKE_MAG = mag
	end if
end function

particleBurst = function(x, y, m=false,amount = 2)
	for i in range(amount)
		p = new Part
	
		if m then
			p.speed = 5

			d = new Vec2
			d.x = mouse.x - x
			d.y = mouse.y - y

			d.normalize

			p.dir = d
		end if

		//p.color = [80+rnd*40-20,80+rnd*40-20,80+rnd*40-20]	

		p.alpha = 150

		p.rotation = (rnd * 360)

		p.scale = (1 + rnd)
		p.x = x + round(rnd * 64 - 32)
		p.y = y + round(rnd * 64 - 32)
		p.init 0.2
	end for
end function

display(7).color = color.rgb(10,10,20)
//display(3).mode = displayMode.sprite
display(2).mode = displayMode.pixel
display(1).mode = displayMode.sprite

display(2).clear

display(6).mode = displayMode.pixel

GFX = display(5)
SPD = display(4)
TXD = display(3)
TRD = display(1)

GFX.clear
SPD.clear

bgm = file.loadSound("./assets/bgMusic.wav")
bgm.loop = true
bgm.play 0.5

casino = file.loadSound("./assets/casino.wav")
casino.loop = false

hurt = file.loadSound("./assets/hurt.ogg")
hurt.loop = false

splash = file.loadSound("./assets/splash.wav")
splash.loop = false

shoot = file.loadSound("./assets/shoot.wav")
shoot.loop = false

good = file.loadSound("./assets/good.wav")
good.loop = false

bad = file.loadSound("./assets/bad.wav")
bad.loop = false

enemyDead = file.loadSound("./assets/enemy_dead.wav")
enemyDead.loop = false

// Imported Objects
import "Player"
import "Enemy"
import "Card"


logoTime = null
creditTime = null

Logo = function
	GFX.clear

	lg = file.loadImage("./assets/logo.png")

	display(6).drawImage lg, 0, 0, 960, 640

	if STATE == "logo" then
		globals.logoTime = time + 2
		globals.STATE = "credits"
	end if
end function

Credit = function
	display(6).clear

	lg = file.loadImage("./assets/credits.png")

	display(6).drawImage lg, 0, 0, 960, 640
	globals.creditTime = time + 2
end function

startBtn = new Sprite
startBtn.x = 480
startBtn.y = 240

startBtn.clicked = false
startBtn.image = file.loadImage("./assets/start.png")

startBtn.init = function
	super.init

	self.localBounds = new Bounds
	SPD.sprites.push self
	updatedSprites.push self
end function

startBtn.update = function(dt)
	if self.worldBounds.contains([mouse.x, mouse.y]) then
		self.scale = merp.lerp(self.scale, 1.2, 5 * dt)
		
		if keyPressed("mouse 0") then
			if not self.clicked then
				self.clicked = true

				tran.start @Reload
			end if
		end if
	else
		self.scale = merp.lerp(self.scale, 1, 5 * dt)	
	end if
end function

startBtn.destroy = function
	SPD.sprites.removeVal self
	updatedSprites.removeVal self
end function

Menu = function
	display(6).clear

	lg = file.loadImage("./assets/title.png")

	display(6).drawImage lg, 0, 0, 960, 640
	

	startBtn.init
end function

Reload = function
	globals.STATE = "game"

	display(6).clear
	updatedSprites = []
	bullets = []
	enemies = []

	globals.PLATS = []
	globals.FLOOR = null
	globals.PLAYER = null

	while SPD.sprites.len > 0
		SPD.sprites[0].destroy
	end while

	b = new backg
	b.init

	f = new floorr
	f.init

	pLeft = new platLeft
	pLeft.init

	pr = new platRight
	pr.init 

	pl = new Player.player
	pl.init

	spawner.init
end function


transition = file.loadImage("./assets/transition.png")
amount = round(transition.width / 960)

tran = new Sprite
tran.frames = []

for i in range(0, amount-1)
	tran.frames.push transition.getImage(960 * i, 0, 960, 640)
end for

tran.currentFrame = 0
tran.callBack = null

tran.delay = 5

tran.x = 480
tran.y = 320
tran.playing = false

tran.start = function(call)
	if not self.playing then
		self.playing = true
		self.callBack = @call
	end if
end function

tran.update = function(dt)
	if self.playing then
		if not splash.isPlaying then splash.play 0.4

		if self.delay <= 0 then
			self.delay = 5

			self.currentFrame += 1
			if self.currentFrame >= self.frames.len then 
				self.currentFrame = 0
				self.image = self.frames[self.currentFrame]
				self.playing = false
				return
			end if

			if self.currentFrame == 8 then
				self.callBack
				self.callBack = null
			end if

			self.image = self.frames[self.currentFrame]
		else
			self.delay -= 1
		end if
	end if
end function

TRD.sprites.push tran

backg = new Sprite
backg.image = file.loadImage("./assets/background.png")
backg.x = 480
backg.y = 320

backg.init = function
	super.init
	SPD.sprites.push self
end function

backg.destroy = function
	SPD.sprites.removeVal self
end function


floorr = new Sprite
floorr.image = file.loadImage("./assets/floor.png")
floorr.x = 480
floorr.y = 62

floorr.init = function
	super.init

	globals.FLOOR = self

	self.localBounds.width = 2000
	self.localBounds.height = 115

	SPD.sprites.push self
end function

floorr.destroy = function
	globals.FLOOR = null
	SPD.sprites.removeVal self
end function


platLeft = new Sprite
platLeft.image = file.loadImage("./assets/floor.png")
platLeft.tint = "#ffffff00"
platLeft.x = -90
platLeft.y = 400

platLeft.init = function
	super.init

	globals.PLATS.push self

	self.localBounds.width = 700
	self.localBounds.height = 48

	SPD.sprites.push self
end function

platLeft.destroy = function
	SPD.sprites.removeVal self
end function


platRight = new Sprite
platRight.image = file.loadImage("./assets/floor.png")
platRight.tint = "#ffffff00"
platRight.x = 1020
platRight.y = 470

platRight.init = function
	super.init

	globals.PLATS.push self

	self.localBounds.width = 700
	self.localBounds.height = 48

	SPD.sprites.push self
end function

platRight.destroy = function
	SPD.sprites.removeVal self
end function

//************************* SPAWNER
wheel = new Sprite
wheel.image = file.loadImage("./assets/wheel.png")
wheel.x = 480
wheel.y = -600

wheel.start = false
wheel.spinSpeed = 0

wheel.target = null
wheel.fx = null

wheel.waiting = false

wheel.init = function(fx)
	super.init

	globals.WHEEL = self

	self.target = self.y
	self.fx = fx

	self.waiting = false

	self.startTimer 1.3, "start", true

	SPD.sprites.push self
	updatedSprites.push self
end function

wheel.update = function(dt)
	if self.start then
		self.spinSpeed = 25

		self.startTimer 1.3 + rnd * 2.7, "spinSpeed", 0
		self.start = null
	end if

	if self.spinSpeed > 0 then
		if not casino.isPlaying then
			casino.play 0.5//, 0, 1 + rnd
		end if
	else
		if casino.isPlaying then casino.stop
	end if

	self.rotation += self.spinSpeed

	if self.rotation > 359 then
		self.rotation -= 359
	end if

	if self.spinSpeed == 0 and self.start == null then
		if self.waiting == false then
			self.startTimer 2, "waiting", null
			self.waiting = true

			if self.rotation > 50 and self.rotation < 170 then
				if self.fx == "damage" then
					PLAYER.damage *= 2
				else if self.fx == "firerate" then
					PLAYER.fireRate *= 0.5
				else if self.fx == "move_speed" then
					PLAYER.moveSpeed *= 2
				end if

				good.play 0.5
			else
				if self.fx == "damage" then
					PLAYER.damage *= 0.5
				else if self.fx == "firerate" then
					PLAYER.fireRate *= 2
				else if self.fx == "move_speed" then
					PLAYER.moveSpeed *= 0.5
				end if

				bad.play 0.5
			end if
		end if

		if self.waiting == null then 
			self.y = merp.lerp(self.y, self.target, 10 * dt)

			globals.STATE = "upgraded"

			if abs(self.y - self.target) < 5 then 
				self.destroy
			end if
		end if
	else
		self.y = merp.lerp(self.y, 320, 5 * dt)
	end if
end function

wheel.spin = function 
	self.start = true 
end function

wheel.destroy = function
	globals.WHEEL = null

	updatedSprites.removeVal self
	SPD.sprites.removeVal self
end function

arrow = new Sprite
arrow.image = file.loadImage("./assets/arrow.png")
arrow.x =  720
arrow.y = -600

arrow.init = function(fx)
	super.init

	SPD.sprites.push self
	updatedSprites.push self
end function

arrow.update = function(dt)
	if WHEEL != null then
		self.y = WHEEL.y
	else
		self.destroy
	end if
end function

arrow.destroy = function
	updatedSprites.removeVal self
	SPD.sprites.removeVal self
end function

spawner = new Sprite

spawner.buffer = new PixelDisplay

spawner.currentWave = 0
spawner.displayedWave = -1

spawner.enemies = 1
spawner.canSpawn = false

spawner.waiting = false

spawner.cards = null
spawner.enemyHealth = 2

spawner.displayedHp = 0

spawner.init = function
	super.init

	self.cards = []
	self.canSpawn = false

	self.enemyHealth = 2
	self.enemies = 1
	self.currentWave = 0

	updatedSprites.push self
	SPD.sprites.push self
end function

spawner.rumble = function(fx)
	for c in self.cards
		c.targetY = c.startY
	end for

	self.cards = []

	w = new wheel
	w.init fx

	a = new arrow
	a.init
end function

spawner.update = function(dt)
	if STATE == "upgrading" then
		for i in range(2)
			c = new Card.card

			c.id = i
			c.y = 500 - 150 * i - 700

			c.init

			self.cards.push c
		end for

		globals.STATE = "waiting"
		return
	else if STATE == "waiting" then
		return
	else if STATE == "upgraded" then
		self.canSpawn = true
		globals.STATE = "done"
	
	else if STATE == "done" or STATE == "game" then

		if self.canSpawn then
			self.spawn

			self.canSpawn = false
		else if self.canSpawn == false then
			if enemies.len == 0 then

				if self.currentWave % 2 == 0 and self.currentWave != 0 then
					if STATE != "done" then
						globals.STATE = "upgrading"
					end if
					return
				end if

				globals.STATE = "game"

				self.canSpawn = null
				self.startTimer 2, "canSpawn", true
			end if
		end if

		if PLAYER != null then
			if self.displayedWave != self.currentWave or self.displayedHp != PLAYER.hp then
				t = "Wave:" + self.currentWave
				img = textToImage(t, 2)

				t = "Max Wave:" + MAXWAVE
				m = textToImage(t, 2)

				t = "HP:" + PLAYER.hp
				h = textToImage(t, 2)


				self.displayedWave = self.currentWave
				self.displayedHp = PLAYER.hp

				self.buffer.clear
				self.buffer.drawImage img, 480 - img.width/2, 600 - img.height/2, img.width, img.height
				self.buffer.drawImage m, 480 - m.width/2, 550 - m.height/2, m.width, m.height
				self.buffer.drawImage h, 64 - h.width/2, 600 - h.height/2, h.width, h.height

				self.buffer.install 2
			end if
		end if
	end if
end function

spawner.spawn = function
	if not self.canSpawn then return

	for i in range(self.enemies)
		en = new Enemy.enemy
		if rnd < 0.5 then
			en.x = -(100 + rnd * 260)
		else
			en.x = 1000 + rnd * 260
		end if

		if rnd < 0.5 then
			en.y = 560
		else
			en.y = 260
		end if

		en.hp = self.enemyHealth

		en.init
	end for

	if self.currentWave % 3 == 0 then
		self.enemyHealth += 1
	end if

	self.canSpawn = false
	self.enemies += 2
	self.currentWave += 1
	if self.currentWave > MAXWAVE then globals.MAXWAVE = self.currentWave
end function

spawner.destroy = function
	updatedSprites.removeVal self
	SPD.sprites.removeVal self
end function
//***********************************

Logo

last = time
frameCount = 0
while true
	frameCount += 1
	dt   = time - last
	last = time


	for sp in TRD.sprites
		sp.update dt
	end for

	if logoTime != null then
		if time >= logoTime then
			tran.start @Credit
			logoTime = null
		end if
	end if

	if creditTime != null then
		if time >= creditTime then
			tran.start @Menu
			creditTime = null
		end if
	end if

	// Screen shake
	if SHAKE_MAG > 0 then
		SHAKE_X = SHAKE_MAG - rnd * (SHAKE_MAG * 2)
		SHAKE_Y = SHAKE_MAG - rnd * (SHAKE_MAG * 2)
		
		SHAKE_MAG -= (SHAKE_MAG * 0.4)
	else
		SHAKE_MAG = 0
		SHAKE_X = 0
		SHAKE_Y = 0
	end if

	SPD.scrollX = SHAKE_X
	SPD.scrollY = SHAKE_Y

	for sp in updatedSprites
		sp.process dt
	end for

	for en in enemies
		en.process dt
	end for

	for b in bullets
		b.process dt
	end for

	yield
end while

key.clear
TRD.clear
TRD.sprites = []

Sound.stopAll
