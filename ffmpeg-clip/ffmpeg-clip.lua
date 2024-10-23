local mp = require "mp"
local utils = require "mp.utils"

function escape(str)
    -- FIXME(Kagami): This escaping is NOT enough, see e.g.
    -- https://stackoverflow.com/a/31413730
    -- Consider using `utils.subprocess` instead.
    return str:gsub("\\", "\\\\"):gsub('"', '\\"')
end

function clip(res)
	local a = mp.get_property_number("ab-loop-a")
	local b = mp.get_property_number("ab-loop-b")
	
	if not a then
		mp.osd_message("ab-loop-a not set", 1)
		return
	end
	
	if not b then
		mp.osd_message("ab-loop-b not set", 1)
		return
	end
	
	local filename = mp.get_property("filename")
	local inpath = escape(utils.join_path(utils.getcwd(), mp.get_property("stream-path")))
	local outpath = inpath:gsub(".mp4", "") .. "_clip.mp4"
	
	local i = 1
	local file = io.open(outpath,"r")
	while file ~= nil do
		io.close(file)
		outpath = inpath:gsub(".mp4", "") .. "_clip" .. i .. ".mp4"
		file = io.open(outpath,"r")
		i = i + 1
	end
	--mp.osd_message(outpath)

	if not filename or not inpath or not outpath then
		mp.osd_message("filename error", 1)
		return
	end

	local cmd = [[
		ffmpeg -i "$in" -ss $start -to $end -c:a libopus $res "$out"
	]]
	cmd = cmd:gsub("$start", a)
	cmd = cmd:gsub("$end", b)
	cmd = cmd:gsub("$in", inpath)
	cmd = cmd:gsub("$out", outpath)
	if res == 0 then
		cmd = cmd:gsub("$res", "")
	elseif res == 1 then
		cmd = cmd:gsub("$res", "-vf scale=-1:720")
	elseif res == 2 then
		cmd = cmd:gsub("$res", "-vf scale=-2:480")
	end
	
	if res == 3 then
		cmd = [[
			ffmpeg -i "$in" -ss $start -to $end -map 0 -c copy "$out"
		]]
		cmd = cmd:gsub("$start", a)
		cmd = cmd:gsub("$end", b)
		cmd = cmd:gsub("$in", inpath)
		cmd = cmd:gsub("$out", outpath)
	end
	
	mp.osd_message(cmd, 5)
	
	os.execute(cmd)
	--io.close(file)
end

function mute(keep)
	local filename = mp.get_property("filename")
	local inpath = escape(utils.join_path(utils.getcwd(), mp.get_property("stream-path")))
	local outpath = inpath:gsub(".mp4", "") .. "_muted.mp4"
	
	local i = 1
	local file = io.open(outpath,"r")
	while file ~= nil do
		io.close(file)
		outpath = inpath:gsub(".mp4", "") .. "_muted" .. i .. ".mp4"
		file = io.open(outpath,"r")
		i = i + 1
	end
	
	local cmd = [[
		ffmpeg -i "$in" -c copy -an "$out"
	]]
	cmd = cmd:gsub("$in", inpath)
	cmd = cmd:gsub("$out", outpath)
	
	mp.osd_message(cmd, 5)
	
	os.execute(cmd)
	io.close(file)
	if not keep then
		os.remove(inpath)
	end
end

function print_help()
	local msg = [[
		F4:					clip (copy)
		F5:					clip (1080p)
		Shift+F5:			clip (720p)
		Ctrl+Shift+F5:		clip (480p)
		F6:					mute
	]]
	mp.osd_message(msg, 1)
end

	
mp.add_key_binding("F5", "clip_1080", 		function() clip(0) end)
mp.add_key_binding("shift+F5", "clip_720", 	function() clip(1) end)
mp.add_key_binding("ctrl+shift+F5", "clip_480", 	function() clip(2) end)
mp.add_key_binding("F4", "clip_copy", 		function() clip(3) end)
mp.add_key_binding("F6", "clip_mute_keep", 	function() mute(true) end)
mp.add_key_binding("F1", "print_help", 		function() print_help() end)
--mp.add_key_binding("shift+F6", "clip_mute", function() mute(false) end)