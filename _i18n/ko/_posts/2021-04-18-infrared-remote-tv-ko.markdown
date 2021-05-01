---
title:  "아두이노로 LG TV 조작하기"
date:   2021-04-18
categories: 프로젝트
toc: true
---

얼마 전, 세컨드 모니터가 필요하게돼서 집에 있는 LG TV를 가져왔다.
리모콘은 없어졌고 터치 버튼이 인식이 원활하지 않아서 고민하던 중, 리모콘을 직접 만들기로 했다.
사실 버튼만 고치는 것이 더 쉬운 방법이었을 것 같지만 사람은 때론 실수를 하기도 한다.

## 준비물

작은 프로젝트에 쓰인 모듈은 다음과 같다.
- 적외선 송신 모듈
- 푸시버튼 3개 (전원, 확인, 메뉴)
- 네비게이션용 조이스틱

외부 라이브러리는 [IRremote](https://github.com/Arduino-IRremote/Arduino-IRremote) 를 사용하여 적외선 모듈로 신호를 전송하였다.

## 회로도 및 사진

![회로도](/assets/images/2021-04-18-infrared-remote-tv-1.png)

회로도를 작성하기 위해 사용한 프로그램은 [Circuit.io](https://www.circuito.io/)라는 웹 앱플리케이션으로 사용가능한 모듈 숫자는 적지만 일단 무료이고 브라우저로 조작할 수 있다는 점에서 편리했다.

![사진](/assets/images/2021-04-18-infrared-remote-tv-2.jpg)

선들이 스파게티지만, 일단 작동은 잘하니 상관은 없다.

## 코드

우선 코드를 통해서 하나하나 살펴보도록 하자.

{% highlight cpp %}
// IR
// LG has data bits similar to NEC but in reverse (Most Significant Bit first)
#define IR_SEND_PIN 8
#include <IRremote.h>
IRData IRSendData;

// Joystick
#define JOY_X A0
#define JOY_Y A1
enum dir { CENTER = -1, UP = 0x20DF02FD, DOWN = 0x20DF827D, LEFT = 0x20DFE01F, RIGHT = 0x20DF609F };
dir current;

// Power Button
#define POWER_BUTTON 3
#define POWER_CMD 0x20DF10EF

// Settings Button
#define SETTINGS_BUTTON 4
#define SETTINGS_CMD 0x20DFC23D

// Confirm Button
#define CONFIRM_BUTTON 5
#define CONFIRM_CMD 0x20DF22DD

// Function to read the direction of the joystick based on x and y values
void readJoystick() {
  int x = analogRead(JOY_X);
  int y = analogRead(JOY_Y);

  dir temp = NULL;
  // The module is in 10 bit for x and y
  if (x < 600 && x > 400 && y == 0) {
    temp = LEFT;
  }
  if (x < 600 && x > 400 && y == 1023) {
    temp = RIGHT;
  }
  if (x == 0 && y < 600 && y > 400) {
    temp = DOWN;
  }
  if (x == 1023 && y < 600 && y > 400) {
    temp = UP;
  }
  if (x < 600 && x > 400 && y < 600 && y > 400) {
    temp = CENTER;
  }

  // Only update value when change has occurred
  if (temp && temp != current) {
    current = temp;
    
    // Send all signals except for center as center is default
    // This allows sending the same signal in sequence
    if (current != CENTER) {
      IrSender.sendNECMSB(current, 32, false);
      delay(110);
    }
  }
}

// Function to read from multiple (power, settings, confirm) push-buttons
void readPushButton() {
  if (digitalRead(POWER_BUTTON) == HIGH) {
    IrSender.sendNECMSB(POWER_CMD, 32, false);
    delay(110);
  }

  if (digitalRead(SETTINGS_BUTTON) == HIGH) {
    IrSender.sendNECMSB(SETTINGS_CMD, 32, false);
    delay(110);
  }

  if (digitalRead(CONFIRM_BUTTON) == HIGH) {
    IrSender.sendNECMSB(CONFIRM_CMD, 32, false);
    delay(110);
  }
}

void setup() {
  Serial.begin(9600);
  pinMode(POWER_BUTTON, INPUT);
  pinMode(CONFIRM_BUTTON, INPUT);
  pinMode(SETTINGS_BUTTON, INPUT);
  IrSender.begin(IR_SEND_PIN, ENABLE_LED_FEEDBACK);
  delay(1000);
}

void loop() {
  // Joystick input
  readJoystick();

  // PushButton input
  readPushButton();
}
{% endhighlight %}

[Github](https://github.com/thinkty/arduino-remote)

간단하게 요약하자면, ```setup``` 에서 푸시버튼 및 IR 관련 초기설정을 해주었고, ```loop``` 에서는 지속적으로 사용자의 입력을 읽고 있다.
사용자는 앞서 언급한 네비게이션용 조이스틱으로 메뉴에서 방향을 조절할 수 있고, 나머지 세 버튼을 통해 전원을 껐다 키고, 메뉴를 열거나 확인을 할 수 있다.
가장 위에서부터 시작하자면,

{% highlight cpp %}
// IR
// LG has data bits similar to NEC but in reverse (Most Significant Bit first)
#define IR_SEND_PIN 8
#include <IRremote.h>
IRData IRSendData;
{% endhighlight %}

여기서는 IR 관련 라이브러리를 불러오고있고 실제 신호 송신 함수를 호출할 때 필요한 변수를 선언하고 있다.
주석을 통해 알 수 있듯이, LG 는 NEC 와 비슷한 적외선 프로토콜을 가지고 있다.
비록 2017년 [자료](http://www.remotecentral.com/cgi-bin/forums/viewpost.cgi?1335768)이지만, LG 의 적외선 코드는 32 비트로 8 비트씩 4개의 파트로 나뉘어져있다.
첫 번째 파트는 Low Custom 이고 두 번째 파트는 첫 파트의 역(inverse)으로 High Custom 이라 불린다.
세 번째와 네 번째도 마찬가지로 역이며 이 파트는 명령어(Command)를 보유하고 있다.
방금 설명한 프로토콜은 NEC 와 매우 유사하다.

![NEC protocol](https://techdocs.altium.com/sites/default/files/wiki_attachments/296329/NECMessageFrame.png)

이 라이브러리에서는 NEC 프로토콜로 보낼 시, LSB 가 우선시되므로 나중에는 MSB 를 우선 보내는 함수를 사용해야한다.

{% highlight cpp %}
// Joystick
#define JOY_X A0
#define JOY_Y A1
enum dir { CENTER = -1, UP = 0x20DF02FD, DOWN = 0x20DF827D, LEFT = 0x20DFE01F, RIGHT = 0x20DF609F };
dir current;

// Power Button
#define POWER_BUTTON 3
#define POWER_CMD 0x20DF10EF

// Settings Button
#define SETTINGS_BUTTON 4
#define SETTINGS_CMD 0x20DFC23D

// Confirm Button
#define CONFIRM_BUTTON 5
#define CONFIRM_CMD 0x20DF22DD
{% endhighlight %}

이 파트에서는 사용자 입력에 쓰일 다양한 버튼과 조이스틱의 핀 번호 및 데이터 코드를 설정해주고 있다.

{% highlight cpp %}
// Function to read the direction of the joystick based on x and y values
void readJoystick() {
  int x = analogRead(JOY_X);
  int y = analogRead(JOY_Y);

  dir temp = NULL;
  // The module is in 10 bit for x and y
  if (x < 600 && x > 400 && y == 0) {
    temp = LEFT;
  }
  if (x < 600 && x > 400 && y == 1023) {
    temp = RIGHT;
  }
  if (x == 0 && y < 600 && y > 400) {
    temp = DOWN;
  }
  if (x == 1023 && y < 600 && y > 400) {
    temp = UP;
  }
  if (x < 600 && x > 400 && y < 600 && y > 400) {
    temp = CENTER;
  }

  // Only update value when change has occurred
  if (temp && temp != current) {
    current = temp;
    
    // Send all signals except for center as center is default
    // This allows sending the same signal in sequence
    if (current != CENTER) {
      IrSender.sendNECMSB(current, 32, false);
      delay(110);
    }
  }
}
{% endhighlight %}

이 부분은 조이스틱의 입력을 읽는 함수로 축이 x 와 y 가 있는 조이스틱의 결과값을 바탕으로 현재 방향을 결정한다.
좀 더 좋은 코드를 쓸 수 있을 것 같으며 아직은 배울 것이 많은 것 같다.

{% highlight cpp %}
// Function to read from multiple (power, settings, confirm) push-buttons
void readPushButton() {
  if (digitalRead(POWER_BUTTON) == HIGH) {
    IrSender.sendNECMSB(POWER_CMD, 32, false);
    delay(110);
  }

  if (digitalRead(SETTINGS_BUTTON) == HIGH) {
    IrSender.sendNECMSB(SETTINGS_CMD, 32, false);
    delay(110);
  }

  if (digitalRead(CONFIRM_BUTTON) == HIGH) {
    IrSender.sendNECMSB(CONFIRM_CMD, 32, false);
    delay(110);
  }
}
{% endhighlight %}

조이스틱 입력 함수와 마찬가지로 전원, 메뉴, 확인 입력을 읽는 함수다.
버튼을 누를 시, ```IrSender.sendNECMSB()``` 를 호출하는데, 앞서 언급한대로 MSB 를 가장 먼저 보내는 방법을 사용하고 있다.
그것이 LG 니까.

{% highlight cpp %}
void setup() {
  Serial.begin(9600);
  pinMode(POWER_BUTTON, INPUT);
  pinMode(CONFIRM_BUTTON, INPUT);
  pinMode(SETTINGS_BUTTON, INPUT);
  IrSender.begin(IR_SEND_PIN, ENABLE_LED_FEEDBACK);
  delay(1000);
}

void loop() {
  // Joystick input
  readJoystick();

  // PushButton input
  readPushButton();
}
{% endhighlight %}

가장 마지막 부분이자 이 프로젝트를 한 페이지에 볼 수 있는 부분으로, 여기서는 버튼 및 적의선 송신 모듈을 초기 설정해주고 사용자의 입력을 기다린다.

## 마무리
우연치않게 시작하게된 소규모 프로젝트였지만, IR 통신 및 프로토콜에 대해 많이 알게되었다.
처음에는 RF 와 IR 의 차이도 잘 몰랐지만 인터넷에 널린 자료들 및 여러 시행착오를 통해 TV 문제도 해결할 수 있었다.
운이 없게도, 리모콘을 만들어서 몇번 설정을 건드려주니 더 이상 리모콘이 필요없어졌지만, 그래도 좋은 경험이었다.

IR 에 대해 알고싶다면, 이 [동영상](https://www.youtube.com/watch?v=gADIb1Xw8PE)을 볼 것을 추천한다.
적외선의 특징과 적용 과정을 프로젝트를 통해 알려주는데 아주 유익하다.
