host     = "127.0.0.1"
port     = 6379
key      = "hoge"
database = 0

# MIME形式の判定
class String
  def is_js?
    self.split(".")[-1] == "js"
  end
  def is_m3u8?
    self.split(".")[-1] == "m3u8"
  end
  def is_ts?
    self.split(".")[-1] == "ts"
  end

end

rds = Redis.new host, port
rds.select database

# HTTPサーバーを初期化する。
server = SimpleHttpServer.new({
  :server_ip => "0.0.0.0",
  :port  =>  8000,
  :document_root => "./",
  :debug => false,
})

server.http do |r|
  p r
  server.set_response_headers({
    "Server" => "my-mruby-simplehttpserver",
    "Date" => server.http_date,
  })
end

server.location "/glsl" do |r|
  puts "/glsl"
  if r.method == "POST"
    # POSTの場合、RedisにPOSTされたJSONにジョブIDを付けて登録する。
    h = {
      :body => r.body
    }
    h = JSON.parse(r.body)
    h['Id'] = Uuid.uuid
    rds.rpush "myglsllist", JSON.generate(h)
    server.response_body = h.to_json
  else
    # GETの場合は、あたりさわりのない返事をする。
    server.response_body = "Hello mruby World at '#{r.path}'\n"
    server.response_body += r.inspect + "\n"
  end

  server.create_response
end

# Static html file contents
server.location "/static/" do |r|
  if r.method == 'GET' && r.path.is_dir? || r.path.is_html?
    filename = server.config[:document_root] + r.path
    filename += r.path.is_dir? ? 'index.html' : ''

    server.set_response_headers "Content-Type" => "text/html; charset=utf-8"
    server.file_response r, filename
  elsif r.path.is_js?
    filename = server.config[:document_root] + r.path

    server.set_response_headers "Content-Type" => "application/javascript; charset=utf-8"
    server.file_response r, filename
  elsif r.path.is_m3u8?
    puts "m3u8!"
    filename = server.config[:document_root] + r.path

    server.set_response_headers "Content-Type" => "application/x-mpegURL; charset=utf-8"
    server.file_response r, filename
  elsif r.path.is_ts?
    filename = server.config[:document_root] + r.path
    server.set_response_headers "Content-Type" => "video/MP2T"
    server.file_response r, filename
  else
    server.response_body = "Service Unavailable\n"
    server.create_response 503
  end
end


server.run
