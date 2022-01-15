#include <SoftwareSerial.h>

SoftwareSerial BTSerial(7, 8);

int led = LED_BUILTIN;

void setup() {
  pinMode(led, OUTPUT);
  Serial.begin(9600); // 시리얼 통신 선언 (보드레이트 9600)
  BTSerial.begin(9600);  
}

void loop() {

  // Bluetooth 연결된 장치에서 읽은 값을 PC 에 보내는 부분 
  if(BTSerial.available()) {
    char a = BTSerial.read();
    Serial.write(a);
    if (a == '0'){
      digitalWrite(LED_BUILTIN, LOW); // If value is 0, turn OFF the device
    }
    else if (a == '1'){
      digitalWrite(LED_BUILTIN, HIGH);
    }else{
      Serial.write("eeeeee");
    }
  }

  // PC 에서 읽은 값을 Bluetooth 연결된 장치에 보내는 부분
  if(Serial.available()) {
    BTSerial.write(Serial.read());
  }
}