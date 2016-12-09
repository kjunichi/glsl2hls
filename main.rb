# Copyright (c) 2016 Junichi Kajiwara
# Released under the MIT license
# https://github.com/kjunichi/glsl2hls/blob/master/LICENSE

# Redisの接続情報を設定する。
host     = "127.0.0.1"
port = 6379
database = 0

$log = Fluent::Logger.new(nil, protocol: 'tcp', host: '127.0.0.1', port: '24224')

r = Redis.new host, port
r.select database

def doConvert(r,j)
  #puts "doConvert start"
  $log.post('glslmain', 'log' => "doConvert start")
  
  h = JSON.parse(j)
  # puts h["Id"]
  $log.post('glslmain', 'log' => h["Id"])
  
  r.set h["Id"], j
  
  `mruby/bin/mruby glsl2ppm.rb #{h["Id"]}`
  #puts "doConvert end" 
  $log.post('glslmain', 'log' => "doConvert end")
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
