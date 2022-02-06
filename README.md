# tasmota32-mpl3115

A (very) simple I2C driver for the MPL3115 atmospheric pressure sensor for Tasmota32

![Tasmota Screen](screenshot.png)

I've had a lot of fun playing around with Tasmota, using it to sense various things like temperature and particulate counts in my garage.
I was intrigued that the version for the ESP32 included a scripting language called "Berry" that could be used to write simple,
low performance I2C drivers.  As it happens, I had an Adafruit MPL3115 based pressure/altimeter board that was unsupported by 
the base Tasmota firmware, so I decided to give it a whirl.

Using the example code from the Berry Cookbook and the MPL3115 datasheet, I coded up a sensor in a couple of hours.  Nifty!

To use it, upload the mpl3115p.be file to the Tasmota32 module, and then add load("mpl3115p.be") to the autoexec.be file
on your sensor node.

# Problems/limitations

This was a first attempt, and so could use some cleanup.

I'm uncertain about the pressure measurements.  While the numbers returned seem plausible, over the first 12 hours of running, it recorded incredibly stable pressure numbers at my location.  This device is used as an altimeter as well, so I am not sure that I got it configured properly.

It's using polling, and has no support for data logging, which might be interesting to support. 


# Additional Information

Link to the datasheet:

https://cdn-shop.adafruit.com/datasheets/1893_datasheet.pdf
