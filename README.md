# Smart Agriculture Robot

This project demonstrates a smart agriculture robot designed to monitor and control environmental conditions for optimal crop growth. The robot uses stepper motors for movement and various sensors to measure distance, temperature, air quality, and light intensity.

## Author

This project was created by Vaibhav Maloo.

## Components Used

- Arduino
- Stepper Motors
- Ultrasonic Sensor (HC-SR04)
- Temperature Sensor (KY-001)
- Gas Sensor (MQ-2)
- Light Sensor (TSL2561)
- Breadboard and Jumper Wires

## Libraries Required

- OneWire
- DallasTemperature
- Stepper
- Wire
- Adafruit_Sensor
- Adafruit_TSL2561_U

## Pin Connections

- Stepper Motor 1: Pins 3, 4, 5, 6
- Stepper Motor 2: Pins 8, 9, 10, 11
- Ultrasonic Sensor: Trig Pin 12, Echo Pin 13
- Temperature Sensor: Data Pin 2
- Gas Sensor: Analog Pin A0
- Light Sensor: I2C (SDA, SCL)

## Code Explanation

The code is divided into several sections:

1. **Library Inclusions**: Required libraries are included at the beginning of the code.
2. **Pin Definitions and Variables**: Pins and variables for sensors and stepper motors are defined.
3. **Stepper Motor Initialization**: Two stepper motors are initialized with the specified number of steps per revolution.
4. **Sensor Initialization**: Ultrasonic, temperature, gas, and light sensors are initialized.
5. **Setup Function**: 
   - Serial communication is started.
   - Stepper motor speeds are set.
   - Light sensor is configured.
   - Distance and temperature sensors are initialized.
6. **Main Loop**: 
   - Stepper motors move one revolution in one direction.
   - Distance is measured using the ultrasonic sensor.
   - Height is calculated and compared with the expected height.
   - If the height is less than the expected height:
     - Air quality is measured using the gas sensor.
     - Temperature is measured using the temperature sensor.
     - Light intensity is measured using the light sensor.
     - Conditions are printed to the serial monitor.
   - If the height is greater than the expected height, optimal conditions are printed to the serial monitor.

## How to Run

1. Connect the components as per the pin connections mentioned above.
2. Upload the code to the Arduino.
3. Open the Serial Monitor to observe the sensor readings and motor movements.

## Notes

- Adjust the `stepsPerRevolution` variable to match your stepper motor specifications.
- Ensure proper wiring and connections for accurate sensor readings.

## License

This project is open-source and available for anyone to use and modify.