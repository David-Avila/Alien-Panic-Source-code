import "listUtil"

Sprite._timers = null
Sprite.startTimer = function(duration, prop, value)
	t = {}
	t.time = time + duration
	t.prop = prop
	t.value = value
	self._timers.push t
end function
Sprite.init = function
	self.localBounds = new Bounds

	self.localBounds.width = 20
	self.localBounds.height = 20

	self._timers = []
end function

Sprite.update = function(dt)
end function

Sprite.process = function(dt)
	for t in self._timers
		if t.time != null then
			if time >= t.time then
				self[t.prop] = t.value
				t.time = null
				self._timers.removeVal t
			end if
		else
			self._timers.removeVal t
		end if
	end for
	
	self.update dt
end function
