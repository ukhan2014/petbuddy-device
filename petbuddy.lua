------------------
-- petbuddy.lua --
------------------

local petbuddy = {}

function petbuddy.pingCloud(port, ip)
   print("pingCloud()")
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
   end)

   print("connecting to " .. ip .. ":" .. port)
   socket:connect(port,ip)
   
end

-- Set up the softAP. This makes PBD appear
-- as a WiFi network to anyone in range.
function petbuddy.setupAP()
   print("setupAP()")
   
   -- Network Variables
   ap_cfg = 
   {
      ssid = s_no,
      pwd = "053117104000"
   }

   ip_cfg = 
   {
      ip = "192.168.1.1",
      netmask = "255.255.255.0",
      gateway = "192.168.1.1"
   }

   -- Configure Wireless Internet
   wifi.setmode(wifi.SOFTAP)
   print('set mode=SOFTAP (mode='..wifi.getmode()..')\n')
   print('MAC Address: ',wifi.sta.getmac())
   print('Chip ID: ',node.chipid())
   print('Heap Size: ',node.heap(),'\n')

   -- Configure WiFi
   wifi.ap.config(ap_cfg)
   wifi.ap.setip(ip_cfg)
end

-- Wait for a client to connect to the 
-- softAP we have created
function petbuddy.waitForClients()
   waitCount = 0
   print("waitForClients()")
   
   tmr.alarm( 0, 5000, 1, function()
      waitCount = waitCount + 1
      --if wifi.sta.getip() == nil then
      --   print("Connecting to AP...\n")
      table = {}
      table = wifi.ap.getclient()
      if (next(table) == nil) then
         print("waitForClients(): Waiting for a cnxn for PBD setup")
      else
         ip, nm, gw=wifi.ap.getip()
         print("IP Info: \nIP Address: ",ip)
         print("Netmask: ",nm)
         print("Gateway Addr: ",gw,'\n')
         print("Current list of clients:\n")
         for mac, ip in pairs(table) do
            print(mac,ip)
         end
         tmr.stop(0)
         petbuddy.beginServer(8234)
      end
   end) 
end

-- Creates a server that will respond to HTTP
-- requests from anybody that is connected. This
-- will remain on and listening until it is
function petbuddy.beginServer(port)
   print("beginServer()")
   print(collectgarbage("count"))
   srv=net.createServer(net.TCP)
   srv:listen(port,function(conn)
      conn:on("receive",function(conn,msg)
         print("cmdHandler msg=" .. msg)
         if(msg == "hello") then
            conn:send(s_no .. ": reporting 4 duty")
         elseif(msg ==  "feedpet") then
            petbuddy.doServo()
         elseif(string.match(msg, "turnServo")) then
            conn:send("turning the servo")
         elseif string.match(msg, string.reverse(s_no)) then
            print ("mobile said hi, sending hi back")
            conn:send("RX:" .. string.reverse(msg) .. ":sendwifi")
         elseif(msg == "ping") then
            print("received message: ping")
            print(collectgarbage("count"))
            conn:close()
            print("count after conn:close")
            print(collectgarbage("count"))
            petbuddy.pingCloud(10004,"192.168.1.2")
         elseif string.find(msg, "ssid") then
            home_wifi_ssid = string.sub(msg, 6, string.find(msg, "\n") - 1)
            home_wifi_psk = string.sub(msg, string.find(msg, "\n") + 5)
            home_wifi_psk = string.gsub(home_wifi_psk, "\n", "") -- remove line breaks
            print("rx_ssid=" .. home_wifi_ssid)
            print("rx_psk=" .. home_wifi_psk)
            conn:send("Thank you, turning off this server, byebye.\n")
            conn:on("sent",function(conn)
               conn:close() 
               petbuddy.connect2HomeWifi()
            end)
            return
         elseif string.find(msg, "reginfo") then
            print("got registration info")
            reginfo = string.sub(msg, 9, string.find(msg, "\n"))
            conn:send("PetBuddy: Registering...\n")
            petbuddy.registerWithPetBuddyCloud(reginfo)
         else
            print("unknown message")
            conn:send("PetBuddy: I don't know what that means.\n")
            --conn:send("RX:" .. string.reverse(payload) .. ":sendwifi")
         --elseif(msg == "") then
            --conn:send("RX:" .. string.reverse(payload) .. ":sendwifi")
         end
      end)
   end)
   print("leaving server function")
