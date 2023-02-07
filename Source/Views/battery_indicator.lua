class('BatteryIndicator').extends(playdate.graphics.sprite)

function BatteryIndicator:init(x, y, font)
	BatteryIndicator.super.init(self)
	
	self.font = font
	self:redraw()
	self:moveTo(x, y)
	self:add()
	
	self.timer = playdate.timer.new(30000, function()
		self:redraw()
	end)--every 30 seconds
	self.timer.repeats = true
end

function BatteryIndicator:show()
	self:setVisible(true)
end

function BatteryIndicator:hide()
	self:setVisible(false)
end

function BatteryIndicator:redraw()
	local image = playdate.graphics.image.new(80, 36)
	playdate.graphics.pushContext(image)
		playdate.graphics.fillRoundRect(5, 3, 25, 14, 3)
		playdate.graphics.fillRect(28, 7, 4, 6)
		self.font:drawText(self:getText(), 34, 0)
	playdate.graphics.popContext()
	
	self:setImage(image)
end

function BatteryIndicator:getText()
	return "" .. math.floor(playdate.getBatteryPercentage()) .."%"
end