-- main.lua --

-- Define serial number as a global
s_no = "PB053117104000"
home_wifi_ssid = 0
home_wifi_psk = 0

----------------------------------
--       main() function        --
----------------------------------
pb = require "petbuddy"
print("main()")
servo = require "servo"
print("testing servo")

pb.setupAP()
   
if(file.exists("env.cfg")) then
   pb.beginExistingSession()
else
   print("no env file, start cfg")
   pb.waitForClients()
   print("finishing main...")
end
