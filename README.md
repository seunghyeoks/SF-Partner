# SFonMenuBar

맥 메뉴바에서 시스템 리소스를 실시간으로 모니터링할 수 있는 SwiftUI 앱입니다. SF 심볼을 사용해서 시각적으로 시스템 상태를 표현합니다.

## 주요 기능

- **실시간 시스템 모니터링**
  - CPU 사용률
  - 메모리 사용률  
  - 네트워크 활동

- **SF 심볼 기반 시각화**
  - `cellularbars` 아이콘을 사용한 리소스 상태 표시
  - 리소스 사용률에 따라 동적으로 변경되는 메뉴바 아이콘
  - 1~4단계의 막대로 사용률 표현

- **직관적인 UI**
  - 메뉴바에서 간편한 접근
  - 색상으로 구분된 상태 표시 (녹색/노랑/주황/빨강)
  - 프로그레스 바를 통한 시각적 피드백

## 시작하기

1. Xcode에서 프로젝트를 엽니다
2. `Product > Run` 또는 `Cmd+R`로 앱을 실행합니다
3. 메뉴바에 cellularbars 아이콘이 나타납니다
4. 아이콘을 클릭하면 상세 리소스 정보를 볼 수 있습니다

## SF 심볼 사용 예시

`cellularbars` 심볼은 `variableValue` 매개변수를 사용해서 동적으로 채워집니다:

```swift
Image(systemName: "cellularbars", variableValue: 0.25)  // 25% 채워짐
Image(systemName: "cellularbars", variableValue: 0.50)  // 50% 채워짐  
Image(systemName: "cellularbars", variableValue: 0.75)  // 75% 채워짐
Image(systemName: "cellularbars", variableValue: 1.0)   // 100% 채워짐
```

- `variableValue: 0.0-0.25`: 낮은 사용률 (1칸 채워짐)
- `variableValue: 0.26-0.50`: 보통 사용률 (2칸 채워짐)
- `variableValue: 0.51-0.75`: 높은 사용률 (3칸 채워짐) 
- `variableValue: 0.76-1.0`: 매우 높은 사용률 (4칸 채워짐)

## 요구사항

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## 라이센스

MIT License
