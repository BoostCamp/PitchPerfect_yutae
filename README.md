#### PitchPerfect 프로젝트  최 유 태 (yutae)
------------------------------
## VOVO - 목소리에 목소리를 더 하다.

![alt tag](https://cloud.githubusercontent.com/assets/14192093/21926602/d614110e-d9c5-11e6-843e-8a565d45ceb6.png)


[![VOVO Video](https://cloud.githubusercontent.com/assets/14192093/21926578/b35cb6b6-d9c5-11e6-9aef-d29433b0b9cd.png)](https://youtu.be/rXhGd22EPY8 "VOVO Video")
#### ( 위의 사진을 클릭 하시면 Youtube 로 연결됩니다. )

## 추가 기능
+ Wave - 녹음 할 때 Siri 처럼 음파 wave 로 녹음 중인 것을 시각적으로 표현 하였습니다.
+ 편집 기능 - 녹음한 파일을 편집 할 수 있습니다.
+ Dial Layout - 전화기의 다이얼 느낌으로 돌려가면서 재생 할 수 있습니다. 클릭으로도 재생 가능합니다.
+ Universal - iPhone, iPad (Landscape)
+ 총 10개의 효과음 - 드럼, 오르간, 자동차, 박수 소리를 추가 하였습니다.
+ 재생 될 때 currentTime 을 Animation 과 시간을 표시함으로 시각적으로 표현 하였습니다.
+ 공유 기능 - 변조된 목소리 파일을 SNS 공유 할 수 있습니다.


## 예외 처리 및 기술
+ open, openURL : 마이크 권한 체크 -> 설정
+ 다른 앱에서 오디오 플레이 한 후 다시 돌아와도 Speaker Mode 유지
+ CallKit : 통화 중 일때 Waiting 화면
+ Project Structure : MVC 패턴 기반의 프로젝트 구조화
+ Navigation Controller, Modal Controller
+ Extension : UIColor Extension 하여 Public inner Class로 앱의 themeColor를 지정
+ Human Interface Guidelines 에 명시된 Navigation Bar item의 이미지 크기 등을 따름
+ Optional Binding : Optional Variable & Object Manager
+ GCD(Grand Central Dispatch) : 즉시 변동되야할 UI를 Main Thread async 로 비동기 실행, 공유 기능에서 파일 복제를 Global Thread async 로 비동기 실행
+ File System : 녹음 중 취소 누를 경우 FileManager의 제거 함수를 사용하여 파일 삭제, 편집 되는 여러 파일들을 temp 폴더에 저장하여 앱을 종료시 삭제 등
+ Key-Value-Observering : Maintain Speaker Mode, didOrientationChanged
+ Apple 기본으로 제공하는 여러 Delegate 사용
+ Custom Delegate Protocol Edit
+ Git Branch 전략 (Master, Developer, Feature, Release)

## App Store 앱 설명
#### VOVO - 목소리에 목소리를 더하다.
다양한 효과로 음성변조, 심플한 디자인, 공유 기능 지원, 광고 절대 없음. <br>
실시간으로 재생 되는 두꺼운 목소리, 얇은 목소리, 느리게, 빠르게, 에코 등 여러 재밌는 효과 들로 음성 변조 한 후 친구한테 보내보세요! <br>
주의 - 이 앱은 중독성이 강합니다.

iPhone, iPad 마이크를 사용하여 녹음을 해보세요. <br>
돌리면서 재생 시켜 여러 효과음으로 변조된 음성을 들어보세요.
변조된 음성을 SNS로 친구에게 보내보세요.

VOVO와 즐거운 시간 보내세요 !
