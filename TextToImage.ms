_chars = {}
_chars["a"] = 0
_chars["b"] = 1
_chars["c"] = 2
_chars["d"] = 3
_chars["e"] = 4
_chars["f"] = 5
_chars["g"] = 6
_chars["h"] = 7
_chars["i"] = 8
_chars["j"] = 9
_chars["k"] = 10
_chars["l"] = 11
_chars["m"] = 12
_chars["n"] = 13
_chars["o"] = 14
_chars["p"] = 15
_chars["q"] = 16
_chars["r"] = 17
_chars["s"] = 18
_chars["t"] = 19
_chars["u"] = 20
_chars["v"] = 21
_chars["w"] = 22
_chars["x"] = 23
_chars["y"] = 24
_chars["z"] = 25
_chars["A"] = 26
_chars["B"] = 27
_chars["C"] = 28
_chars["D"] = 29
_chars["E"] = 30
_chars["F"] = 31
_chars["G"] = 32
_chars["H"] = 33
_chars["I"] = 34
_chars["J"] = 35
_chars["K"] = 36
_chars["L"] = 37
_chars["M"] = 38
_chars["N"] = 39
_chars["O"] = 40
_chars["P"] = 41
_chars["Q"] = 42
_chars["R"] = 43
_chars["S"] = 44
_chars["T"] = 45
_chars["U"] = 46
_chars["V"] = 47
_chars["W"] = 48
_chars["X"] = 49
_chars["Y"] = 50
_chars["Z"] = 51
_chars["0"] = 52
_chars["1"] = 53
_chars["2"] = 54
_chars["3"] = 55
_chars["4"] = 56
_chars["5"] = 57
_chars["6"] = 58
_chars["7"] = 59
_chars["8"] = 60
_chars["9"] = 61
_chars["space"] = 62
_chars["exclamation"] = 63
_chars["colon"] = 64
_chars["forward_slash"] = 65
_chars["dash"] = 66
_chars["."] = 67


_buffer = new PixelDisplay

globals.textToImage = function(text, scale=4, spacing=10)
	_buffer.clear
	
	if globals.hasIndex("invertColors") then
		if invertColors == 0 then
			_img = file.loadImage("./assets/font.png")
		else
			_img = file.loadImage("./assets/font-inv.png")
		end if
	else
		_img = file.loadImage("./assets/font.png")
	end if

	i = 0
	for txt in text
		t = txt
		if txt == " " then
			t = "space"
		else if txt == "!" then
			t = "exclamation"
		else if txt == ":" then
			t = "colon"
		else if txt == "/" then
			t = "forward_slash"
		else if txt == "-" then
			t = "dash"
		end if
		
		_buffer.drawImage _img, spacing * scale * i, 0, 16 * scale, 18 * scale, _chars[t] * 16, 0, 16,18
		i += 1
	end for
	
	return _buffer.getImage(0,0,(text.len+1) * (spacing) * scale, 18 * scale)
end function
