#include <OneWire.h>
#include <DallasTemperature.h>
#include <SPI.h>
#include <SD.h>
#define ONE_WIRE_BUS 2 

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);
float temp=0;
void setup() {
  Serial.begin(9600);
  while (!Serial) {
              ;
  }
  sensors.begin();
}


void loop() {
  String dataString = "";
  sensors.requestTemperatures();
  int sensorValue = analogRead(A0);
  float voltage = sensorValue * (5.0 / 1023.0);
  float temp = (sensors.getTempCByIndex(0));
  dataString += "V: ";
  dataString += String(voltage);
  dataString += ", C: ";
  dataString += String(temp);
  Serial.println(dataString);
  delay(1000);
}
