# RSTOonWWWW
Aby przekazać stream z kamery za pomocą protokołu RTSP do playera osadzonego na stronie www przy użyciu NGINX, potrzebujesz kilku kroków. Zakładając, że masz już NGINX z modułem RTMP zainstalowany, poniżej przedstawiam ogólny plan:

Instalacja NGINX z modułem RTMP:

Jeśli jeszcze nie masz zainstalowanego NGINX z modułem RTMP, musisz to zrobić. Na przykład, w systemie Ubuntu możesz to zrobić w następujący sposób:

sh
Skopiuj kod
sudo apt update
sudo apt install libnginx-mod-rtmp
Konfiguracja NGINX:

Otwórz plik konfiguracyjny NGINX, zwykle znajdujący się w /etc/nginx/nginx.conf lub /etc/nginx/conf.d/default.conf, i dodaj sekcję RTMP:

nginx
Skopiuj kod
rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        application live {
            live on;
            record off;

            # RTSP stream z kamery
            push rtmp://localhost/live/stream;
        }
    }
}

http {
    server {
        listen 8080;
        server_name localhost;

        location / {
            root html;
            index index.html index.htm;
        }

        location /hls {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            alias /tmp/hls;
            expires -1;
        }

        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }

        location /stat.xsl {
            root /usr/share/nginx/html;
        }
    }
}
Upewnij się, że katalog /tmp/hls istnieje i ma odpowiednie uprawnienia.

Przekształcanie RTMP do HLS:

Aby przekonwertować strumień RTMP na HLS, użyj ffmpeg. Możesz skonfigurować ffmpeg do działania jako usługa lub uruchomić go ręcznie:

sh
Skopiuj kod
ffmpeg -i rtsp://kamery/url -c:v copy -f flv rtmp://localhost/live/stream
Osadzenie playera na stronie www:

Utwórz plik HTML, który będzie osadzać player HLS. Możesz użyć np. Video.js:

html
Skopiuj kod
<!DOCTYPE html>
<html>
<head>
    <title>RTSP Stream</title>
    <link href="https://unpkg.com/video.js/dist/video-js.css" rel="stylesheet">
    <script src="https://unpkg.com/video.js/dist/video.js"></script>
</head>
<body>
    <video id="my_video" class="video-js vjs-default-skin" controls preload="auto" width="640" height="360">
        <source src="http://localhost:8080/hls/stream.m3u8" type="application/x-mpegURL">
    </video>

    <script>
        var player = videojs('my_video');
    </script>
</body>
</html>
Restart NGINX:

Po dokonaniu zmian w konfiguracji, zrestartuj NGINX, aby zastosować zmiany:

sh
Skopiuj kod
sudo systemctl restart nginx
Teraz, gdy odwiedzisz stronę hostowaną na NGINX, player powinien odtwarzać stream RTSP z kamery. Pamiętaj, aby upewnić się, że wszystkie zależności i adresy URL są poprawnie skonfigurowane.


czy ten stream bedzie lokalnie przechowywany na dysku serwera?
ChatGPT
Domyślnie w powyższej konfiguracji stream nie będzie przechowywany na dysku serwera. Konfiguracja, którą przedstawiłem, jedynie przesyła strumień RTSP z kamery przez RTMP do HLS i dalej do przeglądarki internetowej bez zapisywania go na dysku. Jeśli chcesz zapisywać ten stream na dysku serwera, musisz dodać odpowiednią konfigurację do pliku NGINX lub użyć ffmpeg do zapisu strumienia.

Zapisywanie strumienia za pomocą ffmpeg
Możesz użyć ffmpeg do zapisywania strumienia RTSP na dysk podczas przesyłania go do NGINX. Oto przykład, jak to zrobić:

sh
Skopiuj kod
ffmpeg -i rtsp://kamery/url -c:v copy -f flv rtmp://localhost/live/stream -c:v copy -f mp4 /path/to/save/stream.mp4
W tym poleceniu:

-i rtsp://kamery/url - URL strumienia RTSP z kamery.
-c:v copy - kopiuje strumień wideo bez transkodowania.
-f flv rtmp://localhost/live/stream - przesyła strumień do NGINX w formacie RTMP.
-f mp4 /path/to/save/stream.mp4 - zapisuje strumień na dysku w formacie MP4.
Zapisywanie strumienia za pomocą NGINX
Możesz także skonfigurować NGINX do zapisywania strumienia na dysku, ale wymaga to użycia funkcji record w module RTMP.

Zaktualizuj sekcję application live w konfiguracji NGINX:

nginx
Skopiuj kod
application live {
    live on;
    record all;
    record_path /path/to/save/streams;
    record_max_size 512M;
    record_interval 30m;
    record_unique on;

    # RTSP stream z kamery
    push rtmp://localhost/live/stream;
}
W tym przykładzie:

record all; - włącza nagrywanie wszystkich strumieni.
record_path /path/to/save/streams; - określa ścieżkę do katalogu, w którym będą zapisywane strumienie.
record_max_size 512M; - maksymalny rozmiar pliku nagrania (512 MB).
record_interval 30m; - maksymalny czas trwania jednego pliku nagrania (30 minut).
record_unique on; - tworzy unikalne nazwy plików dla każdego nagrania.
Restart NGINX
Po wprowadzeniu zmian w konfiguracji, zrestartuj NGINX, aby zastosować zmiany:

sh
Skopiuj kod
sudo systemctl restart nginx
Teraz strumień będzie przesyłany do przeglądarki i jednocześnie zapisywany na dysku serwera w określonym katalogu.






