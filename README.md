Some custom MPV scripts

put them in `\AppData\Roaming\mpv\scripts\` to use

## ffmpeg-clip

Various basic operations on the current video, like clipping and muting. Mainly intended for creating clips to share on places like Discord.

Requires ffmpeg to be installed and added to PATH.

### Usage

'Clip' operations extract a clip of the video selected using MPV's `a-b-loop feature` to a new file. Re-encoding operations use the default video codec (`x264`) and `libopus`.

By default, `l` is used to set the start and end of the `a-b-loop`.

Keybinds can be changed at the bottom of the script.


- F1: Show help (reminder of keybinds)
- F5: Clip `a-b-loop` selection (1080p)
- Shift+F5: Clip `a-b-loop` selection (720p)
- Control+Shift+F5: Clip `a-b-loop` selection (480p)
- F4: Clip `a-b-loop` selection (Stream copy, no re-encode)
- F6: Save muted copy (Stream copy, no re-encode, discard audio stream)
