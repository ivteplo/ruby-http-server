require_relative "server"

server = Server.new(8080) { |router|
  router.get("/") { |res|
    "hello"
  }
}

puts "Listening on port 8080"

loop do
  server.accept_connection() 
end

