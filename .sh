
# przechwycenie RSTP, transkodowanie, kopia na dysk, wysyłka do NGNX
ffmpeg -i rtsp://kamery/url -c:v copy -f flv rtmp://localhost/live/stream -c:v copy -f mp4 /path/to/save/stream.mp4

#przechwycenie RSTP, transkodowanie, wysyłka do NGNX
ffmpeg -i rtsp://kamery/url -c:v copy -f flv rtmp://localhost/live/stream
