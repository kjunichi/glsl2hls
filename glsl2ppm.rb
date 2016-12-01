# Redisの設定
host     = "127.0.0.1"
port = 6379
database = 0

log = Fluent::Logger.new(nil, :protocol=> 'tcp', :host=> '127.0.0.1', :port=> '24224')

r = Redis.new host, port
r.select database

# ジョブIDを引数でもらう。
jobId = ARGV[0]

# RedisからジョブIDを指定して該当のGLSLコードを取得する。
shader = r.get jobId
h = JSON.parse(shader)

# GLSLを生成、Vertex,Fragmentそれぞれのシェーダープログラムを登録する。
glsl = Glsl.new
glsl.attachVertexShader h["v"]
glsl.attachFragmentShader h["f"]

# ffmpegコマンドのむずかしい設定
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

IO.pipe do |r2, w|
  IO.popen("#{ffmpegCmd} 2>&1","w", err:w) do |pipe|
    # 秒間24フレームで15秒作成する。
    (24*15).times {|i|
      # GLSLをレンダリングする
      pipe.puts glsl.render
    }
    # ffmpegへの書き込みパイプを閉じる。
    w.close
  end　
  # ffmpegの標準出力、エラー出力をfluentdへ投げる
  log.post('glsl2ppm', {"log" => r2.read})
end
