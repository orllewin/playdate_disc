class('Label').extends(playdate.graphics.sprite)

function Label:init(x, y, text, font, maxWidth)
	Label.super.init(self)
	
	self.font = font
	self.fontFamily = {
		 [playdate.graphics.font.kVariantNormal] = self.font,
		[playdate.graphics.font.kVariantBold] = self.font,
		[playdate.graphics.font.kVariantItalic] = self.font
	}
	self.text = text
	self.origX = x
	self.origY = y
	self.maxWidth = maxWidth
	self:redraw()
	self:add()
end

function Label:setText(text)
	if(self.text == text)then return end
	self.text = text
	self:redraw()
end

function Label:setMaxWidth(maxWidth)
	self.maxWidth = maxWidth
	self:redraw()
end

function Label:redraw()
	local width, height = playdate.graphics.getTextSize(self.text, self.fontFamily)
	local cWidth = math.min(width, self.maxWidth)
	local image = playdate.graphics.image.new(cWidth, height)
	playdate.graphics.pushContext(image)
		--self.font:drawText(self.text, 0, 0)
		playdate.graphics.drawTextInRect(self.text, 0, 0, cWidth, height, nil,  "...")
	playdate.graphics.popContext()
	self:moveTo(self.origX + cWidth/2, self.origY)
	self:setImage(image)
end