local port, ip = ...
print("pingCloud(), port:" .. port .. " ip:" .. ip)
print(collectgarbage("count"))
socket = net.createConnection(net.TCP, 0)

-- Wait for connection before sending.
socket:on("connection", function(sck)
   print("onConnection")
   -- 'Connection: close' rather than 'Connection: keep-alive' to have server 
   -- initiate a close of the connection after final response (frees memory 
   -- earlier here), https://tools.ietf.org/html/rfc7230#section-6.6 
   sck:send("GET /get HTTP/1.1\r\nHost: httpbin.org\r\nConnection: close\r\nAccept: */*\r\n\r\n")
   print(collectgarbage("count"))
end)

-- When the stuff is sent close the connection
socket:on("sent", function(sck, c)
   print("onSent()")
   sck:close()
   print("didPing")
   return 0
end)

print("connecting to " .. ip .. ":" .. port)
socket:connect(port,ip)
