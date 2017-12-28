-- main.lua --

print("heap = " .. collectgarbage("count")*1024)

-- Define serial number as a global
s_no = "PB053117104001"
pass = "053117104000"
home_wifi_ssid = 0
home_wifi_psk = 0

----------------------------------
--       main() function        --
----------------------------------
print("main()")

--pb = require "petbuddy"

loadfile("setupAP.lua")(s_no, pass)

   
if(file.exists("env.cfg")) then
  --dofile("beginExistingSession.lua")
  print("beginExistingSession()")
else
   print("no env file, start cfg")
   dofile("waitForClients.lua")
   
   print("finishing main...")
end
