#-

 __  __ ___ _    _____ _ ___ 
|  \/  | _ \ |  |__ / / | __|
| |\/| |  _/ |__ |_ \ | |__ \
|_|  |_|_| |____|___/_|_|___/
                             
An implementation of a very simple driver for the MPL3115
pressure/temperature sensor that I got from Adafruit, written
in the Berry programming language for Tasmota32.

Written by Mark VandeWettering <mvandewettering@gmail.com

-#

class MPL3115 : Driver

    var wire		# which i2c bus are we on?
    var temperature	# temperature...
    var pressure	# pressure

    def init()
	
	print("Initializing...\n")
	# search for the right address
	self.wire = tasmota.wire_scan(0x60)

	if self.wire
	    # read the WHO_AM_I address, should be 0xC4 if we have the
	    # right device.
	    var v = self.wire.read(0x60, 0xC, 0x01)
	    if v != 0xC4 return end

	    # finish initialization, cribbed from the datasheet
	    # set to pressure mode, with over sample rate set
	    # to 128, in standby mode
	    self.wire.write(0x60, 0x26, 0x38, 1)
	    tasmota.delay(10)

	    # enable data flags in PT_DATA_CFG
	    self.wire.write(0x60, 0x13, 0x07, 1)
	    tasmota.delay(10)

	    # set active mode, 
	    self.wire.write(0x60, 0x26, 0x39, 1)
	    tasmota.delay(10)

	    # read status register
	    var sta = self.wire.read(0x60, 0x00, 1)

	    # when sta & PTDR (0x8) is set, new data 
	    # is in the pressure and temperature registers
	    # since the sensor is in active mode, it's
	    # not clear to me that we really need to
	    # monitor the sensor bit. 
	end
    end

    def read_pressure()
	var ph = self.wire.read(0x60, 0x01, 1)
	var pm = self.wire.read(0x60, 0x01, 1)
	var pl = self.wire.read(0x60, 0x03, 1)
	self.pressure = (4. * (pm + 256. * ph) + pl / 64.) / 1000.
    end

    def read_temperature()
	var th = self.wire.read(0x60, 0x04, 1)
	var tl = self.wire.read(0x60, 0x05, 1)
	self.temperature = tl/256. + th * 1.
    end

    def every_second()
	if !self.wire return nil end
	self.read_pressure()
	self.read_temperature()
    end

    def web_sensor()
	if !self.wire return nil end
	import string
	var msg = string.format(
		"{s}MPL3115 Pressure{m}%.2f kPa{e}" ..
		"{s}MPL3115 Pressure{m}%.2f atm{e}" ..
		"{s}MPL3115 Pressure{m}%.2f PSI{e}" ..
		"{s}MPL3115 Temperature{m}%.2f °C{e}",
		self.pressure, self.pressure * 0.00986923266, 
		self.pressure * 0.145038, self.temperature)
	tasmota.web_send_decimal(msg)
    end

    def json_append()
	if !self.wire return nil end
	import string
	# internally, we do stuff in kPa, but it looks like
	# tasmota wants everything in hPa.  So, convert on the fly.
	var msg = string.format(",\"MPL3115\":{\"Temperature\":%.2f,\"Pressure\":%.2f}",
	      self.temperature, self.pressure * 10.) 
	tasmota.response_append(msg)
    end

end

#- Install the driver -#

print("Loading the MPL3115 driver.")

mpl3115 = MPL3115()
tasmota.add_driver(mpl3115)
