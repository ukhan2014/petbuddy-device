# petbuddy-device

Device side code for PetBuddy
  - lua codebase runs on esp-8266
  - using NodeMCU as devkit
  - flowchart file can be opened with draw.io webapp

Camera:
  - ov2640 jpeg cam

How to get up and running:
1. Start ESPlorer by going into the ESPlorer directory and doing:
	> sudo java -jar ESPlorer.jar

2. Connect the NodeMCU (ESP/PetBuddy Device) to your computer via USB
3. On mac, check that your NodeMCU is detected on the USB. On a
   terminal, do:
	> ioreg -p IOUSB | grep -i cp

	You should see something like this:
	
	  | | +-o CP2102 USB to UART Bridge Controller@14420000  <class AppleUSBDevice, id 0x1002f7bd7, registered, matched, active, busy 0 (458 ms), retain 17>

4. Go back to ESPlorer.

5. On the left side there is an "Open File" button, open the main.lua
   file.

6. On the top right area of ESPlorer, there is a reload
   button. Press it. In the dropdown, you should see something
   like:
   /dev/cu.SLAB_USBtoUART
   Make sure that entry is selected.

   If you cannot see the entry, the Silicon Labs drivers for the CP
   USB <-> UART chip on the nodemcu might not be installed.
   (eg. it wouldn't work on OSX Sierra without drivers),
   download the drivers from Silicon Labs' website:
   https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers

   You might also have to play around with the kexts so that silabs
   driver gets loaded as a kext. Google for more info.

7. Click the big "Open" button which is underneath the device
   dropdown. You should see something like:
   		
		PORT OPEN 115200

		Communication with MCU..

8. Press the "Heap" button at the very bottom on the right pane.
   You should see something like:
   Can't autodetect firmware

9. Press the "Send to ESP" button on the lower left of the
   screen.

10. The code should automatically start running. The Petbuddy
   Wifi should start broadcasting and you should be able to
   see it in the wifi selection of your phone or macbook.
