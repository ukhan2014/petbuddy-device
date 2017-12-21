-- rotate servo to provide feed for pet (UNTESTED)
print("doServo()")

function init(p)
    pin = p
    gpio.mode(pin,1)
    pwm.setup(pin,50,((min+max)/2))
end

function write(val,fi)
    pwm.start(pin)
    if(val<min) then val = min end
    if(val>max) then val = max end
    pwm.setduty(pin,val)
    --if(fi) then tmr.alarm( 1, 1000, 0, function() pwm.stop(pin) end ) end
end

function stop()
    pwm.stop(pin)
end

-- TODO: move this to an init function:
pin = 2
min = 50
max = 105
init(pin)
--

write(180)         -- turn servo to open feed door
if not tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
   print("servo stop")
   write(0)           -- turn servo to close
   stop()             -- stop powering servo
end)
then
print("error creating alarm in pb.doservo()")
return 1
end

return 0