end

function petbuddy.registerWithPetBuddyCloud(reginfo)
   print("registerWithPetBuddyCloud()")
   print("reginfo passed is: " .. reginfo)
   --petbuddy.sendMsgToSocket(43332, "74.51.159.20",reginfo)
end

function petbuddy.sendMsgToSocket(port, ip, msg)
   print("sendMsgToSocket()")
   print(collectgarbage("count"))
   socket = net.createConnection(net.TCP, 0)
   
   -- Wait for connection before sending.
   socket:on("connection", function(sck)
      print("onConnection")
      -- 'Connection: close' rather than 'Connection: keep-alive' to have server 
      -- initiate a close of the connection after final response (frees memory 
      -- earlier here), https://tools.ietf.org/html/rfc7230#section-6.6 
      sck:send(s_no .. ":" .. msg)
      print(collectgarbage("count"))
   end)
   
   -- When the stuff is sent close the connection
   socket:on("sent", function(sck, c)
      print("onSent()")
      sck:close()
      print("sendMsgToSocket done")
   end)

   print("connecting to " .. ip .. ":" .. port)
   socket:connect(port,ip)
   
end
   

function petbuddy.connect2HomeWifi()
   --register callbacks
   wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
      print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
      T.BSSID.."\n\tChannel: "..T.channel)
   end)

   wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
      print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
      T.BSSID.."\n\treason: "..T.reason)
   end)

   wifi.eventmon.register(wifi.eventmon.STA_AUTHMODE_CHANGE, function(T)
      print("\n\tSTA - AUTHMODE CHANGE".."\n\told_auth_mode: "..
      T.old_auth_mode.."\n\tnew_auth_mode: "..T.new_auth_mode)
   end)

   wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
      print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
      T.netmask.."\n\tGateway IP: "..T.gateway)
   end)

   wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function()
      print("\n\tSTA - DHCP TIMEOUT")
   end)

   wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
      print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
   end)

   wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, function(T)
      print("\n\tAP - STATION DISCONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
   end)

   wifi.eventmon.register(wifi.eventmon.AP_PROBEREQRECVED, function(T)
      print("\n\tAP - PROBE REQUEST RECEIVED".."\n\tMAC: ".. T.MAC.."\n\tRSSI: "..T.RSSI)
   end)

   wifi.eventmon.register(wifi.eventmon.WIFI_MODE_CHANGED, function(T)
      print("\n\tSTA - WIFI MODE CHANGED".."\n\told_mode: "..
      T.old_mode.."\n\tnew_mode: "..T.new_mode)
   end)

   cfg = 
   {
      ssid = home_wifi_ssid,
      pwd = home_wifi_psk
   }
   print("connect2HomeWifi()")
   print("connecting to wifi ssid=" .. cfg.ssid .. " and pwd=" .. cfg.pwd)
   wifi.setmode(wifi.STATION)
   wifi.setphymode(wifi.PHYMODE_N)
   wifi.sta.config(cfg)
   wifi.sta.connect()
end

-- rotate servo to provide feed for pet (UNTESTED)
function petbuddy.doServo()
   -- TODO: move this to an init function:
   pin = 2
   servo.init(pin)
   --
   
   servo.write(180)         -- turn servo to open feed door
   if not tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
      print("servo stop")
      servo.write(0)           -- turn servo to close
      servo.stop()             -- stop powering servo
   end)
   then
   print("error creating alarm in pb.doservo()")
   end
end

--
function petbuddy.beginExistingSession()

end  

return petbuddy
