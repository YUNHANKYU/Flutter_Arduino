# flutter_arduino

Flutter로 만든 어플리케이션에서 유선, 무선으로 아두이노를 제어하는 예제 프로젝트입니다 :)

## Dart Side

이 프로젝트는 유, 무선으로 아두이노를 제어하는데 아래 두 플러그인을 사용합니다.

### 유선
- [usb_serial](https://pub.dev/packages/usb_serial)


유선 연결에서는 usb_serial 플러그인을 사용해서 아두이노와 연결합니다.


### 무선
- [flutter_bluetooth_serial](https://pub.dev/packages/flutter_bluetooth_serial)

무선 연결에서는 flutter_bluetooth_serial 플러그인을 사용해서 아두이노와 연결합니다. 

무선 연결을 위해서는 아두이노 블루투스 모듈(HC-06)이 필요합니다.

## Arduino Side

/arduino 폴더에 유, 무선 각각 예제 파일을 올려두었습니다.