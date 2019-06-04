--[[ 
	Shortcuts Enhancer
	Designed By:
	- Gdljjrod (https://twitter.com/gdljjrod).
]]

--Load BKGS
BKGS = {}
local list = files.listfiles("resources")
if list and #list > 0 then
	for i=1,#list do
		local img = image.load('resources/bk_'..string.rep('0', 3-#(tostring(i)))..i..'.png')
		if img then	table.insert(BKGS,img) end
	end
end

iconDef = image.load("resources/icondef.png")
if iconDef then	iconDef:resize(w1,h1) end

__SHORTCUTS = "ux0:data/SHORTCUTS/"
files.mkdir(__SHORTCUTS)
files.mkdir(__SHORTCUTS.."lang/")
files.mkdir(__SHORTCUTS.."font/")

-- Loading language file
__LANG = os.language()

dofile("lang/english_us.txt")
if not files.exists(__SHORTCUTS.."lang/english_us.txt") then files.copy("lang/english_us.txt",__SHORTCUTS.."lang/") end
if files.exists(__SHORTCUTS.."lang/"..__LANG..".txt") then dofile(__SHORTCUTS.."lang/"..__LANG..".txt")	end
if files.exists("lang/"..__LANG..".txt") then dofile("lang/"..__LANG..".txt") end

-- Loading custom font
fnt = font.load(__SHORTCUTS.."font/font.ttf") or font.load(__SHORTCUTS.."font/font.pgf") or font.load(__SHORTCUTS.."font/font.pvf")
if not fnt then	fnt = font.load ("resources/font.ttf") end

SYMBOL_CROSS	= string.char(0xe2)..string.char(0x95)..string.char(0xb3)
SYMBOL_SQUARE	= string.char(0xe2)..string.char(0x96)..string.char(0xa1)
SYMBOL_TRIANGLE	= string.char(0xe2)..string.char(0x96)..string.char(0xb3)
SYMBOL_CIRCLE	= string.char(0xe2)..string.char(0x97)..string.char(0x8b)

SYMBOL_CONFIRM = SYMBOL_CROSS
SYMBOL_CANCEL = SYMBOL_CIRCLE
if buttons.assign()==0 then
	SYMBOL_CONFIRM = SYMBOL_CIRCLE
	SYMBOL_CANCEL = SYMBOL_CROSS
end

XMLQUICK = "np/whatsnew.xml"
XMLPATH = "ur0:shell/whats_new/np/whatsnew.xml"
NPPATH =  "ur0:shell/whats_new/np/"

__TOT = 3
local names = { "VITASHELL", "PKGJ00000", "AUTOPLUG0" }

--Functions XML
tb_xml={}
function read_xml(path)
	for line in io.lines(path) do
		if line:byte(#line) == 13 then line = line:sub(1,#line-1) end --Remove CR == 13
		table.insert(tb_xml, line)
	end
end
read_xml(XMLQUICK)

-- Write a file.
function files.write(path, tb)
	local file = io.open(path, "w+")
	for s,t in pairs(tb) do
		file:write(string.format('%s\n', tostring(t)))
	end
	file:close()
end

function write_xml(path,selector,id)
	local linesXML = { 
		{ png = 3,  id = 4 },
		{ png = 10, id = 11},
		{ png = 17, id = 18}
	}

		--<url type="106" >W001.png</url>
	tb_xml[linesXML[selector].png] = tb_xml[linesXML[selector].png]:gsub('>(%w+)',">".."SHORTCUT00"..selector)
		--<target type="u" >psgm:play?titleid=1MENUVITA</target>
	tb_xml[linesXML[selector].id] = tb_xml[linesXML[selector].id]:gsub('=(%w+)',"="..id)

end

PREVIEWS = {}
function parsexml(path)

	local linesXML = { 
		{ png = 3,  id = 4 },
		{ png = 10, id = 11},
		{ png = 17, id = 18}
	}

	for i=1,__TOT do
		PREVIEWS[i] = {}
		PREVIEWS[i].def = false
		PREVIEWS[i].img = nil
		PREVIEWS[i].icono = 1
		if not files.exists(NPPATH.."img/SHORTCUT00"..i..".png") then
			files.copy("np/img/SHORTCUT00"..i..".png", NPPATH.."img/")
		end
		PREVIEWS[i].id = names[i]
	end
	if not files.exists(XMLPATH) then files.copy("np/whatsnew.xml", NPPATH) end

	local objxml = xml.parsefile(path)
	if objxml then

		local var = objxml:findall("url","type","106")--png
		for i=1,__TOT do

			if var[i] and var[i].value then
				
				PREVIEWS[i].name_img = var[i].value
				PREVIEWS[i].path_img = NPPATH.."img/"..var[i].value
			else
				PREVIEWS[i].name_img = "SHORTCUT00"..i..".png"
				PREVIEWS[i].path_img = NPPATH.."img/SHORTCUT00"..i..".png"
			end

			--os.message(PREVIEWS[i].name_img)
			tb_xml[linesXML[i].png] = tb_xml[linesXML[i].png]:gsub('>(%w+)',">"..PREVIEWS[i].name_img:gsub(".png",""))
			--os.message(tb_xml[linesXML[i].png])

			--Load imgs
			PREVIEWS[i].img = image.load(PREVIEWS[i].path_img)
			PREVIEWS[i].def = true
			if PREVIEWS[i].img then
				PREVIEWS[i].img:resize(282,108)
				PREVIEWS[i].img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
			end

		end

		local var = objxml:findall("target","type","u")
		for i=1,__TOT do

			local value = names[i]

			if var[i] and var[i].value then
				value = var[i].value:gsub("\n","")
				value = value:match('?titleid=(.+)')
			end

			PREVIEWS[i].id = value or names[i]
			PREVIEWS[i].title = value or names[i]
			PREVIEWS[i].id = value or names[i]

			tb_xml[linesXML[i].id] = tb_xml[linesXML[i].id]:gsub('=(%w+)',"="..PREVIEWS[i].id)
		end
	end

	files.write(XMLPATH,tb_xml)

end
parsexml(XMLPATH)

-- Simple clip of image
function image.clip(img,x,y,w,h,selector)
	local sheet = image.new(w,h,0x0)
	local px,py = 0,0
	for py=0,h-1 do
		for px=0,w-1 do
			local c = img:pixel(px+x,py+y)
			sheet:pixel(px, py, c)
		end
	end
	--return sheet
	files.mkdir("ur0:shell/whats_new/np/img/")
	image.save(sheet, "ur0:shell/whats_new/np/img/SHORTCUT00"..selector..".png")

	os.delay(1500)
end

function draw.offsetgradrect(x,y,sx,sy,c1,c2,c3,c4,offset)
	local sizey = sy/2
		draw.gradrect(x,y,sx,sizey + offset,c1,c2,c3,c4)
			draw.gradrect(x,y + sizey - offset,sx,sizey + offset,c3,c4,c1,c2)
end

function message_wait(message)
	local mge = (message or STRINGS_WAIT)
	local titlew = string.format(mge)
	local w,h = screen.textwidth(titlew,1) + 30,70
	local x,y = 480 - (w/2), 272 - (h/2)

	draw.fillrect(x,y,w,h,color.black:a(150))
	draw.rect(x,y,w,h,color.white)
		screen.print(480,y+20, titlew,1,color.white,color.black,__ACENTER)
	screen.flip()
end

function isTouched(x,y,sx,sy)
	if math.minmax(touch.front[1].x,x,x+sx)==touch.front[1].x and math.minmax(touch.front[1].y,y,y+sy)==touch.front[1].y then
		return true
	end
	return false
end

function show_dialog()

os.dialog(  "     "..SYMBOL_SQUARE.." "..STRINGS_HELP_SQUARE..
			"\n\n".."     "..STRINGS_HELP_LR..
			"\n\n".."     "..STRINGS_HELP_LEFTRIGHT..
			"\n\n".."     "..STRINGS_HELP_HELD_LR..
			"\n\n".."     "..SYMBOL_CONFIRM.." "..STRINGS_HELP_CONFIRM..
			"\n\n".."     "..SYMBOL_TRIANGLE.." "..STRINGS_HELP_TRIANGLE..
			"\n\n".."     "..STRINGS_HELP_START,
		STRINGS_HELP_CONTROLS )
end

function exit_hb()
    if change then
	    if os.dialog(STRINGS_REBOOT, STRINGS_SYSTEM_DIALOG, __DIALOG_MODE_OK_CANCEL) == true then
		--if os.message(STRINGS_REBOOT,1) == 1 then
			os.delay(250)
			buttons.homepopup(1)
			power.restart()
		end
	end
	os.exit()
end
