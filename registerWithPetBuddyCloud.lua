local reginfo = ...
print("registerWithPetBuddyCloud(), reginfo:" .. reginfo)

print("heap = " .. collectgarbage("count")*1024)

--add serial # to reginfo
--no_bracket = string.sub(reginfo, 2, string.find(reginfo, "}"))
--w_ser = "\"{serial\":" .. s_no .. "," .. no_bracket
--print(w_ser)
--petbuddy.sendMsgToSocket(43332, "74.51.159.20",reginfo)
