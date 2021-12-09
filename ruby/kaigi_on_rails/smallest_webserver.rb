class Application
  def call(env)
    [200, {}, ["Hello World: " + Time.now.to_s]]
  end
end

app = Application.new


require "socket"

port = 3000
server = TCPServer.open(port)

loop do
  # Wait for connection
  socket = server.accept
  
  if match = socket.gets.chomp.match(/^(?<verb>[A-Z]*) (?<path>[^ ]*) (?<ver>.*)$/)
    # Make a hash with the request information
    env = {
      "REQUEST_METHOD" => match[:verb],
      "PATH" => match[:path],
      "HTTP_VERSION" => match[:ver]
    }

    while line = socket.gets.chomp
      break if line.bytesize == 0
      key, value = line.split(": ")
      env[key] = value
    end

    # Call app with request information
    response = app.call(env)

    status = response[0]
    headers = response[1]
    body = response[2]

    socket.write "HTTP/1.1 #{status} OK\r\n"

    headers.each do |key, value|
      socket.write "#{key}: #{value}"
    end

    socket.write "\r\n"

    body.each { |part| socket.write part }
    socket.close
  else
    socket.close
  end
end
