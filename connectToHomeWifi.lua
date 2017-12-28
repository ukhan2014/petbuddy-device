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
   print("Done connect2HomeWifi()")
   return 0
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

local msg = ...
print("connect2HomeWifi(), msg:" .. msg)

print("heap = " .. collectgarbage("count")*1024)

home_wifi_ssid = string.sub(msg, 6, string.find(msg, "\n") - 1)
home_wifi_psk = string.sub(msg, string.find(msg, "\n") + 5)
home_wifi_psk = string.gsub(home_wifi_psk, "\n", "") -- remove line breaks
print("rx_ssid=" .. home_wifi_ssid)
print("rx_psk=" .. home_wifi_psk)

cfg = 
{
   ssid = home_wifi_ssid,
   pwd = home_wifi_psk
}
print("connecting to wifi ssid=" .. cfg.ssid .. " and pwd=" .. cfg.pwd)
wifi.setmode(wifi.STATION)
wifi.setphymode(wifi.PHYMODE_N)
wifi.sta.config(cfg)
wifi.sta.connect()
