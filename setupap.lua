local s_no, pass = ...
print("setupAP(), s_no:" .. s_no .. " pass:" .. pass)

print("heap = " .. collectgarbage("count")*1024)

-- Network Variables
ap_cfg = 
{
   ssid = s_no,
   pwd = pass
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
