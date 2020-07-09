#include <NewPing.h>
#define TRIGGER_PIN 6
#define ECHO_PIN 5
#define MAX_DISTANCE 400
#define TRIGGER_PIN2 2
#define ECHO_PIN2 3
#define MAX_DISTANCE2 400
//#define TRIGGER_PI3 2
//#define ECHO_PIN3 3
//#define MAX_DISTANCE3 200
int numprueba = 1000;
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);
NewPing sonar2(TRIGGER_PIN2, ECHO_PIN2, MAX_DISTANCE2);
//NewPing sonar3(TRIGGER_PIN3, ECHO_PIN3, MAX_DISTANCE2);

String msg = ""; // mensaje que mandamos a Processing

void setup() {
  Serial.begin(9600);
}

void loop() {

  //SENSOR 1
  //delay(50);
  unsigned int uS = sonar.ping();
  pinMode(ECHO_PIN, OUTPUT);
  digitalWrite(ECHO_PIN, LOW);
  pinMode(ECHO_PIN, INPUT);

  unsigned int uS2 = sonar2.ping();
  pinMode(ECHO_PIN2, OUTPUT);
  digitalWrite(ECHO_PIN2, LOW);
  pinMode(ECHO_PIN2, INPUT);

  msg = (uS / US_ROUNDTRIP_CM);
  //msg = msg + "cm";
  msg = msg + ",";
  msg = msg + (uS2 / US_ROUNDTRIP_CM);
  msg = msg + ",";
  //msg = msg + (uS3 / US_ROUNDTRIP_CM);
  //msg = msg + ",";
  msg = msg + "\n"; // final del mensaje

  //Serial.print("MENSAJE: "); // debug por si lo queremos ver en el serial monitor
  Serial.println(msg);

  //Serial.print("Ping: ");
  //Serial.print(uS / US_ROUNDTRIP_CM);
  //Serial.println("cm");
  //Serial.print(",");
  //Serial.println(numprueba);
  //int cm = uS / US_ROUNDTRIP_CM;
  //Serial.println(cm);
  delay(20);

   delay(50);

  //Serial.print("Ping: ");
  //Serial.println(uS2 / US_ROUNDTRIP_CM);
  //Serial.println("cm");
  //Serial.print(",");
  //Serial.println(numprueba);
  //int cm = uS / US_ROUNDTRIP_CM;
  //Serial.println(cm);
  delay(20);

  /*   delay(50);
    unsigned int uS3 = sonar3.ping();
    pinMode(ECHO_PIN3, OUTPUT);
    digitalWrite(ECHO_PIN3, LOW);
    pinMode(ECHO_PIN3, INPUT);
    //Serial.print("Ping: ");
    Serial.println(uS3 / US_ROUNDTRIP_CM);
    //Serial.println("cm");
    Serial.print(",");
    //Serial.println(numprueba);
    //int cm = uS / US_ROUNDTRIP_CM;
    //Serial.println(cm);
    delay(20);*/


}
