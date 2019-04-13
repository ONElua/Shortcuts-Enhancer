--[[ 
	----------Trophy Manager------------
	Create and organize your direct adrenaline bubbles.
	
	Licensed by GNU General Public License v3.0
	
	Designed By:
	- Gdljjrod (https://twitter.com/gdljjrod).
]]

APPS = {}

function fill_list(obj)

	if obj.type == "mb" or obj.type == "mba" then
		obj.path_img = "ur0:appmeta/"..obj.id.."/pic0.png"
		obj.path_startup = "ur0:appmeta/"..obj.id.."/livearea/contents/".."LA_bg.png"
	else

		obj.path_img = "ur0:appmeta/"..obj.id.."/icon0.png"

		--Startup
		local objxml = xml.parsefile("ur0:appmeta/"..obj.id.."/livearea/contents/template.xml")
		if objxml then
			local var = objxml:find("startup-image")--startup
			if var and var.value then
				obj.path_startup = "ur0:appmeta/"..obj.id.."/livearea/contents/"..var.value
			end
		end

	end

	if files.exists("ux0:data/SHORTCUTS/"..obj.id..".png") then
		obj.path_custom = "ux0:data/SHORTCUTS/"..obj.id..".png"
	end

	objxml = nil

	table.insert(APPS, obj)
end

function ScanAPPS()
	--id, type, version, dev, path, title
	local list = game.list(__GAME_LIST_ALL)
	if list and #list>0 then
		table.sort(list, function (a,b) return string.lower(a.title)<string.lower(b.title) end)
		for i=1,#list do
			if list[i].title then
				list[i].title = list[i].title:gsub("\n"," ")

				local title = list[i].title
				len = screen.textwidth(fnt, title,0.8)
				local j = string.len(title)
				while (len > 272) do
					title =  string.sub(title,1,j-1).."..."
					len = screen.textwidth(fnt, title,0.8)
					j = j-1
				end
				
				list[i].title2 = title
				
			end

			fill_list(list[i])
		end
	end
	
	local tmp = {}
	tmp.title = STRINGS_DEFAULT
	for i=1,__TOT do
		table.insert(tmp, { path_img = PREVIEWS[i].path_img or "", title = PREVIEWS[i].title or "unk", id = PREVIEWS[i].id or names[i] } )
	end
	table.insert(APPS,1,tmp)

end
