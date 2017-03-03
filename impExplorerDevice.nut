#require "HTS221.class.nut:1.0.0"
#require "LPS22HB.class.nut:1.0.0"
#require "WS2812.class.nut:2.0.2"

// Configure pin for use of Grove connectors
hardware.pin1.configure(DIGITAL_OUT, 1);

// Define constants
const sleepTime = 120;

// Declare Global Variables
tempSensor <- null;
pressureSensor <- null;
led <- null;
motion <- null;
light <- null;
counter <- 0;

// Define functions

// Read from sensors & send if motion is detected or sleepTime passes
function takeReading(){
    local conditions = {};
    local reading = tempSensor.read();
    conditions.temp <- reading.temperature;
    conditions.humid <- reading.humidity;
    reading = pressureSensor.read();
    conditions.press <- reading.pressure;
    conditions.light <- light.read();
    conditions.motion <- motion.read();
    
    if (conditions.motion == 1){
        agent.send("reading.sent", conditions);
        counter = 0;
    } else if (counter == sleepTime/10) {
        agent.send("reading.sent", conditions);
        counter = 0;
    } else {
        counter = counter + 1;
    }
    // Uncomment below when debugging
    //server.log(counter);
    
    // Flash the LED
    flashLed();
}

function flashLed() {
    led.set(0, [0,0,128]).draw();
    imp.sleep(0.5);
    led.set(0, [0,0,0]).draw();
}

function loop() {
    // Take a reading
    takeReading();
    
    // Wait 10 seconds between readings
    imp.wakeup(10, loop);
}

// Start of program

// Configure I2C bus for sensors
local i2c = hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);

tempSensor = HTS221(i2c);
tempSensor.setMode(HTS221_MODE.ONE_SHOT);

pressureSensor = LPS22HB(i2c);
pressureSensor.softReset();

// Configure SPI bus and powergate pin for RGB LED
local spi = hardware.spi257;
spi.configure(MSB_FIRST, 7500);
hardware.pin1.configure(DIGITAL_OUT, 1);
led <- WS2812(spi, 1);

// Configure Grove sensors
motion <- hardware.pin2;
motion.configure(DIGITAL_IN);
light <- hardware.pin5;
light.configure(ANALOG_IN); // Change to DIGITAL_IN if using digital light sensor

// Start taking readings
loop();
