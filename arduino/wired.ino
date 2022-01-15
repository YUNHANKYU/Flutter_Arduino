#include <LiquidCrystal_I2C.h>
#include <Adafruit_NeoPixel.h>

#define pxlPIN 10   //네오픽셀 컨트롤 핀
#define pCOUNT 8  //네오픽셀 LED 갯수

//int led = LED_BUILTIN;
int led = 10;

// LCD 선언. 
// 0x27이 주소값인데 여기가 실제랑 다르면 네모박스만 나오거나 오류뜸.
LiquidCrystal_I2C lcd(0x27, 16, 2);

// neoPixel 선언
Adafruit_NeoPixel strip = Adafruit_NeoPixel(pCOUNT, led, NEO_GRB + NEO_KHZ800); 

void setup() {
  // dart 코드 통신 관련
  Serial.begin(9600);

  // led_builtin 관련
  pinMode(led, OUTPUT);
  
  // lcd 관련
  lcd.begin();

  // neoPixel 관련 
  strip.begin();
  strip.setBrightness(30);
  strip.show();
}                                                                                                                                                                                                                                                                                                                                     

void loop() {
  // put your main code here, to run repeatedly:
//  digitalWrite(led, HIGH);
//
//  delay(1000);               
//
//  digitalWrite(led, LOW);   
//
//  delay(1000); 
  char c;
  if(Serial.available())
  {
    c = Serial.read();
    lcd.setCursor(0,0);
    lcd.print(c);

    // c는 dart 에서 보낸 string의 끝자리를 가짐
    // Ex. 'start' -> c == 't'
    // Ex. 'stop' -> c == 'p'
    if(c == 't'){
//      digitalWrite(LED_BUILTIN, HIGH);
      strip.setPixelColor(0, strip.Color(255, 0, 0));
      strip.setPixelColor(strip.numPixels()-1, strip.Color(0,255,0));
      strip.show();
    }else if(c == 'p'){
//      digitalWrite(LED_BUILTIN, LOW);
      strip.clear();
      strip.show();      
    }
  }
}