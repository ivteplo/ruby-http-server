require_relative "server"

counter = 0

server = Server.new(8080) { |router|
  router.get("/") { |res|
    "Hello, world!"
  }

  router.get("/counter") { |res|
    "#{counter}"
  }

  router.post("/increment") { |res|
    counter += 1
    "Success"
  }

  router.post("/decrement") { |res|
    counter -= 1
    "Success"
  }

  router.put("/reset") { |res|
    counter = 0
    "Success"
  }

  router.delete("/counter") { |res|
    counter = 0
    "Success"
  }
}

puts "Listening on port 8080"

loop do
  server.accept_connection() 
end
