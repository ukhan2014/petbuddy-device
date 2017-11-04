-- main.lua --

-- Set up the softAP. This makes PBD appear
-- as a WiFi network to anyone in range.
function setupAP()
   print("Setting up AP...")
   
   -- Network Variables
   ap_cfg = 
   {
      ssid = "PB053117104000",
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
   print("Waiting for clients")
   
   tmr.alarm( 0, 1000, 1, function()
      --if wifi.sta.getip() == nil then
      --   print("Connecting to AP...\n")
      table = {}
      table = wifi.ap.getclient()
      if next(table) == nil then
         print("No cnxn for PBD setup...")
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
      end
   end) 
end

-- connects to a user's home WiFi network
-- requires ssid and password
function connectWifi(wifi_ssid, wifi_pwd)
   print("Connecting to home wifi AP")
   station_cfg={}
   station_cfg.ssid=wifi_ssid
   station_cfg.pwd=wifi_pwd
end

-- Creates a server that will respond to HTTP
-- requests from anybody that is connected
function beginServer()
   srv=net.createServer(net.TCP)
   srv:listen(80,function(conn)
      conn:on("receive",function(conn,payload)
         print(payload)
         conn:send("<h1> Hello PetBuddy! </h1>")
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
