#!/bin/bash
MYDIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
SAVEDIR=$(pwd)

# Controlla che i programmi richiesti siano installati
if [ -z "$(which ffmpeg)" ]; then
    echo "Errore: ffmpeg non e' installato"
    exit 1
fi

cd "$MYDIR"

TARGET_FILES=$(find ./ -type f -name "*.mp4")
for f in $TARGET_FILES
do
  f=$(basename "$f") # memorizza il nome completo del file
  f="${f%.*}" # toglie l'estensione
  if [ ! -f "${f}.mpd" ]; then
    echo "Converto il file \"$f\" in Adaptive WebM using DASH"
    echo "Riferimenti: http://wiki.webmproject.org/adaptive-streaming/instructions-to-playback-adaptive-webm-using-dash"

    # http://wiki.webmproject.org/adaptive-streaming/instructions-to-playback-adaptive-webm-using-dash

    VP9_DASH_PARAMS="-tile-columns 4 -frame-parallel 1"

    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:90 -b:v 250k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 1 -y /dev/null
    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:90 -b:v 250k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 2 "${f}_160px_250k.webm"

    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:180 -b:v 500k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 1 -y /dev/null
    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:180 -b:v 500k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 2 "${f}_320px_500k.webm"

    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:360 -b:v 750k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 1 -y /dev/null
    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:360 -b:v 750k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 2 "${f}_640px_750k.webm"

    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:360 -b:v 1000k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 1 -y /dev/null
    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:360 -b:v 1000k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 2 "${f}_640px_1000k.webm"

    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:720 -b:v 1500k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 1 -y /dev/null
    ffmpeg -i "${f}.mp4" -c:v libvpx-vp9 -vf scale=-1:720 -b:v 1500k -keyint_min 150 -g 150 ${VP9_DASH_PARAMS} -an -f webm -dash 1 -pass 2 "${f}_1280px_1500k.webm"

    ffmpeg -i "${f}.mp4" -c:a libvorbis -b:a 128k -vn -f webm -dash 1 "${f}_audio_128k.webm"


    rm -f ffmpeg*.log

    ffmpeg \
    -f webm_dash_manifest -i "${f}_160px_250k.webm" \
    -f webm_dash_manifest -i "${f}_320px_500k.webm" \
    -f webm_dash_manifest -i "${f}_640px_750k.webm" \
    -f webm_dash_manifest -i "${f}_640px_1000k.webm" \
    -f webm_dash_manifest -i "${f}_1280px_1500k.webm" \
    -f webm_dash_manifest -i "${f}_audio_128k.webm" \
    -c copy -map 0 -map 1 -map 2 -map 3 -map 4 -map 5 \
    -f webm_dash_manifest \
    -adaptation_sets "id=0,streams=0,1,2,3,4 id=1,streams=5" \
    "${f}.mpd"

    fi

done

cd "$SAVEDIR"