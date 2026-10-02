# Cyberpunk 2077 군대/세력전 모드

## 최종 목표
플레이어가 지휘하는 **내 군대**를 만들고, 이후 **다른 세력의 군대**와 Night City 구역을 두고 전쟁·땅따먹기를 하는 모드.

## 핵심 설계: 2계층 구조
게임은 플레이어 주변만 스트리밍/시뮬레이션하므로, 넓은 범위는 숫자로 추상화한다.

- **숫자 층 (항상 동작)**: 부대 명단(인원·장비·체력), 세력별 병력, 구역별 지배도. 플레이어가 없는 곳의 전투는 수치로 자동 판정.
- **실체 층 (플레이어 주변만)**: 부대원·적을 실제 NPC로 스폰해 게임 AI로 전투. 결과를 숫자 층에 다시 반영.

화면 동시 교전 인원은 수십 명 수준이 한계 → "대군"은 숫자 층에서만, 화면은 그 일부만 교전 (Mount & Blade식).

## 로드맵

### 0단계: 환경 구축
- 프레임워크 설치: RED4ext → redscript → Cyber Engine Tweaks → ArchiveXL → TweakXL → Codeware
- 참고용: AMM (Appearance Menu Mod) — 동료 스폰 로직 학습용 (Lua 소스)
- 개발 보조: RedHotTools (redscript/archive 핫 리로드)
- 완료 조건: 게임 내 CET 오버레이·콘솔 동작 확인

### 1단계: 내 부대 프로토타입 (CET Lua)
- NPC 1명 아군 스폰 → 플레이어 추종 → 적과 교전
- N명으로 확장
- 단축키 명령: 따라와 / 여기서 대기 / 대상 공격
- 완료 조건: 부대를 데리고 다니며 함께 싸울 수 있다

### 2단계: 부대 관리 (redscript)
- 부대 명단을 세이브에 저장, 로드 시 재스폰 (스폰 NPC는 기본적으로 저장되지 않음)
- 모집: 고용(유로딧) / 쓰러뜨린 갱단원 영입
- 장비·등급·유지비·전사 처리
- 완료 조건: 세이브/로드를 넘어 부대가 유지되고 성장한다

### 3단계: 세력과 영토 전쟁
- 구역별 세력 지배도 (바닐라 갱 세력과 적대 관계 활용)
- 적 세력의 병력 모집·공격
- 플레이어 현장 = 실전투, 부재 = 수치 자동 판정
- 영토 현황 지도 UI
- 완료 조건: 세력 간 구역 점령이 시간에 따라 변하고 플레이어가 개입할 수 있다

## 개발 원칙
- 새 기능은 CET Lua로 먼저 검증(핫 리로드) → 확정되면 redscript로 이식. RED4ext(C++)는 꼭 필요할 때만.
- 게임 API(클래스·함수·TweakDB 레코드 이름)는 기억으로 쓰지 말고 NativeDB / CET TweakDB 에디터 / 기존 모드 소스로 확인.
- 이미 스폰된 NPC·적용된 효과는 리로드에 반영 안 될 수 있음 → 재스폰 또는 세이브 재로드로 확인.

## 환경
- 게임: Steam, `C:\Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077`
- 모딩 시 Steam 자동 업데이트 끄기 (패치마다 RED4ext/CET 호환이 깨짐)

## 참고 자료
- 모딩 위키: https://wiki.redmodding.org
- NativeDB: https://nativedb.red4ext.com
- 모드/프레임워크 배포: Nexus Mods
- **TweakDB 원본 (로컬)**: `<게임>\tools\redmod\tweaks` — 레코드 ID·상속·필드를 grep으로 확인. NPC 레코드는 `...\database\characters\npcs\records\` 아래 (시민: `crowds\communities.tweak`, 세력: `gameplay\factions\*.tweak`)
