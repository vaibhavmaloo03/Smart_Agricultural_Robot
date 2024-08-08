/*
 Smart Agriculture Robot

 This program drives a unipolar or bipolar stepper motor and uses various sensors
 to monitor environmental conditions. The stepper motors are attached to digital pins 3 - 6
 and 8 - 11 of the Arduino. The robot performs one revolution in one direction and
 then one revolution in the other direction. Additionally, the robot measures distance,
 height, air quality, temperature, and light intensity to ensure optimal growing conditions
 for crops.

Created for Smart Agriculture Robot 2023 April
*/

#include <OneWire.h>
#include <DallasTemperature.h>
#include <Stepper.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_TSL2561_U.h>

// Pin definitions
const int trigPin = 12;
const int echoPin = 13;
#define GAS_SENSOR_PIN A0

// Distance measurement variables
long duration;
int distance;
int days = 0;
int grounddistance = 100;
int n = 0;

// Stepper motor configuration
const int stepsPerRevolution = 300; // Adjust this to match your motor
Stepper myStepper(stepsPerRevolution, 3, 4, 5, 6);
Stepper myStepper1(stepsPerRevolution, 8, 9, 10, 11);

// Temperature sensor configuration
#define KY001_ONE_WIRE_BUS 2
OneWire oneWire(KY001_ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// Light sensor configuration
Adafruit_TSL2561_Unified tsl = Adafruit_TSL2561_Unified(TSL2561_ADDR_FLOAT, 12345);

// Function to display sensor details
void displaySensorDetails(void)
{
    sensor_t sensor;
    tsl.getSensor(&sensor);
    delay(500);
}

// Function to configure the light sensor
void configureSensor(void)
{
    tsl.enableAutoRange(true);                            // Auto-gain
    tsl.setIntegrationTime(TSL2561_INTEGRATIONTIME_13MS); // Fast but low resolution
}

void setup()
{
    // Initialize serial communication
    Serial.begin(9600);

    // Set stepper motor speeds
    myStepper.setSpeed(100);
    myStepper1.setSpeed(100);

    // Initialize light sensor
    Serial.println("Light Sensor Test");
    if (!tsl.begin())
    {
        Serial.print("Ooops, no TSL2561 detected ... Check your wiring or I2C ADDR!");
        while (1)
            ;
    }
    displaySensorDetails();
    configureSensor();

    // Initialize distance sensor
    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);

    // Initialize temperature sensors
    sensors.begin();
}

void loop()
{
    // Move stepper motors one revolution in one direction
    Serial.println("Moving");
    myStepper.step(stepsPerRevolution);
    myStepper1.step(stepsPerRevolution);

    // Measure distance
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    duration = pulseIn(echoPin, HIGH);
    distance = duration * 0.034 / 2;
    float height = grounddistance - distance;
    Serial.print("Height: ");
    Serial.print(height);
    Serial.println(" cm");

    // Expected height calculation
    float expectedHeight = 1.8 * days;

    if (height <= 1)
    {
        return;
    }
    else
    {
        if (height < expectedHeight)
        {
            // Measure air quality
            int sensorValue = analogRead(GAS_SENSOR_PIN); // Read gas sensor value
            float smoke = analogRead(A0);                 // Read smoke value
            Serial.print(smoke);
            Serial.println(" ppm");

            // Measure temperature
            sensors.requestTemperatures();
            Serial.print("Temperature: ");
            Serial.print(sensors.getTempCByIndex(0));
            Serial.println(" °C");

            if (sensors.getTempCByIndex(0) > 21 && sensors.getTempCByIndex(0) <= 24)
            {
                Serial.println("Temperature is optimum");
            }
            else if (sensors.getTempCByIndex(0) < 21)
            {
                Serial.print("Temperature is too low for optimum growth");
            }
            else
            {
                Serial.print("Temperature is too high for optimum growth");
            }

            // Measure light intensity
            sensors_event_t event;
            tsl.getEvent(&event);

            if (event.light)
            {
                Serial.print(event.light);
                Serial.println(" lux");
            }
            else
            {
                Serial.println("Sensor overload");
            }

            if (event.light > 2000 && event.light < 4000)
            {
                Serial.println("Moderate sunlight (40% of midday sunlight)");
            }
            else if (event.light <= 2000)
            {
                Serial.println("Low light (below 40% of midday sunlight)");
            }
            else if (event.light >= 4000)
            {
                Serial.println("Good sunlight. Optimal for plants");
            }

            delay(10000);
        }
        else
        {
            if (n > 10)
            {
                int sensorValue = analogRead(GAS_SENSOR_PIN);
                float smoke = analogRead(A0);
                Serial.print(smoke);
                Serial.println(" ppm");

                sensors.requestTemperatures();
                Serial.print("Temperature: ");
                Serial.print(sensors.getTempCByIndex(0));
                Serial.println(" °C");

                sensors_event_t event;
                tsl.getEvent(&event);

                if (event.light)
                {
                    Serial.print(event.light);
                    Serial.println(" lux");
                }
                else
                {
                    Serial.println("Sensor overload");
                }
                n = 0;
            }
            else
            {
                n++;
                Serial.println("Crop size is optimum");
            }
        }
    }

    delay(100);
}