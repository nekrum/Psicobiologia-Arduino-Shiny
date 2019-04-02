#include <SPI.h>
#include <SD.h>
#include <OneWire.h>
#include <DallasTemperature.h>
 
// Pin donde se conecta el bus 1-Wire
const int pinDatosDQ = 7;

// Instancia a las clases OneWire y DallasTemperature
OneWire oneWireObjeto(pinDatosDQ);
DallasTemperature sensorDS18B20(&oneWireObjeto);

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  while (!Serial) {
              ; // wait for serial port to connect. Needed for native USB port only
  }
  sensorDS18B20.begin(); 
          
  Serial.print("Initializing SD card... ");
  if (!SD.begin(9)) {
    Serial.println("Initialization failed");
    return;
  }
  Serial.println("Initialization done");     
}


void loop() {
  String dataString = "";
  sensorDS18B20.requestTemperatures();
  int sensorValue = analogRead(A0);
  dataString += "V: ";
  dataString += String(sensorValue);
  dataString += ",";
  dataString += "C: ";
  float voltage = sensorValue * (5.0 / 1023.0);
  dataString += String(sensorValue);
  Serial.println(dataString);
  SD.open("datalog.txt", FILE_WRITE);
  if (myFile) {
    Serial.print("Writing to testsd.txt...");
    myFile.println(dataString);
    myFile.close();
    Serial.println("Done");
   } else {
    // If the file didn't open, print an error:
    Serial.println("Error opening testsd.txt");
   }
}
