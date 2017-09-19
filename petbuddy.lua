------------------
-- petbuddy.lua --
------------------

local petbuddy = {}


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
   print("waitForClients()")
   
   tmr.alarm( 0, 1000, 1, function()
      --if wifi.sta.getip() == nil then
      --   print("Connecting to AP...\n")
      table = {}
      table = wifi.ap.getclient()
      if next(table) == nil then
         print("waitForClients(): No cnxn 4 PBD setup")
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
         beginServer()
      end
   end) 
end

-- Creates a server that will respond to HTTP
-- requests from anybody that is connected
function petbuddy.beginServer()
   count = 0
   print("count=" .. count)
   print("beginServer()")
   srv=net.createServer(net.TCP)
   srv:listen(8234,function(conn)
      conn:on("receive",function(conn,payload)
         print (payload)
         if string.match(payload, string.reverse(s_no)) then
            if count == 0 then
               print ("mobile said hi, sending hi back")
               conn:send("RX:" .. string.reverse(payload) .. ":sendwifi")
               count = count + 1
               print("count=" .. count)
            end
         elseif string.find(payload, "ssid") then
            if count == 1 then
               home_wifi_ssid = string.sub(payload, 6, string.find(payload, "\n") - 1)
               home_wifi_psk = string.sub(payload, string.find(payload, "\n") + 5)
               print("rx_ssid=" .. home_wifi_ssid)
               print("rx_psk=" .. home_wifi_psk)
               count = count + 1
               print("count=" .. count)
               conn:send("Thank you, byebye.")
               conn:on("sent",function(conn) 
                  conn:close() 
                  connect2HomeWifi()
               end)
            end
         elseif count == 0 then
            print ("unknown msg received")
            conn:send("what? expected= " .. string.reverse(s_no))
         end
      end)
   end)
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
   pin = 2
   servo.init(pin)
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
