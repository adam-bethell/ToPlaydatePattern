local img = app.image

local dlg = Dialog("Error")
dlg:label{text="Canvas must be 8x8 pixels"}

if img == nil then
    dlg:show()
    return
end

if img.width ~= 8 or img.height ~= 8 then
    dlg:show()
    return
end

local strParts = {}
local bin = {128, 64, 32, 16, 8, 4, 2, 1}
for y=0, 7 do
    local rowValue = 0
    for x=0, 7 do
        local pixelValue = img:getPixel(x, y)
        local c = Color(pixelValue)
        if c.gray > 127 then
            rowValue = rowValue + bin[x+1]
        end 
    end
    strParts[y+1] = string.format("0x%02x", rowValue)
end

local str = "gfx.setPattern({" .. table.concat(strParts, ", ") .. "})"


-- The following fuction was taken and tweaked from the following thread
-- https://community.aseprite.org/t/solved-copy-string-within-aseprite-extension/16344
local function copy_to_clipboard(str)

    -- returns whether the copy command succeeded
    -- (this function may fail; use pcall)
    local function os_copy(os_name,text)
      if os_name=="Windows" then
        io.popen('clip','w'):write(text):close()
      elseif os_name=="macOS" then
        return io.popen('pbcopy','w'):write(text):close()
      elseif os_name=="Linux" then
        return io.popen('xsel --clipboard','w'):write(text):close()
      end
      return nil --failed
    end
  
    -- using pcall as this might fail
    local pcall_ok,os_copy_ok = pcall(os_copy,app.os.name,str)
end

local dlg = Dialog("Playdate pattern")
local bounds = dlg.bounds
dlg.bounds = Rectangle(bounds.x-140, bounds.y-100, 310, 60)
dlg:label{text=str}
dlg:button{text="Copy to clipboard", selected=true,focus=true,onclick=function() copy_to_clipboard(str) end}
dlg:show()

