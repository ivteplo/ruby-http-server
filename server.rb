require "socket"

class Router
  def initialize
    @routes = {
      "get" => Hash.new,
      "post" => Hash.new,
      "put" => Hash.new,
      "delete" => Hash.new,
    }
  end

  def get url, &block
    @routes["get"][url] = block
  end

  def post url, &block
    @routes["post"][url] = block
  end

  def put url, &block
    @routes["put"][url] = block
  end

  def delete url, &block
    @routes["delete"][url] = block
  end

  def handle method, url
    result = {
      :body => "",
      :status => 200,
      :headers => Hash.new
    }

    if not @routes[method.downcase].has_key? url
      result[:body] = "404 Not Found"
      result[:status] = 404
      result[:headers]["Content-Type"] = "text/html"
      return result
    end

    begin
      body = @routes[method.downcase][url].call result
      result[:body] = body
    rescue StandardError => error
      result[:body] = "500 Internal Server Error"
      result[:status] = 500
      result[:headers] = Hash.new
      result[:headers]["Content-Type"] = "text/html"
      puts error
      puts error.backtrace
    end

    return result
  end
end

class Server
  def initialize port, &router_setup
    @router = Router.new
    router_setup.call @router
    @tcp = TCPServer.new port
  end

  def accept_connection
    socket = @tcp.accept
    request = socket.gets

    request_lines = request.split "\r\n"
    
    method, url, http_version = request_lines[0].split " "

    response = @router.handle method, url

    socket.puts "#{http_version} #{response[:status]}"

    response[:headers].each do |key, value|
      socket.puts "#{key}: #{value}"
    end

    socket.puts ""
    socket.puts response[:body]
    socket.close
  end
end

