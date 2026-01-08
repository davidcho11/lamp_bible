# 성경 통독 앱 설계서

**프로젝트명**: 함께 성경 읽기 (Bible Reading Together)  
**버전**: 1.0.0  
**작성일**: 2025-01-07  
**플랫폼**: Flutter (iOS/Android)

---

## 📑 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [기능 명세](#3-기능-명세)
4. [데이터베이스 설계](#4-데이터베이스-설계)
5. [화면 설계](#5-화면-설계)
6. [기술 스택](#6-기술-스택)
7. [주요 알고리즘](#7-주요-알고리즘)
8. [보안 및 성능](#8-보안-및-성능)
9. [배포 전략](#9-배포-전략)

---

## 1. 프로젝트 개요

### 1.1 프로젝트 목적
- 1년 365일 성경 통독을 체계적으로 관리
- YouTube 기반 공동체 성경읽기 콘텐츠 제공
- 개인 묵상 노트 작성 및 진행률 추적
- 성경 66권 개요 학습 지원

### 1.2 주요 목표
- 사용자 친화적인 UI/UX 제공
- 오프라인 우선 동작 (SQLite 기반)
- 다국어 지원 (한국어/영어)
- 다크모드 지원
- 반응형 디자인 (모든 모바일 기기 대응)

### 1.3 타겟 사용자
- 체계적인 성경 통독을 원하는 기독교인
- 공동체 성경읽기 프로그램 참여자
- 성경 공부를 시작하는 초신자
- 묵상 노트를 작성하고 싶은 사용자

---

## 2. 시스템 아키텍처

### 2.1 전체 아키텍처

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  ┌─────────────────────────────────┐   │
│  │   Screens (UI)                  │   │
│  │   - HomeScreen                  │   │
│  │   - CalendarScreen              │   │
│  │   - ReadingDetailScreen         │   │
│  │   - BibleBooksScreen            │   │
│  │   - BookDetailScreen            │   │
│  │   - SettingsScreen              │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│      Business Logic Layer               │
│  ┌─────────────────────────────────┐   │
│  │   Providers (State Management)  │   │
│  │   - BibleReadingProvider        │   │
│  │   - BibleBooksProvider          │   │
│  │   - ReadingHistoryProvider      │   │
│  │   - UserNoteProvider            │   │
│  │   - ThemeProvider               │   │
│  │   - CsvImportProvider           │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  ┌─────────────────────────────────┐   │
│  │   Services                      │   │
│  │   - DatabaseHelper              │   │
│  │   - DateHelper                  │   │
│  │   - CsvDownloadService          │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │   Local Storage                 │   │
│  │   - SQLite Database             │   │
│  │   - Asset Files (CSV)           │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│        External Services                │
│  - YouTube API (url_launcher)           │
│  - CSV Server (https://lamp.empluses.com)│
└─────────────────────────────────────────┘
```

### 2.2 디자인 패턴

#### 2.2.1 상태 관리: Provider 패턴
- **선택 이유**: 
  - Flutter 공식 권장 패턴
  - 간단하고 직관적
  - 불필요한 리빌드 최소화
  - 프로젝트 규모에 적합

#### 2.2.2 Repository 패턴
- **구조**:
  ```
  Screen → Provider → Repository → Database
  ```
- **장점**:
  - 데이터 소스 추상화
  - 테스트 용이성
  - 유지보수성 향상

#### 2.2.3 MVVM 패턴
- **Model**: 데이터 모델 (BibleReading, BibleBook 등)
- **View**: UI 위젯 (Screens)
- **ViewModel**: Provider 클래스

### 2.3 데이터 흐름

```
User Action
    ↓
Widget Event
    ↓
Provider Method Call
    ↓
Database Operation (SQLite)
    ↓
Provider State Update
    ↓
notifyListeners()
    ↓
UI Rebuild (Consumer Widget)
```

---

## 3. 기능 명세

### 3.1 핵심 기능

#### 3.1.1 성경 통독 관리
| 기능 | 설명 | 우선순위 |
|------|------|----------|
| 매일 읽기 | 날짜별 성경 읽기 URL 제공 | 높음 |
| 완료 표시 | 읽기 완료 체크 | 높음 |
| 진행률 추적 | 연간 진행률 시각화 | 높음 |
| 묵상 노트 | 날짜별 묵상 기록 | 중간 |
| 연속 읽기 | 연속 읽기 일수 추적 | 중간 |

#### 3.1.2 성경 66권 개요
| 기능 | 설명 | 우선순위 |
|------|------|----------|
| 책 목록 | 구약/신약 66권 리스트 | 높음 |
| 개요 영상 | 책별 개요 YouTube 영상 | 높음 |
| 책 정보 | 저자, 장 수, 요약 정보 | 중간 |
| 메모 | 책별 개인 메모 | 낮음 |
| 검색 | 성경책 검색 | 낮음 |

#### 3.1.3 데이터 관리
| 기능 | 설명 | 우선순위 |
|------|------|----------|
| CSV 자동 다운로드 | URL에서 자동 다운로드 | 높음 |
| CSV 수동 가져오기 | 파일 선택 후 가져오기 | 높음 |
| 데이터 초기화 | 읽기 기록 또는 전체 초기화 | 중간 |
| 로컬 Fallback | 다운로드 실패 시 로컬 사용 | 높음 |

#### 3.1.4 설정 및 사용자 경험
| 기능 | 설명 | 우선순위 |
|------|------|----------|
| 다크모드 | 라이트/다크/시스템 모드 | 중간 |
| 다국어 | 한국어/영어 자동 전환 | 중간 |
| 년도 선택 | 다년도 데이터 관리 | 중간 |
| 통계 | 완독률, 진행률 표시 | 낮음 |

### 3.2 윤년 처리

#### 3.2.1 윤년 판단 로직
```dart
bool isLeapYear(int year) {
  if (year % 400 == 0) return true;
  if (year % 100 == 0) return false;
  if (year % 4 == 0) return true;
  return false;
}
```

#### 3.2.2 2월 29일 처리
- **윤년 (2024, 2028 등)**: 찬양 영상 표시 (is_special = 1)
- **평년 (2025, 2026 등)**: 2월 28일 다음이 3월 1일
- **총 일수**: 윤년 366일, 평년 365일

### 3.3 사용자 시나리오

#### 시나리오 1: 첫 사용자
1. 앱 설치 및 실행
2. 설정 화면에서 CSV 자동 다운로드
3. 홈 화면에서 진행률 확인 (0%)
4. "오늘의 성경 읽기" 선택
5. 날짜 터치 → 영상 시청
6. 묵상 작성 및 완료 표시
7. 홈으로 돌아가 진행률 업데이트 확인

#### 시나리오 2: 일상 사용자
1. 앱 실행 (데이터 로드)
2. 홈 화면에서 진행률 확인
3. 오늘 날짜 선택 (자동)
4. YouTube 영상 시청
5. 묵상 노트 작성
6. 완료 표시
7. 격려 메시지 확인

#### 시나리오 3: 성경 공부
1. "성경 66권 개요" 선택
2. 관심 있는 책 선택
3. 개요 영상 시청
4. 메모 작성
5. 나중에 다시 확인

---

## 4. 데이터베이스 설계

### 4.1 ERD (Entity Relationship Diagram)

```
┌─────────────────────┐
│  bible_readings     │
├─────────────────────┤
│ id (PK)             │
│ month               │◄──────┐
│ day                 │       │
│ youtube_url         │       │  (month, day로 조회)
│ title               │       │
│ chapter_info        │       │
│ is_special          │       │
│ created_at          │       │
│ updated_at          │       │
└─────────────────────┘       │
                               │
┌─────────────────────┐       │
│  reading_history    │       │
├─────────────────────┤       │
│ id (PK)             │       │
│ year                │───────┘
│ month               │
│ day                 │
│ is_completed        │
│ completed_at        │
│ created_at          │
└─────────────────────┘
         │
         │ (year, month, day)
         ↓
┌─────────────────────┐
│  user_notes         │
├─────────────────────┤
│ id (PK)             │
│ year                │
│ month               │
│ day                 │
│ verse_reference     │
│ note_content        │
│ created_at          │
│ updated_at          │
└─────────────────────┘

┌─────────────────────┐
│  bible_books        │
├─────────────────────┤
│ id (PK)             │
│ book_number         │
│ testament           │
│ korean_name         │
│ english_name        │
│ youtube_url         │
│ author              │
│ chapters_count      │
│ summary             │
│ created_at          │
│ updated_at          │
└─────────────────────┘
         │
         │ (book_id FK)
         ↓
┌─────────────────────┐
│  book_notes         │
├─────────────────────┤
│ id (PK)             │
│ book_id (FK)        │
│ note_content        │
│ created_at          │
│ updated_at          │
└─────────────────────┘

┌─────────────────────┐
│  app_settings       │
├─────────────────────┤
│ key (PK)            │
│ value               │
│ updated_at          │
└─────────────────────┘
```

### 4.2 테이블 상세 설계

#### 4.2.1 bible_readings (성경 읽기 데이터)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | INTEGER | PRIMARY KEY AUTO INCREMENT | 고유 ID |
| month | INTEGER | NOT NULL | 월 (1-12) |
| day | INTEGER | NOT NULL | 일 (1-31) |
| youtube_url | TEXT | NOT NULL | YouTube URL |
| title | TEXT | NOT NULL | 제목 |
| chapter_info | TEXT | NULL | 상세 챕터 정보 |
| is_special | INTEGER | DEFAULT 0 | 윤년 찬양 여부 (0/1) |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 생성일 |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 수정일 |

**UNIQUE 제약**: (month, day)  
**INDEX**: idx_month_day ON (month, day)

**비즈니스 규칙**:
- 월-일만 저장 (연도 무관)
- 2월 29일은 is_special = 1로 설정
- CSV Import 시 REPLACE로 자동 UPSERT

#### 4.2.2 bible_books (성경 66권 정보)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | INTEGER | PRIMARY KEY AUTO INCREMENT | 고유 ID |
| book_number | INTEGER | NOT NULL UNIQUE | 책 번호 (1-66) |
| testament | TEXT | NOT NULL | 구약(OLD)/신약(NEW) |
| korean_name | TEXT | NOT NULL | 한글 이름 |
| english_name | TEXT | NULL | 영문 이름 |
| youtube_url | TEXT | NOT NULL | 개요 영상 URL |
| author | TEXT | NULL | 저자 |
| chapters_count | INTEGER | NOT NULL | 총 장 수 |
| summary | TEXT | NULL | 요약 |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 생성일 |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 수정일 |

**INDEX**: 
- idx_testament ON (testament)
- idx_book_number ON (book_number)

**비즈니스 규칙**:
- book_number는 1-66 범위
- testament는 'OLD' 또는 'NEW'만 허용

#### 4.2.3 reading_history (읽기 기록)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | INTEGER | PRIMARY KEY AUTO INCREMENT | 고유 ID |
| year | INTEGER | NOT NULL | 년도 |
| month | INTEGER | NOT NULL | 월 |
| day | INTEGER | NOT NULL | 일 |
| is_completed | INTEGER | DEFAULT 0 | 완료 여부 (0/1) |
| completed_at | TEXT | NULL | 완료 시각 |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 생성일 |

**UNIQUE 제약**: (year, month, day)  
**INDEX**: idx_year_month_day ON (year, month, day)

**비즈니스 규칙**:
- 년도별로 별도 관리
- 완료 시 completed_at 자동 기록

#### 4.2.4 user_notes (묵상 노트)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | INTEGER | PRIMARY KEY AUTO INCREMENT | 고유 ID |
| year | INTEGER | NOT NULL | 년도 |
| month | INTEGER | NOT NULL | 월 |
| day | INTEGER | NOT NULL | 일 |
| verse_reference | TEXT | NULL | 성경 구절 |
| note_content | TEXT | NOT NULL | 묵상 내용 |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 생성일 |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 수정일 |

**INDEX**: idx_year_month_day_note ON (year, month, day)

#### 4.2.5 book_notes (성경책 메모)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | INTEGER | PRIMARY KEY AUTO INCREMENT | 고유 ID |
| book_id | INTEGER | NOT NULL | 성경책 ID (FK) |
| note_content | TEXT | NOT NULL | 메모 내용 |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 생성일 |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 수정일 |

**UNIQUE 제약**: (book_id)  
**FOREIGN KEY**: book_id REFERENCES bible_books(id) ON DELETE CASCADE  
**INDEX**: idx_book_id ON (book_id)

#### 4.2.6 app_settings (앱 설정)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| key | TEXT | PRIMARY KEY | 설정 키 |
| value | TEXT | NULL | 설정 값 |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 수정일 |

**저장되는 설정**:
- target_year: 현재 선택된 년도
- theme_mode: 테마 설정 (light/dark/system)

### 4.3 데이터 관계

```
bible_readings (월-일 기준 템플릿)
       ↓ (조회)
reading_history (년-월-일 실제 기록)
       ↓ (1:N)
user_notes (년-월-일별 묵상)

bible_books (66권 정보)
       ↓ (1:1)
book_notes (책별 메모)
```

### 4.4 인덱스 전략

| 테이블 | 인덱스 | 목적 |
|--------|--------|------|
| bible_readings | (month, day) | 날짜별 빠른 조회 |
| bible_books | (testament) | 구약/신약 필터링 |
| bible_books | (book_number) | 책 번호로 조회 |
| reading_history | (year, month, day) | 날짜별 완료 여부 확인 |
| user_notes | (year, month, day) | 날짜별 노트 조회 |
| book_notes | (book_id) | 책별 노트 조회 |

---

## 5. 화면 설계

### 5.1 화면 구조도

```
HomeScreen (홈)
    ├─→ CalendarScreen (캘린더)
    │       └─→ ReadingDetailScreen (날짜 상세)
    ├─→ BibleBooksScreen (성경 66권)
    │       └─→ BookDetailScreen (책 상세)
    └─→ SettingsScreen (설정)
```

### 5.2 HomeScreen (홈 화면)

#### 5.2.1 레이아웃
```
┌─────────────────────────────────┐
│  [설정 아이콘]                  │ AppBar
├─────────────────────────────────┤
│                                 │
│  📅 2025년 성경 통독            │ 년도 뱃지
│                                 │
│  ┌───────────────────────────┐ │
│  │   📊 진행 현황            │ │
│  │                           │ │
│  │      ◯ 78.5%             │ │ 원형 프로그레스
│  │    245 / 365일           │ │
│  │                           │ │
│  │  ✅245  ⏳120  🔥7       │ │ 통계 카드
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │      🔥                   │ │ 격려 메시지
│  │  절반을 넘었어요!        │ │
│  │  계속 이어가세요!        │ │
│  └───────────────────────────┘ │
│                                 │
│  [오늘의 성경 읽기] 버튼       │ 액션 버튼
│  [성경 66권 개요] 버튼         │
│                                 │
└─────────────────────────────────┘
```

#### 5.2.2 주요 위젯
- **SliverAppBar**: 스크롤 시 축소되는 앱바
- **원형 프로그레스**: CircularProgressIndicator
- **통계 카드**: Wrap으로 반응형 배치
- **그라데이션 버튼**: LinearGradient + BoxShadow

#### 5.2.3 반응형 설계
| 화면 크기 | 원형 크기 | 폰트 크기 | 패딩 |
|-----------|-----------|-----------|------|
| < 360px | 160px | 작게 | 축소 |
| 360-400px | 180px | 중간 | 보통 |
| > 400px | 200px | 크게 | 넓게 |

### 5.3 CalendarScreen (캘린더 화면)

#### 5.3.1 레이아웃
```
┌─────────────────────────────────┐
│  [← 뒤로]  성경 읽기 캘린더     │ AppBar
├─────────────────────────────────┤
│  ┌───────────────────────────┐ │
│  │   ← 2025년 1월 →         │ │ 캘린더 헤더
│  │                           │ │
│  │  일 월 화 수 목 금 토    │ │
│  │        1✅ 2✅ 3✅ 4✅   │ │ 날짜 그리드
│  │  5✅ 6✅ 7⭕ 8  9  10 11│ │ (완료 표시)
│  │  ...                     │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │  ✅완료  ⭕오늘  ⬜미완료│ │ 범례
│  │  🎵찬양 (윤년만)         │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

#### 5.3.2 날짜 표시 규칙
- **완료**: 초록색 배경 + ✅ 아이콘
- **오늘**: 주황색 배경 + ⭕ 표시
- **미완료**: 기본 흰색 배경
- **윤년 찬양**: 보라색 + 🎵 아이콘

### 5.4 ReadingDetailScreen (날짜 상세 화면)

#### 5.4.1 레이아웃
```
┌─────────────────────────────────┐
│  [← 뒤로] 2025년 1월 8일        │ AppBar
├─────────────────────────────────┤
│  ┌───────────────────────────┐ │
│  │  📖                       │ │ 제목 카드
│  │  창세기 1-3장            │ │ (그라데이션)
│  └───────────────────────────┘ │
│                                 │
│  [▶ YouTube 영상 재생] 버튼    │ YouTube 버튼
│                                 │
│  ✍️ 나의 묵상 노트              │
│  ┌───────────────────────────┐ │
│  │ 성경 구절: [입력란]      │ │ 입력 필드
│  │                           │ │
│  │ 묵상 내용: [다중 입력]   │ │
│  │                           │ │
│  └───────────────────────────┘ │
│                                 │
│  [✅완료] [💾저장] 버튼        │ 액션 버튼
└─────────────────────────────────┘
```

#### 5.4.2 상태별 UI
- **영상 있음**: 제목 카드 + YouTube 버튼 표시
- **영상 없음**: 안내 메시지만 표시
- **완료됨**: 완료 버튼 초록색
- **미완료**: 완료 버튼 회색

### 5.5 BibleBooksScreen (성경 66권 화면)

#### 5.5.1 레이아웃
```
┌─────────────────────────────────┐
│  [← 뒤로]  성경 66권 개요       │ AppBar
├─────────────────────────────────┤
│  ┌───────────────────────────┐ │
│  │  🔍 검색...              │ │ 검색바
│  └───────────────────────────┘ │
│                                 │
│  🔵 구약성경 (39권)             │
│  ┌───────────────────────────┐ │
│  │ ①  📖 창세기    [50장]→ │ │ 리스트 아이템
│  │ ②  📖 출애굽기  [40장]→ │ │
│  │ ③  📖 레위기    [27장]→ │ │
│  └───────────────────────────┘ │
│                                 │
│  🔴 신약성경 (27권)             │
│  ┌───────────────────────────┐ │
│  │ 40 📖 마태복음  [28장]→ │ │
│  │ 41 📖 마가복음  [16장]→ │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

### 5.6 BookDetailScreen (책 상세 화면)

#### 5.6.1 레이아웃
```
┌─────────────────────────────────┐
│  [← 뒤로]  창세기               │ AppBar
├─────────────────────────────────┤
│         ①                       │ 책 번호 뱃지
│       창세기                     │
│  📖 구약성경 1권 / 50장         │ 기본 정보
│  ✍️ 저자: 모세                  │
│                                 │
│  [▶ 개요 영상 보기] 버튼       │ YouTube 버튼
│                                 │
│  📝 요약                        │
│  ┌───────────────────────────┐ │
│  │ 천지창조와 족장들의 역사  │ │ 요약 카드
│  │ ...                       │ │
│  └───────────────────────────┘ │
│                                 │
│  ✍️ 나의 메모                   │
│  ┌───────────────────────────┐ │
│  │ [메모 입력]              │ │ 입력 필드
│  └───────────────────────────┘ │
│                                 │
│  [💾 저장] 버튼                │
└─────────────────────────────────┘
```

### 5.7 SettingsScreen (설정 화면)

#### 5.7.1 레이아웃
```
┌─────────────────────────────────┐
│  [← 뒤로]  설정                 │ AppBar
├─────────────────────────────────┤
│  📥 데이터 업데이트             │
│  ├ 매일 읽기 URL (자동)        │
│  ├ 매일 읽기 URL (수동)        │
│  ├ 성경 개요 URL (자동)        │
│  └ 성경 개요 URL (수동)        │
│                                 │
│  🗑️ 데이터 초기화               │
│  ├ 읽기 기록 초기화            │
│  └ 모든 데이터 초기화          │
│                                 │
│  🎨 테마 설정                   │
│  └ 테마 모드: 시스템 기본값    │
│                                 │
│  🗓️ 년도 설정                   │
│  └ 현재 년도: 2025년           │
│                                 │
│  📊 통계                        │
│  └ 연간 완독률: 67.1%          │
│                                 │
│  ℹ️ 앱 정보                     │
│  ├ 버전: 1.0.0                 │
│  └ CSV 형식 안내               │
└─────────────────────────────────┘
```

### 5.8 UI/UX 가이드라인

#### 5.8.1 컬러 팔레트

**라이트 모드**:
- Primary: Blue (#42A5F5)
- Secondary: Green (#66BB6A)
- Accent: Orange (#FFA726)
- Background: White (#FFFFFF)
- Surface: Grey 50 (#FAFAFA)
- Text: Black (#000000)

**다크 모드**:
- Primary: Blue (#42A5F5)
- Secondary: Green (#66BB6A)
- Accent: Orange (#FFA726)
- Background: Grey 900 (#121212)
- Surface: Grey 800 (#1E1E1E)
- Text: White (#FFFFFF)

#### 5.8.2 타이포그래피

| 용도 | 크기 | 굵기 |
|------|------|------|
| 제목 (Large) | 24-28px | Bold |
| 제목 (Medium) | 20-22px | Bold |
| 본문 (Large) | 18px | Medium |
| 본문 (Regular) | 16px | Regular |
| 캡션 | 12-14px | Regular |

#### 5.8.3 간격 체계

| 간격 | 크기 |
|------|------|
| XS | 4px |
| S | 8px |
| M | 12px |
| L | 16px |
| XL | 20px |
| XXL | 24px |

#### 5.8.4 모서리 반경

| 요소 | 반경 |
|------|------|
| 버튼 | 16-20px |
| 카드 | 20-24px |
| 입력 필드 | 20px |
| 뱃지 | 30px (완전 둥글게) |

---

## 6. 기술 스택

### 6.1 프레임워크 및 언어

| 기술 | 버전 | 용도 |
|------|------|------|
| Flutter | ≥3.0.0 | 크로스 플랫폼 개발 |
| Dart | ≥3.0.0 | 프로그래밍 언어 |

### 6.2 주요 패키지

#### 6.2.1 상태 관리
```yaml
provider: ^6.1.1
```
- 목적: 전역 상태 관리
- 선택 이유: 간단하고 효율적, Flutter 공식 권장

#### 6.2.2 로컬 데이터베이스
```yaml
sqflite: ^2.3.0
path: ^1.8.3
path_provider: ^2.1.1
```
- 목적: SQLite 데이터베이스 사용
- 특징: 오프라인 우선, 빠른 성능

#### 6.2.3 YouTube 연동
```yaml
youtube_player_flutter: ^9.0.0
url_launcher: ^6.2.0
```
- 목적: YouTube 앱으로 영상 재생
- 방식: 외부 앱 실행 (LaunchMode.externalApplication)

#### 6.2.4 CSV 처리
```yaml
csv: ^6.0.0
file_picker: ^6.1.1
```
- 목적: CSV 파일 읽기 및 파싱
- 기능: 자동 인코딩 감지 (UTF-8, Latin-1 등)

#### 6.2.5 UI 컴포넌트
```yaml
table_calendar: ^3.0.9
intl: ^0.18.1
```
- table_calendar: 월별 캘린더 표시
- intl: 국제화 및 날짜 포맷

#### 6.2.6 네트워크
```yaml
http: ^1.1.0
```
- 목적: CSV 파일 다운로드
- URL: https://lamp.empluses.com/csv/

#### 6.2.7 다국어
```yaml
flutter_localizations: (SDK)
```
- 지원 언어: 한국어(ko), 영어(en)
- 방식: ARB 파일 기반

### 6.3 개발 도구

```yaml
dev_dependencies:
  flutter_test: (SDK)
  flutter_lints: ^3.0.0
```

---

## 7. 주요 알고리즘

### 7.1 윤년 판단 알고리즘

```dart
/// 윤년 여부 판단
/// 
/// 규칙:
/// 1. 400으로 나누어떨어지면 윤년
/// 2. 100으로 나누어떨어지면 평년
/// 3. 4로 나누어떨어지면 윤년
/// 4. 그 외는 평년
/// 
/// 시간 복잡도: O(1)
/// 공간 복잡도: O(1)
bool isLeapYear(int year) {
  if (year % 400 == 0) return true;
  if (year % 100 == 0) return false;
  if (year % 4 == 0) return true;
  return false;
}

/// 예시:
/// 2024 → true (4로 나누어떨어짐)
/// 2025 → false
/// 1900 → false (100으로 나누어떨어지지만 400으로는 안됨)
/// 2000 → true (400으로 나누어떨어짐)
```

### 7.2 진행률 계산 알고리즘

```dart
/// 연간 진행률 계산
/// 
/// 로직:
/// 1. 해당 년도의 총 일수 계산 (365 or 366)
/// 2. 완료된 날짜 카운트
/// 3. 백분율 계산
/// 
/// 시간 복잡도: O(n) - n은 읽기 기록 수
/// 공간 복잡도: O(1)
double getProgressPercentage(int year) {
  final total = getTotalDaysInYear(year); // 365 or 366
  final completed = getCompletedCount(year);
  return (completed / total) * 100;
}

int getTotalDaysInYear(int year) {
  return isLeapYear(year) ? 366 : 365;
}

int getCompletedCount(int year) {
  return history.values
      .where((h) => h.year == year && h.isCompleted)
      .length;
}
```

### 7.3 연속 읽기 일수 계산

```dart
/// 연속 읽기 일수 계산
/// 
/// 로직:
/// 1. 오늘부터 역순으로 확인
/// 2. 완료 표시가 끊기는 날까지 카운트
/// 3. 년도가 바뀌면 중단
/// 
/// 시간 복잡도: O(d) - d는 연속 일수
/// 공간 복잡도: O(1)
int getStreakDays(int year) {
  final today = DateTime.now();
  if (year != today.year) return 0;

  int streak = 0;
  DateTime current = today;

  while (true) {
    if (!isCompleted(current.year, current.month, current.day)) {
      break;
    }
    streak++;
    current = current.subtract(const Duration(days: 1));
    if (current.year != year) break;
  }

  return streak;
}
```

### 7.4 CSV 인코딩 자동 감지

```dart
/// CSV 파일 자동 인코딩 감지 및 읽기
/// 
/// 로직:
/// 1. UTF-8 시도
/// 2. Latin-1 시도
/// 3. 시스템 인코딩 시도
/// 4. BOM 자동 제거
/// 
/// 시간 복잡도: O(n*m) - n은 파일 크기, m은 인코딩 개수
/// 공간 복잡도: O(n)
Future<String?> _readCsvFile(File file) async {
  final encodings = [utf8, latin1, systemEncoding];

  for (var encoding in encodings) {
    try {
      final bytes = await file.readAsBytes();
      
      // BOM 제거 (UTF-8 BOM: EF BB BF)
      var startIndex = 0;
      if (bytes.length >= 3 && 
          bytes[0] == 0xEF && 
          bytes[1] == 0xBB && 
          bytes[2] == 0xBF) {
        startIndex = 3;
      }
      
      final content = encoding.decode(bytes.sublist(startIndex));
      
      if (content.isNotEmpty) {
        return content;
      }
    } catch (e) {
      continue;
    }
  }
  
  return null;
}
```

### 7.5 반응형 크기 계산

```dart
/// 화면 크기에 따른 반응형 크기 계산
/// 
/// 로직:
/// 1. MediaQuery로 화면 크기 확인
/// 2. 작은 화면 여부 판단 (< 360px)
/// 3. 비율 또는 고정값 적용
/// 
/// 시간 복잡도: O(1)
/// 공간 복잡도: O(1)
double calculateResponsiveSize(
  BuildContext context,
  double minSize,
  double ratio,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  final calculatedSize = screenWidth * ratio;
  return calculatedSize < minSize ? minSize : calculatedSize;
}

// 사용 예:
final circleSize = calculateResponsiveSize(context, 160.0, 0.45);
// 작은 화면: 160px 보장
// 큰 화면: 화면의 45% 사용
```

---

## 8. 보안 및 성능

### 8.1 보안 고려사항

#### 8.1.1 데이터 보안
| 항목 | 방법 | 비고 |
|------|------|------|
| 로컬 DB | SQLite 암호화 미사용 | 개인 묵상 데이터로 민감도 낮음 |
| 네트워크 | HTTPS 사용 | CSV 다운로드 시 |
| SQL Injection | Parameterized Query | whereArgs 사용 |

#### 8.1.2 입력 검증
```dart
// 날짜 유효성 검사
bool isValidDate(int year, int month, int day) {
  if (month < 1 || month > 12) return false;
  if (day < 1) return false;
  return day <= getDaysInMonth(year, month);
}

// CSV 데이터 검증
if (row.isEmpty || 
    row.every((cell) => cell.toString().trim().isEmpty)) {
  continue; // 빈 행 건너뛰기
}
```

### 8.2 성능 최적화

#### 8.2.1 데이터베이스 최적화

**인덱스 활용**:
```sql
CREATE INDEX idx_month_day ON bible_readings(month, day);
CREATE INDEX idx_year_month_day ON reading_history(year, month, day);
```

**트랜잭션 사용**:
```dart
await db.transaction((txn) async {
  for (var item in items) {
    await txn.insert('table', item);
  }
});
```
- 효과: 대량 삽입 시 100배 이상 속도 향상

**쿼리 최적화**:
```dart
// 나쁜 예
final all = await db.query('reading_history');
final filtered = all.where((r) => r.year == year);

// 좋은 예
final filtered = await db.query(
  'reading_history',
  where: 'year = ?',
  whereArgs: [year],
);
```

#### 8.2.2 UI 성능

**리스트 렌더링**:
```dart
ListView.builder(  // O(visible items)
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);
```

**Provider 스코프 최소화**:
```dart
// 특정 위젯만 리빌드
Consumer<SpecificProvider>(
  builder: (context, provider, child) => Widget(),
);
```

**이미지 캐싱**:
- 없음 (현재 아이콘만 사용)

#### 8.2.3 메모리 관리

**Controller Dispose**:
```dart
@override
void dispose() {
  _verseController.dispose();
  _noteController.dispose();
  super.dispose();
}
```

**AnimationController Dispose**:
```dart
@override
void dispose() {
  _animationController.dispose();
  super.dispose();
}
```

### 8.3 성능 목표

| 항목 | 목표 | 측정 방법 |
|------|------|-----------|
| 앱 시작 시간 | < 2초 | 첫 화면 표시까지 |
| 화면 전환 | < 300ms | Navigator.push 완료까지 |
| DB 쿼리 | < 50ms | 단일 쿼리 |
| CSV Import | < 5초 | 365개 항목 |
| 메모리 사용 | < 100MB | 일반 사용 시 |

---

## 9. 배포 전략

### 9.1 빌드 설정

#### 9.1.1 Android (build.gradle)
```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        applicationId "com.example.bible_reading_app"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

#### 9.1.2 iOS (Info.plist)
```xml
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

### 9.2 앱 스토어 배포

#### 9.2.1 Google Play Store

**요구사항**:
- 최소 SDK: 21 (Android 5.0)
- 타겟 SDK: 33 (Android 13)
- 64비트 지원: 필수
- 앱 번들(AAB): 권장

**스크린샷 크기**:
- 휴대폰: 1080x1920 (16:9)
- 7인치 태블릿: 1200x1920
- 10인치 태블릿: 1600x2560

**앱 설명** (예시):
```
📖 함께 성경 읽기 - 1년 365일 성경 통독 도우미

✨ 주요 기능:
• 매일 성경 읽기와 YouTube 영상 연동
• 개인 묵상 노트 작성
• 진행률 추적 및 격려 시스템
• 성경 66권 개요 영상
• 다크 모드 지원

🎯 완벽한 성경 통독을 위한 필수 앱!
```

#### 9.2.2 Apple App Store

**요구사항**:
- 최소 iOS: 12.0
- Swift 버전: 5.0+
- 앱 아이콘: 1024x1024

**프라이버시 정책**:
- 수집 데이터: 없음 (로컬 저장만)
- 추적: 없음
- 위치 정보: 사용 안 함

### 9.3 버전 관리 전략

#### 9.3.1 시맨틱 버저닝
```
MAJOR.MINOR.PATCH

1.0.0 - 초기 릴리스
1.1.0 - 새 기능 추가
1.1.1 - 버그 수정
2.0.0 - 주요 변경
```

#### 9.3.2 릴리스 체크리스트
- [ ] 모든 기능 테스트 완료
- [ ] 다국어 번역 확인
- [ ] 다크모드 동작 확인
- [ ] 다양한 화면 크기 테스트
- [ ] CSV 파일 준비
- [ ] 스크린샷 준비
- [ ] 앱 설명 작성
- [ ] 개인정보 처리방침 확인
- [ ] 버전 번호 업데이트

### 9.4 업데이트 계획

#### 9.4.1 Phase 2 (v1.1.0)
- 알림 기능 추가
- 데이터 백업/복원
- 통계 차트 개선
- 위젯 지원

#### 9.4.2 Phase 3 (v1.2.0)
- 클라우드 동기화
- 공유 기능
- 오디오 재생 지원
- 다중 년도 비교

---

## 10. 테스트 계획

### 10.1 단위 테스트 (Unit Tests)

#### 10.1.1 DateHelper 테스트
```dart
test('윤년 판단 - 2024년은 윤년', () {
  expect(DateHelper.isLeapYear(2024), true);
});

test('윤년 판단 - 2025년은 평년', () {
  expect(DateHelper.isLeapYear(2025), false);
});

test('총 일수 - 윤년은 366일', () {
  expect(DateHelper.getTotalDaysInYear(2024), 366);
});

test('총 일수 - 평년은 365일', () {
  expect(DateHelper.getTotalDaysInYear(2025), 365);
});
```

#### 10.1.2 Provider 테스트
```dart
test('진행률 계산 - 50% 완료', () {
  final provider = ReadingHistoryProvider();
  // ... 테스트 데이터 설정
  expect(provider.getProgressPercentage(2025), 50.0);
});
```

### 10.2 위젯 테스트 (Widget Tests)

```dart
testWidgets('홈 화면 렌더링 테스트', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  expect(find.text('함께 성경 읽기'), findsOneWidget);
  expect(find.text('오늘의 성경 읽기'), findsOneWidget);
});
```

### 10.3 통합 테스트 (Integration Tests)

```dart
testWidgets('CSV 가져오기 플로우', (WidgetTester tester) async {
  // 1. 설정 화면 이동
  // 2. CSV 가져오기 버튼 클릭
  // 3. 성공 메시지 확인
  // 4. 데이터 확인
});
```

### 10.4 수동 테스트 체크리스트

#### 10.4.1 기능 테스트
- [ ] CSV 자동 다운로드 (성공/실패)
- [ ] CSV 수동 가져오기
- [ ] 날짜별 완료 표시
- [ ] 묵상 노트 작성/저장
- [ ] 년도 변경
- [ ] 테마 변경
- [ ] 언어 변경
- [ ] 데이터 초기화

#### 10.4.2 UI 테스트
- [ ] iPhone SE (작은 화면)
- [ ] iPhone 14 Pro (중간 화면)
- [ ] iPhone 14 Pro Max (큰 화면)
- [ ] iPad (태블릿)
- [ ] Galaxy S23
- [ ] Pixel 7

#### 10.4.3 시나리오 테스트
- [ ] 신규 사용자 온보딩
- [ ] 일상 사용 (읽기 → 묵상 → 완료)
- [ ] 성경 공부 (66권 개요)
- [ ] 설정 변경
- [ ] 데이터 관리

---

## 11. 부록

### 11.1 CSV 파일 형식

#### 11.1.1 daily_readings.csv
```csv
month,day,youtube_url,title,chapter_info,is_special
1,1,https://youtu.be/xxxxx,신년 특별말씀,창세기 1-3장,0
1,2,https://youtu.be/yyyyy,2일차,창세기 4-7장,0
2,29,https://youtu.be/bbbbb,윤년 특별 찬양,찬양 모음,1
12,31,https://youtu.be/ccccc,365일차,요한계시록 19-22장,0
```

#### 11.1.2 bible_books.csv
```csv
book_number,testament,korean_name,english_name,youtube_url,author,chapters_count,summary
1,OLD,창세기,Genesis,https://youtu.be/gen,모세,50,천지창조와 족장들의 역사
40,NEW,마태복음,Matthew,https://youtu.be/mat,마태,28,예수님의 생애와 가르침
66,NEW,요한계시록,Revelation,https://youtu.be/rev,요한,22,종말과 새 하늘 새 땅
```

### 11.2 용어 정리

| 용어 | 설명 |
|------|------|
| 통독 | 성경 전체를 처음부터 끝까지 읽는 것 |
| 묵상 | 성경 구절을 깊이 생각하고 적용하는 것 |
| 윤년 | 2월이 29일까지 있는 해 (366일) |
| 평년 | 일반적인 해 (365일) |
| 구약 | 성경의 전반부 (39권) |
| 신약 | 성경의 후반부 (27권) |

### 11.3 참고 자료

- Flutter 공식 문서: https://flutter.dev
- Provider 패키지: https://pub.dev/packages/provider
- SQLite 문서: https://www.sqlite.org/docs.html
- Material Design: https://material.io

### 11.4 개발 환경

| 항목 | 사양 |
|------|------|
| Flutter SDK | ≥3.0.0 |
| Dart SDK | ≥3.0.0 |
| IDE | VS Code / Android Studio |
| 최소 Android | API 21 (5.0 Lollipop) |
| 최소 iOS | 12.0 |

---

## 12. 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|-----------|
| 1.0.0 | 2025-01-07 | 초기 설계 완료 |

---
