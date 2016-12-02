# Redisの接続情報を設定する。
host     = "127.0.0.1"
port = 6379
database = 0

r = Redis.new host, port
r.select database

def doConvert(r,j)
  puts "doConvert start"
  h = JSON.parse(j)
  puts h["Id"]
  r.set h["Id"], j
  ffmpegCmd = <<"EOT"
ffmpeg -y -f ppm_pipe \
-f ppm_pipe -r 24 -i - \
-f ssegment -segment_format mpegts -s 320x240 -r 24 -c:v libx264 \
-pix_fmt yuv420p \
-flags +loop-global_header -bsf h264_mp4toannexb \
-strict experimental \
-segment_list static/#{h["Id"]}.m3u8 \
-break_non_keyframes 1 -segment_list_type hls \
-segment_time 8 -segment_list_size 3 -segment_list_flags +live -threads 4 static/#{h["Id"]}%03d.ts
EOT

  `bin/mruby glsl2ppm.rb #{h["Id"]}`
  puts "doConvert end"
end

# RedisにGLSLコードの登録が無いかを監視する。
while true
  job = r.lpop "myglsllist"
  if(job != nil)
     doConvert(r,job)
  end
  # ウェイト
  Sleep::usleep(30000)
end