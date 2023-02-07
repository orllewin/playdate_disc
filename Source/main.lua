import 'CoreLibs/ui'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/nineslice'
import 'Coracle/coracle'
import 'Views/label'
import 'Views/battery_indicator'

invertDisplay()

playdate.setAutoLockDisabled(true)

local font = playdate.graphics.font.new("Fonts/Roobert-11-Medium")
playdate.graphics.setFont(font)

if playdate.file.exists("playlist.json") then
	print("found playlist.json")
else
	print("playlist.json not found")
end

local file = playdate.file.open("playlist.json")
local size = playdate.file.getSize("playlist.json")	
local disc = file:read(size)

file:close()
local playlist = json.decode(disc)
local title = playlist.title
local artist = playlist.artist
local tracks = playlist.tracks
local count = #tracks

local listview = playdate.ui.gridview.new(0, 35)
local label = Label(6, 18, title .. " - " .. artist, font, 390)
local batteryIndicator = BatteryIndicator(355, 25, font)
batteryIndicator:hide()

print("Album: " .. title)
print("Artist: " .. artist)
print("Track count: " .. count)

for t=1, count do
	print("" .. t .. " " .. tracks[t].title .. " (" .. tracks[t].file .. ")")
end

local playIndex = 0

function playNext()
	playIndex += 1
	if(playIndex <= count)then
		local track = tracks[playIndex].file
		print("Playing: " .. track)
		play("Audio/" .. track)
	else
		print("Finished")
	end
end

function playPrev()
	playIndex -= 1
	if(playIndex < 1) then playIndex = 1 end	
		local track = tracks[playIndex].file
		print("Playing: " .. track)
		play("Audio/" .. track)
end

function playTrack(index)
	playIndex = index
	if(playIndex <= count)then
		local track = tracks[playIndex].file
		print("Playing: " .. track)
		play("Audio/" .. track)
	else
		print("Finished")
	end
end

local filePlayer = playdate.sound.fileplayer.new()
filePlayer:setFinishCallback(playNext)

function play(path)
	filePlayer:stop()
	filePlayer:load(path)
	filePlayer:play()
	listview:scrollToRow(playIndex)
end

playNext()

userSelectedTrack = nil
userSelectedIndex = 1

--listview.backgroundImage = playdate.graphics.nineSlice.new('Images/empty_box', 4, 4, 45, 45)
listview:setNumberOfRows(#tracks)
listview:setCellPadding(3, 3, 3, 3)
listview:setContentInset(0,0,0,0)
listview:setNumberOfColumns(1)

function listview:drawCell(section, row, column, selected, x, y, width, height)
		local renderTrack = tracks[row]
		if row == playIndex then
			local label = "" .. row .. " " ..renderTrack.title
			local textWidth = playdate.graphics.getTextSizeForMaxWidth(label, 400)
			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
			playdate.graphics.fillRoundRect(x, y, textWidth + 10, height, 5)
			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
			playdate.graphics.drawText(label, x + 4, y+7)
		elseif selected then
			local label = "" .. row .. " " ..renderTrack.title
			local textWidth = playdate.graphics.getTextSizeForMaxWidth(label, 400)
			userSelectedTrack = renderTrack
			userSelectedIndex = row
			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
			playdate.graphics.drawRoundRect(x, y, textWidth + 10, height, 5)
			playdate.graphics.drawText("" .. row .. " " ..renderTrack.title, x + 4, y+7)
		else
			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
			playdate.graphics.drawText("" .. row .. " " ..renderTrack.title, x + 4, y+7)
		end
end

function playdate.leftButtonDown()
	playPrev()
end

function playdate.rightButtonDown()
	playNext()
end

function playdate.upButtonDown()
	listview:selectPreviousRow()
end

function playdate.downButtonDown()
	listview:selectNextRow()
end

function playdate.AButtonDown()
	playTrack(userSelectedIndex)
end

modeA = 0--everything on
modeB = 1--track details only, no animation
modeC = 2--battery saver mode
mode = modeA

function playdate.BButtonDown()
	if mode == modeA then
		mode = modeB
		batteryIndicator:hide()
		label:setMaxWidth(390)
	elseif mode == modeB then
		mode = modeC
		batteryIndicator:show()
		label:setMaxWidth(310)
	else
		mode = modeA
		batteryIndicator:hide()
		label:setMaxWidth(390)
	end
end

--Coracle animation fields:
local t = 0.0
local donut = true
local cameraZ = 9.0
local cX = width/2 + width/4
local cY = height/2

local q = 0
local sQ = 0
local b = 0
local p = 0
local z = 0
local s = 0
	
function playdate.update()
	if(mode == modeA)then
		background()
	end
	playdate.graphics.sprite.update()
	if(mode == modeA)then
		-- This block can be anything, any animation with or without using Coracle, or just a static image
		t += 0.04
		
		for i = 60, 0, -1  do
		
			q = (i * i)
			sQ = sin(q)
			
			if(donut)then
				b = i % 6 + t + i
			else
				b = i % 6 + t
			end
		
			p = i + t
			z = cameraZ + cos(b) * 3 + cos(p) * sQ
			s = 150 / z / z
			
			fill(1*(s * 0.35))
			
			circle((cX * (z + sin(b) * 0.8 + sin(p) * sQ) / z), (cY + cX * (cos(q)- cos(b+t))/z), s)
		end
	end
	if(mode ~= modeC)then
		fill(1)
		line(5, 32, 395, 32)
		listview:drawInRect(0, 36, 400, 205)
		
		local change = crankChange()/50
		if change > 0 then
			filePlayer:setRate(filePlayer:getRate() + change)
		elseif change < 0 then
			filePlayer:setRate(math.min(1, filePlayer:getRate() - change))
		end
	end
	playdate.timer:updateTimers()
	
end