in_mp4="$1"
out_gif="$2"
start_sec="$3"
pts="1.00"
width="320"
fps="7"

ffmpeg -i "${in_mp4}" -ss "00:00:0${start_sec}" -vf "scale=${width}:-1, setpts=${pts}*PTS" -r "${fps}" -f image2pipe -vcodec ppm - | convert - "${out_gif}"
