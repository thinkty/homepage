---
title:  "Source Chat - 직관적 챗봇 관리 플랫폼"
date:   2020-08-29
categories: 프로젝트
toc: true
---

구글에서 만든 [*Dialogflow*](https://cloud.google.com/dialogflow) 라는 플랫폼이 있다.
Dialogflow 를 이용하여 자연어 처리가 가능한 챗봇을 만들 수 있고 각종 플랫폼에 배포할 수도 있다.
그러나, 직접 Dialogflow 를 사용해봤을 때, 어느정도 간단한 챗봇을 만드는데는 별 지장이 없지만, *깊이있는 챗봇*을 만들 때는 가능은 하나 적합하지 않다고 판단했다.

여기서 *깊이있는 챗봇*이란, 대화 플로우에 복잡한 패턴이 발생하는 챗봇을 의미한다.
고객상담에서 사용되는 일반적인 챗봇은 깊이가 거의 없거나 한 자릿 수 밖에 안된다.
예를 들어 꽃집에서 주문을 하는 챗봇의 경우, 사용자가 원하는 꽃과 시간을 말하면 챗봇은 바로 예약을 진행하고 세션을 종료한다.
복잡한 챗봇의 경우, 사용자와 챗봇이 여러번 대화를 주고받으며 한 세션의 길이가 마치 일반적인 사람들이 대화하듯 변칙적이며 대체로 한번에 끝나지 않는다.
Dialogflow 를 사용하여 깊이있는 챗봇을 만들 수도 있겠지만 가끔씩 의도치않은 흐름을 타거나, 몇몇 특이한 상황에서는 흐름을 떠나서 다시 처음으로 돌아가기도 한다.

그리하여, Dialogflow 의 자연어 처리 능력을 바탕으로 챗봇을 직감적인 디자인으로 생성하고 관리하는 프로그램을 만들기 위해 이 프로젝트를 시작하게 되었다.

## 소개

위에서 언급했듯이, Dialogflow 를 사용하면서 겪은 문제점들을 해결하기 위해 이 프로젝트를 시작하게 되었다.
몇몇 문제점들을 읊어보자면:
- 챗봇을 편집하면서 흐름을 *직감적으로 보는 것*이 불가능
- 흐름을 좀 더 *자유롭게* 조절하거나 *복잡하게* 표현하는 것이 가능하지만 수작업이 많음

이 프로젝트는 위의 문제점들을 고치고 추가로 하나의 에이전트로 Slack, Discord, Facebook 과 같은 각종 채팅 플랫폼에서 접근할 수 있도록 하려고 한다.

## 프로젝트 구조

이 프로젝트는 크게 [에디터](https://github.com/thinkty/dialogflow-editor) 와 [서버](https://github.com/thinkty/source-chat) 로 나뉜다.
말 그대로, 에디터는 사용자가 사용하게 될 웹 애플리케이션으로 그래프를 작성하고 편집하는 앱이다.
서버는 에디터와 상호작용하는 프로그램으로 사용자가 작성한 그래프를 Dialogflow 와 연동하고, 각 사용자와 챗봇의 진행도를 관리한다.

### 에디터

![dialogflow editor](https://imgur.com/OfWKkHT.png)

Dialogflow Editor (에디터) 는 [React](https://reactjs.org/) 와 Uber 사의 [react-digraph](https://github.com/uber/react-digraph)를 활용하여 로 만든 그래프 편집기이다.
에디터의 주 요소로는 노드 편집기가 있다.
그래프의 노드와 직선을 선택하여 의도([Intent](https://cloud.google.com/dialogflow/es/docs/intents-overview))와 문맥([Context](https://cloud.google.com/dialogflow/es/docs/contexts-overview))을 수정할 수 있다.
현재, [https://editor.thinkty.net/](https://editor.thinkty.net/) 에서 직접 사용해서 챗봇의 흐름을 제작할 수 있다.
구체적으로 어떻게 앞서 언급한 문제점들을 해결하는지 사진을 통해서 보자.

![Dialogflow Console](https://imgur.com/QfYZ9iF.png)

위 사진은 Google 의 **Dialogflow 콘솔**이다.
콘솔을 통해 사용자는 의도(Intent)를 추가/수정/삭제할 수 있다.
그러나, 앞서 언급한 문제점처럼, 직감적으로 챗봇의 흐름을 볼 수는 없다.

![Dialogflow Editor](https://imgur.com/fABOX4k.png)

위 사진은 **Dialogflow Editor** 의 메인 화면이다.
Dialogflow 콘솔처럼 의도(Intent)를 추가/수정/삭제할 수 있고, 더 나아가 단축키로 훨씬 빠르고 간단하게 새로운 의도를 생성하거나 삭제할 수 있다.
보자마자 바로 그래프를 통해서 챗봇의 흐름을 파악할 수 있고 오른쪽의 편집기를 통해 Dialogflow 콘솔에서 [Entity](https://cloud.google.com/dialogflow/es/docs/entities-overview) 를 제외한 training phrases, fallback 등, 대부분의 항목들을 수정할 수 있다.
Entity 에 관해서는 아직 어떻게 추가할지 구상하고 있다.

Dialogflow 콘솔과 Dialogflow Editor 의 중요한 차이점이라면, 문맥(Context)이 그래프에서 각 노드(도형)를 이어주는 화살표를 통해 자동으로 배정된다는 것이다.
자동으로 배정된다는 점에서 사람의 수고가 덜고 추가적으로 더 복잡한 챗봇 흐름을 구현할 수 있다.
복잡한 챗봇 흐름의 예시로는 **분할-및-병합** (Split-and-Merge) 이 있다.

분할-및-병합 패턴이란, 말 그대로 흐름이 나뉘었다가 다시 같은 지점으로 모이는 패턴을 뜻한다.
예시로 도서관 챗봇을 볼 수 있다.
사용자는 도서관의 책을 빌리는 흐름을 타거나 도서관의 회의실을 예약하는 흐름을 탈 수 있다.
어떤 흐름을 따라 진행해도 결국에는 책을 대출하거나 회의실을 예약할 때 개인정보를 제공해야한다.
이처럼 나뉘었다가 다시 한 시점으로 모이는 것을 분할-병합 패턴이라고 하며 이러한 패턴을 Dialogflow 콘솔에서 follow-up intent 라는 것을 통해 구현할 수 있지만 많은 수작업이 필요하다.

Dialogflow Editor 에서는 모두 자동으로 정해지므로 완성된 그래프를 서버로 전송하여 처리하기만 하면 된다.
서버에서 돌아가는 Source Chat 은 전송된 그래프를 바탕으로 의도(Intent)를 업데이트하고 흐름을 통제한다.

노드 편집기에 이어 부가적인 기능으로는 그래프의 버전 관리 (Version Control) 와 불러오기/내보내기 (Import / Export) 가 있다.
버전 관리 기능은 서버를 통해 여러 버전의 그래프를 저장하고 불러오고 수정하여 업데이트 할 수 있다.
불러오기/내보내기는 JSON 에서 그래프를 읽거나 JSON 으로 내보낼 수 있고, 서버의 URL을 제공하여 그래프를 서버로 전송하여 그래프를 Dialogflow 와 연동시키는 작업을 진행할 수 있다.

### 서버

![server layout](https://imgur.com/o0VtSQj.png)

서버에서는 Source Chat 라는 프로그램이 실행되며 크게 두 가지 기능을 한다.
- 전송된 그래프를 처리 (에디터 모듈)
- 각종 채팅 플랫폼과 상호작용 (챗봇 모듈)

아래에는 두 가지 기능에 대한 간단한 설명이 있지만, [Github](https://github.com/thinkty/source-chat) 에 좀 더 자세하게 순차적으로 설명을 했다.

#### 에디터 모듈

에디터 모듈은 Dialogflow Editor 와의 상호작용을 담당한다.
Dialogflow Editor 에서 그래프를 전송 받으면 총 3 단계를 거쳐서 챗봇의 흐름을 업데이트한다.

1. 확인 (Validation) : 전송된 그래프가 정해진 규칙에 부합하고 추출 단계에서 문제가 없을지 확인
2. 추출 (Parsing) : 그래프에서 의도(Intent) 생성에 필요한 정보를 추출한 뒤, 의도들을 생성
3. 업데이트 (Updating) : 생성된 의도들을 Google 의 Dialogflow 콘솔로 전송하여 흐름을 업데이트하고, 흐름을 관리하기 위한 *State Table* 을 업데이트

3 단계에서 언급된 *State Table* 이란, 일종의 유한 상태 기계[(Finite State Automata)](https://ko.wikipedia.org/wiki/%EC%9C%A0%ED%95%9C_%EC%83%81%ED%83%9C_%EA%B8%B0%EA%B3%84)로 챗봇의 흐름을 담은 테이블이다.
챗봇의 흐름은 유한 상태 기계로 해석될 수 있다.
각 상태는 문맥(Context)에 해당되고 상태들을 이어주는 모서리는 사용자의 입력값 또는 의도(Intent)에 해당한다.

![finite automata diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/DFA_example_multiplies_of_3.svg/250px-DFA_example_multiplies_of_3.svg.png)

이러한 유한 상태 기계는 [*State Transition Table*](https://en.wikipedia.org/wiki/State_transition_table) 로 변환될 수 있으며, Google 의 흐름 제어없이, 오직 변환된 State Transition Table 을 통해 챗봇의 흐름을 완전히 통제할 수 있다.
이로서 Dialogflow 에서는 오직 자연어 처리 능력만을 사용하고 자체적인 흐름 제어를 통해 의도치않은 흐름을 타는 것을 방지할 수 있다.
State Table 의 자료구조는 Nested HashMap 으로 형식은 <code>Map&lt;String, Map&lt;String, String[]&gt;&gt;</code> 과 같다.
바깥쪽 Map 의 key 는 input context 이고 value 에 해당하는 Map 은 intent 와 다음 input context 들을 담고있다.

![State Table 예시 그림](https://i.imgur.com/VKE1j6R.png)

그림 예시와 함께 설명하자면, 현재 사용자의 맥락(위치)이 Hello-1 일 경우, key 가 Hello-1 이며 value 에 있는 Map 은 Hello-4 와 Hello-5 가 각 엔트리의 key 가 되며 Hello-2 와 Hello-3 가 각 key 의 value 가 된다.

위처럼 간단한 그래프의 경우, Nested HashMap 을 사용하기에 공간-대비-속도 측면에서 큰 이득이 없어보이나 그래프의 규모가 커질수록 조회하는 시간이 Tree 나 Multi-dimensional Array 에 비해 월등할 것이므로 적합한 판단이라고 생각한다.

#### 챗봇 모듈

에디터 모듈에서 Google 의 Dialogflow 에 의도들(Intents)을 업데이트하고 State Table 도 최신화한 뒤, 사용자들은 *어댑터*를 통해 각종 플랫폼에서 챗봇으로 연락을 취할 수 있다.
*어댑터*의 기능은 채팅 플랫폼과 서버간의 상호작용을 담당하며, 사용자가 메시지를 채팅 플랫폼으로 보내면 채팅 플랫폼에서는 서버로 메시지와 각종 정보를 전송하고 서버에서는 사용자의 현재 맥락과 입력값을 바탕으로 다음 흐름으로 가며 답장을 한다.

각 채팅 플랫폼마다 상호작용하는 방식은 REST API 나 Web Socket 을 사용하여 비슷하지만, 주고받는 메시지의 형식이 고유하기에 어댑터는 플랫폼에 맞춤 제작되어 담당한다.
그러나, 모두 똑같은 State Table 을 사용하기에 자원을 효율적으로 사용하며 관리에 유용하다.

## 계획

앞서 언급했듯이, 이 프로젝트는 구동하기 위해 필요한 최소한의 기능들로만 이루어져있다.
현시점의 개인적인 능력의 한계로 많은 부분이 타인이 봤을 때 미흡할 수도 있다.
그러나, 발전 가능한 부분이 많다는 것은 그만큼 포텐셜이 높다고 생각한다.
Entity 지원도 도입해야 하고, 다양한 형태의 메시지도 지원해야하며, 타 채팅 플랫폼을 통해 추가하고 향상할 부분이 많다.

## 추신

![dialogflow cx](https://imgur.com/Rw5VwCk.png)

며칠전에 Google 에서 [DialogflowCX](https://cloud.google.com/dialogflow/cx/docs) 라는 제품을 출시했으며 그래프 에디터를 도입한 점에서 역시 구글이라는 생각이 들었다.
사용해봤을 때, 물론 내가 만든 것보다 훨씬 좋지만, 베타 버젼이라 그런지 아직은 다듬어질 부분이 좀 있는 것처럼 느껴졌다.
