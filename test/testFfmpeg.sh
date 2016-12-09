cat static/test*.ppm|avconv -y -f image2pipe -r 24 -i - \
    -f ssegment -segment_format mpegts -s 320x240 -r 24 -c:v libx264 \
    -pix_fmt yuv420p \
    -flags +loop-global_header -bsf h264_mp4toannexb \
    -strict experimental \
    -segment_list static/test.m3u8 \
    -segment_list_type hls \
    -segment_time 8 -segment_list_size 3 -segment_list_flags +live -threads 4 static/test%03d.ts
