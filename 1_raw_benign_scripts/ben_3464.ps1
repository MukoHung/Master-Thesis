adb shell screenrecord --verbose --time-limit 150 --bit-rate 20000000 /sdcard/captured_video.mp4
adb pull /sdcard/captured_video.mp4 .
