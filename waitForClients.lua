-- Wait for a client to connect to the 
-- softAP we have created

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
   end
end)
print("waitForClients done")
return 0
