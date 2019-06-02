--[[ 
	Shortcuts Enhancer
	Designed By:
	- Gdljjrod (https://twitter.com/gdljjrod).
]]

game.close()

--Show splash
splash.zoom("resources/splash.png")

--Load palette
color.loadpalette()

back = image.load("resources/back.png")

--Update
dofile("git/shared.lua")
dofile("git/updater.lua")

--Checking XML
local objxml = xml.parsefile("ur0:shell/whats_new/np/whatsnew.xml")
if objxml then
	local var = objxml:find("target","type", "p")
	if var and var.value then files.copy("np/whatsnew.xml","ur0:shell/whats_new/np/")end
	local var = objxml:find("target","type", "c")
	if var and var.value then files.copy("np/whatsnew.xml","ur0:shell/whats_new/np/")end
end

--Resize del icon de cada app
w1,h1 = 100,85

dofile("system/commons.lua")
dofile("system/apps.lua")
dofile("system/scroll.lua")

ScanAPPS()

local scrolls_bkgs,sel = {},1
local maxim,d_scroll = 8,15
local scroll_apps = newScroll(APPS,maxim)

for i=1,__TOT do
--Aqui guardaremos las posiciones de c/PREVIEW
	PREVIEWS[i].ini = scroll_apps.ini
	PREVIEWS[i].sel = scroll_apps.sel
	PREVIEWS[i].lim = scroll_apps.lim

--Necesitamos 3 scrolls para los 3 PREVIEWS
	table.insert(scrolls_bkgs,newScroll(BKGS,#BKGS))

end

function backup_cursors(selector)
	--backup cursors
	PREVIEWS[sel].ini = scroll_apps.ini
	PREVIEWS[sel].sel = scroll_apps.sel
	PREVIEWS[sel].lim = scroll_apps.lim

	sel = selector

	--restore cursors
	scroll_apps.ini = PREVIEWS[sel].ini
	scroll_apps.sel = PREVIEWS[sel].sel
	scroll_apps.lim = PREVIEWS[sel].lim
end

local coords, yp = { 35, 339, 641 }, 348
buttons.interval(12,5)
change = false
local crono, clicked = timer.new(), false
while true do
	buttons.read()
	touch.read()
	if change then buttons.homepopup(0) else buttons.homepopup(1) end

	if back then back:blit(0,0) end

	------------------------------------------------------------------------------------------
	screen.print(480,10,STRINGS_TITLE,1,color.white,color.black,__ACENTER)
	screen.print(955,10,"("..scroll_apps.maxim..")",1,color.red,color.black, __ARIGHT)

	if scroll_apps.maxim > 0 and APPS then

		local y=40
		for i=scroll_apps.ini, scroll_apps.lim do

			if i == scroll_apps.sel then

				draw.offsetgradrect(5,y-7,940,34,color.shine:a(75),color.shine:a(135),0x0,0x0,21)

				if i == 1 then
					if not PREVIEWS[sel].img then
						PREVIEWS[sel].def = true
						PREVIEWS[sel].img = image.load(APPS[1][sel].path_img)
						if PREVIEWS[sel].img then
							PREVIEWS[sel].img:resize(282,108)
							PREVIEWS[sel].img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
						else
							PREVIEWS[sel].img = iconDef
						end
					end
					PREVIEWS[sel].id = APPS[1][sel].id

				else
					if not PREVIEWS[sel].img then
						PREVIEWS[sel].def = false

						if PREVIEWS[sel].icono == 1 then
							if APPS[scroll_apps.sel].type == "EG" or APPS[scroll_apps.sel].type == "ME" then
								if string.upper(APPS[scroll_apps.sel].title) == "VHBL" then
									PREVIEWS[sel].img = game.geticon0(APPS[scroll_apps.sel].path.."/PBOOT.PBP")
								else
									PREVIEWS[sel].img = game.geticon0(APPS[scroll_apps.sel].path.."/EBOOT.PBP")
								end
							else
								PREVIEWS[sel].img = image.load(APPS[scroll_apps.sel].path_img)
							end
						elseif PREVIEWS[sel].icono == 2 and APPS[scroll_apps.sel].path_startup then
							PREVIEWS[sel].img = image.load(APPS[scroll_apps.sel].path_startup)
						elseif PREVIEWS[sel].icono == 3 and APPS[scroll_apps.sel].path_custom then
							PREVIEWS[sel].img = image.load(APPS[scroll_apps.sel].path_custom)
						end

						if PREVIEWS[sel].img then
							if PREVIEWS[sel].icono == 1 then
								PREVIEWS[sel].img:resize(w1,h1)
							else
								PREVIEWS[sel].img:resize(282,108)
							end
							PREVIEWS[sel].img:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
						else
							if PREVIEWS[sel].icono == 1 then PREVIEWS[sel].img = iconDef end
						end
					end
					PREVIEWS[sel].id = APPS[scroll_apps.sel].id
					PREVIEWS[sel].title = APPS[scroll_apps.sel].title2
				end

			end

			if screen.textwidth(APPS[i].title,1) > 945 then
				d_scroll = screen.print(d_scroll,y,APPS[i].title,1,color.white,color.black, __SLEFT,920)
			else 
				screen.print(15,y,APPS[i].title,1,color.white,color.black, __ALEFT)
			end

			--Bar scroll_apps
			if scroll_apps.maxim >= maxim then -- Draw Scroll Bar
				local ybar,h = 35,(maxim*34)
				draw.fillrect(950, ybar-2, 8, h, color.shine:a(50))
				local pos_height = math.max(h/scroll_apps.maxim, maxim)
				draw.fillrect(950, ybar-2 + ((h-pos_height)/(scroll_apps.maxim-1))*(scroll_apps.sel-1), 8, pos_height, color.new(0,255,0))
			end

			y+=34

		end --for

		draw.fillrect(coords[sel]-4, yp-4, 290, 116, color.green)

		--blit icons
		for j=1,__TOT do

			--ID
			screen.print(coords[j]+141,yp-28,PREVIEWS[j].id,1,color.white,color.black, __ACENTER)

			--BKGS
			if BKGS[scrolls_bkgs[j].sel] then BKGS[scrolls_bkgs[j].sel]:blit(coords[j],yp) end

			--Icons & Text
			if PREVIEWS[j].def then
				if PREVIEWS[j].img then PREVIEWS[j].img:blit(coords[j],yp) end
			else
				if PREVIEWS[j].icono == 1 then

					if PREVIEWS[j].img then PREVIEWS[j].img:blit(coords[j]+5,yp+5) end
						draw.fillrect(coords[j]+5,yp+108-18, screen.textwidth(fnt,PREVIEWS[j].title,0.8)+10, 20, color.shine:a(45))
						screen.print(fnt, coords[j]+10,yp+108-19,PREVIEWS[j].title,0.8,color.white,color.black, __ALEFT)
					screen.print(coords[j],yp+108+13,STRINGS_ICON0,0.9,color.white,color.black, __ALEFT)
				else

					if PREVIEWS[j].img then PREVIEWS[j].img:blit(coords[j],yp) end

					if PREVIEWS[j].icono == 2 then
						screen.print(coords[j],yp+108+13,STRINGS_STARTUP,0.9,color.white,color.black, __ALEFT)
					else
						screen.print(coords[j],yp+108+13,STRINGS_CUSTOM,0.9,color.white,color.black, __ALEFT)
					end

				end
			end

			screen.print(coords[j]+280,yp+108+13,STRINGS_BKG.." ("..scrolls_bkgs[j].sel..")",0.9,color.white,color.black, __ARIGHT)
		end

	else
		screen.print(480,202,STRINGS_EMPTY,1.5,color.yellow,color.black,__ACENTER)
	end

	--Info
	draw.fillrect(0,500,960,544, color.shine:a(10))
	screen.print(480,515,STRINGS_HELP,1,color.white,color.black, __ACENTER)

	screen.flip()

	----------------------------------Controls-------------------------------
	if scroll_apps.maxim > 0 and APPS then

		if (buttons.up or buttons.analogly<-60) and (not buttons.held.l or not buttons.held.r) then
			if scroll_apps:up() then
				if not APPS[scroll_apps.sel].path_custom and PREVIEWS[sel].icono == 3 then PREVIEWS[sel].icono = 1 end
				d_scroll = 25
				PREVIEWS[sel].img = nil
			end
		end

		if (buttons.down or buttons.analogly>60) and (not buttons.held.l or not buttons.held.r) then
			if scroll_apps:down() then
				if not APPS[scroll_apps.sel].path_custom and PREVIEWS[sel].icono == 3 then PREVIEWS[sel].icono = 1 end
				d_scroll = 25
				PREVIEWS[sel].img = nil
			end
		end

		if buttons.released.l or buttons.released.r then
			--backup cursors
			PREVIEWS[sel].ini = scroll_apps.ini
			PREVIEWS[sel].sel = scroll_apps.sel
			PREVIEWS[sel].lim = scroll_apps.lim
		
			if buttons.released.l then sel -= 1 else sel += 1 end

			if sel < 1 then sel = __TOT end
			if sel > __TOT then sel = 1 end

			--restore cursors
			scroll_apps.ini = PREVIEWS[sel].ini
			scroll_apps.sel = PREVIEWS[sel].sel
			scroll_apps.lim = PREVIEWS[sel].lim
		end
		if isTouched(40,358,270,100) then
			backup_cursors(1)
		elseif isTouched(344,358,270,100) then
			backup_cursors(2)
		elseif isTouched(646,358,270,100) then
			backup_cursors(3)
		end

		if (buttons.left or buttons.right) and not PREVIEWS[sel].def then
			--if PREVIEWS[sel].icono != 3 then
				if buttons.left then
					scrolls_bkgs[sel]:up()
				else
					scrolls_bkgs[sel]:down()
				end
			--end
		end

		if buttons.square and not PREVIEWS[sel].def then
			local lim = 2
			if APPS[scroll_apps.sel].path_custom then lim = 3 end

			PREVIEWS[sel].icono += 1

			if PREVIEWS[sel].icono < 1 then PREVIEWS[sel].icono = lim end
			if PREVIEWS[sel].icono > lim then PREVIEWS[sel].icono = 1 end

			PREVIEWS[sel].img = nil
		end

		if buttons.accept then
			if not PREVIEWS[sel].def then

				local vbuff = screen.toimage()

				if vbuff then vbuff:blit(0,0) end
					message_wait(STRINGS_WAIT_PREVIEW.."  "..PREVIEWS[sel].id)
				os.delay(500)

				image.clip(vbuff,coords[sel],yp,282,108,sel)

				if vbuff then vbuff:blit(0,0) end
					message_wait(PREVIEWS[sel].id.."  "..STRINGS_READY_PREVIEW)
				os.delay(1000)

				write_xml(XMLPATH,sel,PREVIEWS[sel].id)
				files.write(XMLPATH,tb_xml)

				os.dialog(STRINGS_DONE)
				os.delay(500)
				change = true
			end
		end

		if buttons.triangle then
			local flag = false
			local vbuff = screen.toimage()
			for i=1, __TOT do
				if not PREVIEWS[i].def then

					if vbuff then vbuff:blit(0,0) end
						message_wait(STRINGS_WAIT_PREVIEW.."  "..PREVIEWS[i].id)
					os.delay(500)
					
					image.clip(vbuff,coords[i],yp,282,108,i)

					if vbuff then vbuff:blit(0,0) end
						message_wait(PREVIEWS[i].id.."  "..STRINGS_READY_PREVIEW)
					os.delay(1000)

					write_xml(XMLPATH,i,PREVIEWS[i].id)
					flag = true
				end
			end
			if flag then
				files.write(XMLPATH,tb_xml)
				--os.message(STRINGS_DONE)
				os.dialog(STRINGS_DONE)
				os.delay(500)
				change = true
			end
		end

		--Help
		if buttons.select then
			show_dialog()
		end
		if isTouched(0,495,960,544) and touch.front[1].released then--pressed then
			if clicked then
				clicked = false
				if crono:time() <= 300 then -- Double click and in time to Go.
					-- Your action here.
					show_dialog()
				end
			else
				-- Your action here.
				clicked = true
				crono:reset()
				crono:start()
			end
		end

		if crono:time() > 300 then -- First click, but long time to double click...
			clicked = false
		end

		if buttons.start then exit_hb() end

	end

end
