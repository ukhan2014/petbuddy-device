print("ESP8266 Server")
wifi.setmode(wifi.STATIONAP);
wifi.ap.config({ssid="PBD053117104000",pwd="1357911131"});
print("Server IP Address:",wifi.ap.getip())
sv = net.createServer(net.TCP)

sv:listen(80, function(conn)
conn:send("<h1> ESP8266<BR>Server is working!</h1>")
conn:on("receive", function(conn, receivedData)
print("Received Data: " .. receivedData)
end)
conn:on("sent", function(conn)
collectgarbage()
end)
end)
