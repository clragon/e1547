for i in "$@"; do
	convert -background none paw.svg -render -resize "${i}x${i}" "paw_${i}.png"
done
