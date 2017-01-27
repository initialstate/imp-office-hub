#require "InitialState.class.nut:1.0.0"

// Initialize your Initial State bucket
is <- InitialState("YOUR_ACCESS_KEY","impexplorer_officehub",":smiling_imp: impExplorer Office Hub");

function stream(data) {
    
    // Prepare data to be streamed
    local message = format("Data from my Explorer Kit! [Temp: %.2f | Humid: %.2f | Pressure: %.2f | Light: %.2f | Motion: %.2f]", 
        data.temp, data.humid, data.press, data.light, data.motion);
    server.log(message);
    
    local tempString = format("%.2f", data.temp);
    local humidString = format("%.2f", data.humid);
    local pressString = format("%.2f", data.press);
    
    if (data.light>=22000) {
        lightString <- ":city_sunset: lights on";
    } else {
        lightString <- ":night_with_stars: lights off";
    }
    if (data.motion==1.00) {
        motionString <- ":mens: motion detected";
    } else {
        motionString <- ":no_pedestrians: no motion";
    }
    
    // Stream formatted data
    is.sendEvents([
        {"key": ":thermometer: temperature (C)", "value": tempString},
        {"key": ":sweat_drops: humidity (%)", "value": humidString},
        {"key": ":balloon: pressure (hPa)", "value": pressString},
        {"key": ":high_brightness: light", "value": lightString},
        {"key": ":wave: motion", "value": motionString},
    ], function(err, data) {
        if (err != null) server.error("Error: " + err);
    });
}

// Register a function to receive sensor data from the device
device.on("reading.sent", stream);
