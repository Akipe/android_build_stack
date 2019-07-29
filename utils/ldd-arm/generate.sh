# /bin/bash

# https://forum.xda-developers.com/showthread.php?t=2737126

echo 'readelf -d $1 | grep "\(NEEDED\)" | sed -r "s/.*\[(.*)\]/\1/"' | sudo tee -a ./ldd-arm