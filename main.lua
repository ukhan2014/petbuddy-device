-- main.lua --

-- Define serial number as a global
s_no = "PB053117104000"

-- Set up the softAP. This makes PBD appear
-- as a WiFi network to anyone in range.
function setupAP()
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
function waitForClients()
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

-- connects to a user's home WiFi network
-- requires ssid and password
function connectWifi(wifi_ssid, wifi_pwd)
   print("connectWifi()")
   --print("Connecting to home wifi AP")
   station_cfg={}
   station_cfg.ssid=wifi_ssid
   station_cfg.pwd=wifi_pwd
end

-- Creates a server that will respond to HTTP
-- requests from anybody that is connected
function beginServer()
   print("beginServer()")
   srv=net.createServer(net.TCP)
   srv:listen(8234,function(conn)
      conn:on("receive",function(conn,payload)
         print (payload)
         if string.match(payload, string.reverse(s_no)) then
            print ("mobile said hi, sending hi back")
            conn:send("RX: " .. string.reverse(payload))
         else
            print ("unknown msg received")
            conn:send("what? expected= " .. string.reverse(s_no))
         end
      end)
      conn:on("sent",function(conn) 
         conn:close() 
      end)
   end)
end

--
function beginExistingSession()

end  

----------------------------------
--       main() function        --
----------------------------------
print("main()")
setupAP()
   
if(file.exists("env.cfg")) then
   beginExistingSession()
else
   print("no env file, start cfg")
   waitForClients()
end
