# https://trac.ffmpeg.org/wiki/Capture/Desktop
# https://ffmpeg.org/ffmpeg-devices.html#gdigrab
# https://trac.ffmpeg.org/wiki/Encode/H.264#LosslessH.264

# WARNING: THE RECORDING WILL STOP WHEN UAC POPUP IS SHOWN

C:\SoftPortable\ffmpeg\bin\ffmpeg `
	-f gdigrab -framerate 30 -draw_mouse 1 -i desktop `
	-c:v libx264 -qp 0 -pix_fmt yuv444p -preset ultrafast `
	"C:\Videos\recording-$(get-date -f yyyy-MM-dd-Hmss).mp4"
