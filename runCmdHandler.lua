print("runCmdHandler()")
print("heap = " .. collectgarbage("count")*1024)

-- Creates a server that will respond to HTTP
-- requests from anybody that is connected. This
-- will remain on and listening until it is
srv=net.createServer(net.TCP)
srv:listen(8234,function(conn)
   conn:on("receive",function(conn,msg)
      print("heap = " .. collectgarbage("count")*1024)
      print("cmdHandler msg=" .. msg)
      if(msg == "hello") then
         conn:send(s_no .. ": reporting 4 duty")
      elseif(msg ==  "feedpet") then
         loadfile("doServo.lua")
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
         -- loadfile("pingCloud.lua")(10004,"192.168.1.2")
         loadfile("pingCloud.lua")(80, "petbuddy.mooo.com")
      elseif string.find(msg, "ssid") then
         home_wifi_ssid = string.sub(msg, 6, string.find(msg, "\n") - 1)
         home_wifi_psk = string.sub(msg, string.find(msg, "\n") + 5)
         home_wifi_psk = string.gsub(home_wifi_psk, "\n", "") -- remove line breaks
         print("rx_ssid=" .. home_wifi_ssid)
         print("rx_psk=" .. home_wifi_psk)
         conn:send("Thank you, turning off this server, byebye.\n")
         conn:on("sent",function(conn)
            conn:close() 
            loadfile("connect2HomeWifi.lua")(home_wifi_ssid, home_wifi_psk)
         end)
         return
      elseif string.find(msg, "reginfo") then
         print("got registration info")
         reginfo = string.sub(msg, 9, string.find(msg, "\n"))
         conn:send("PetBuddy: Registering...\n")
         loadfile("registerWithPetBuddyCloud.lua")(reginfo)
      else
         print("unknown message")
         conn:send("PetBuddy: I don't know what that means.\n")
         --conn:send("RX:" .. string.reverse(payload) .. ":sendwifi")
      --elseif(msg == "") then
         --conn:send("RX:" .. string.reverse(payload) .. ":sendwifi")
      end
   end)
end)
