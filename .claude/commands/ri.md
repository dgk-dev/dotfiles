---
allowed-tools: [Read, Write, Edit, MultiEdit, Bash, Glob, Grep, TodoWrite, Task, WebSearch, WebFetch, AskUserQuestion, mcp__context7-mcp__resolve-library-id, mcp__context7-mcp__get-library-docs, mcp__sequential-thinking__sequentialthinking]
description: "Research-first workflow: 리서치 → 분석 → 구현/수정 → 검증 → 배포 (상황에 맞게 PHASE 자동 조절, --pr 플래그로 PR 워크플로우 전환)"
argument-hint: "feature description (예: 'user authentication' 또는 'dashboard UI component')"
---

## 🚩 플래그 옵션

| 플래그 | 설명 |
|--------|------|
| (없음) | **기본**: main 직접 푸시 |
| `--pr` | **Pull Request 워크플로우**: feature 브랜치 → PR 생성 → CI 대기 → 머지 |
| `--pr --auto` | **PR + Auto-merge**: PR 생성 → auto-merge 설정 → 바로 종료 (CI 대기 안 함) |
| `--skip N` | 특정 PHASE 스킵 (예: `--skip 2`) |

# /ri - Research & Implement

**📌 워크플로우**: 리서치 기반 구현 방법론

**철학**:
- **"리서치 없이 구현 없다"** - 모든 구현 전에 철저한 조사를 강제
- **사용자 방향과 의도 파악 우선** - 요청이 모호하거나 여러 해석이 가능할 때, 어떤 Phase에 있든 추측하지 말고 AskUserQuestion으로 명확히 확인. 최대한 질문을 많이해서 사용자의 방향과 의도를 디테일하게 정확히 일치시킨 후에 진행. 최소 컨텍스트 파악(Phase 1) 후 질문.
- **엔터프라이즈 레벨 품질** - 임시 방편·우회·타협 대신, 대기업이 택할 근본적이고 유지보수 가능한 궁극적 솔루션
- **작업량/시간 무관** - AI가 수행하므로 오래 걸리고 거대한 작업이라도 최종 품질만 고려
- **토큰 절약 금지** - 효율성 핑계로 정확성을 희생하지 않음 (구조 자체가 이미 최적화됨)
- **복수 옵션 제시** - 항상 최소 3가지 접근법 비교 후 최적안 추천
- **타협 금지** - 구현 난이도나 변경 범위를 이유로 차선책 선택 금지, 리스크 과도 시에만 예외

---

**🎨 UI/UX 가이드라인** (권장):

**원칙**: shadcn/ui 컴포넌트 + 테마 변수 최대 활용

1. **shadcn 컴포넌트 우선**
   - 새 UI 구현 전 shadcn/ui에 해당 컴포넌트가 있는지 먼저 확인
   - 없으면 `pnpm dlx shadcn@latest add [component]`로 설치 후 사용
   - shadcn에 없는 경우에만 커스텀 컴포넌트 제작 (테마 변수 활용하여 통일감 유지)

2. **테마 변수 사용 (하드코딩 금지)**
   ```tsx
   // ❌ 피할 것 - Tailwind 기본 색상 직접 사용
   <div className="bg-blue-500 text-white border-gray-300">

   // ✅ 권장 - 테마 변수 클래스 사용
   <div className="bg-primary text-primary-foreground border-border">
   ```

---

**사용법**: `/ri [feature-description]`

---

## 🚨 강제 실행 단계

### ✅ PHASE 1: 컨텍스트 파악 (MANDATORY)

**목적**: 프로젝트 컨텍스트 파악 및 리서치 타겟 식별

**탐색 방법**: Claude Code 내장 도구 자유 활용
- Glob으로 프로젝트 구조 파악 (예: `**/*.ts`, `src/**/*.tsx`)
- Grep으로 핵심 패턴 검색 (예: `export.*function`, `import.*from`)
- Read로 주요 설정 파일 확인 (package.json, tsconfig.json 등)
- 필요시 Explore subagent로 병렬 탐색 (대규모 코드베이스)

**필수 산출물**:
- 📦 기술 스택 및 라이브러리 버전
- 🏗️ 프로젝트 패턴 (App Router, 상태관리, API 통신, 스타일링 등)
- 🏷️ 네이밍 컨벤션 및 디렉토리 구조
- 🎯 리서치 타겟 (Context7 라이브러리, 웹 검색 키워드)

**완료 표시**: TodoWrite로 "PHASE 1 완료" 마크

---

### ✅ PHASE 2: 리서치 (MANDATORY)

**목적**: 공식 패턴 + 최신 엔터프라이즈급 업계 표준 + 최신 커뮤니티 모범사례 확보

**필수 워크플로우** (Context7):
1. `resolve-library-id`로 관련 라이브러리 식별
2. `get-library-docs`로 공식 문서 조회
- 자율 선택: 조회할 라이브러리 선택, topic 파라미터

**필수 조건**:
- **Context7 워크플로우**: 필수 실행
- **총 소스 조사**: 20개 이상 (Context7, WebSearch, WebFetch 자유 조합)

**리서치 전략**:
- Context7 + WebSearch + WebFetch로 공식 문서 + 최신 엔터프라이즈급 업계 표준 + 최신 커뮤니티 모범 사례 + 원본 소스 동시 수집
- 신뢰 가능 소스 우선 (공식 블로그, 프레임워크 문서, 개발자 커뮤니티 등)

**도구별 활용 가이드**:
- **Context7**: `topic` 파라미터로 필요한 섹션 요청 (예: topic="authentication")
- **WebSearch**: 최신 업계 동향 및 모범사례 검색 (예: "Next.js 15 auth patterns 2025")
- **WebFetch**: 상황에 맞게 활용
  - 공식 릴리즈 노트/변경로그 직접 확인
  - GitHub 이슈/PR/Discussion에서 실제 해결 사례 조회
  - Vercel, Next.js 등 공식 블로그 원문 접근
- AI 자율성: 도구 선택, topic, 쿼리 전략 모두 AI 판단

**필수 산출물**:
- 📚 **공식 권장 패턴**: 공식 문서 기반 베스트 프랙티스
- 🌐 **최신 엔터프라이즈급 업계 표준 패턴**: 커뮤니티 검증된 최신 모범사례 (2025 기준)
- ❌ **안티패턴**: 회피해야 할 접근법 및 주의사항
- 🎯 **사용자 명령 수행 정보**: 현재 작업에 필요한 모든 관련 정보

**완료 표시**: TodoWrite로 "PHASE 2 완료" 마크

---

### ✅ PHASE 3: 코드베이스 전체 분석 (MANDATORY)

**목적**: 구현 전 관련 코드를 **전부** 파악하여 일관성 있는 구현 보장

**⚠️ 핵심 원칙: 정확성 최우선**

코드를 일부분만 대충 훑어보는 것은 **절대 금지**. 관련 코드는 반드시 **전체를 읽어야** 한다. 일부만 보고 추측하면 기존 패턴과 충돌하거나 중복 구현이 발생한다.

**분석 방법**:
1. **관련 파일 전수 조사**: Glob으로 관련 파일을 **모두** 찾아낸다
2. **전체 코드 읽기**: 찾은 파일은 **전부 Read**로 완독한다 (일부만 읽기 금지)
3. **패턴 추출**: 읽은 코드에서 기존 패턴을 정확히 파악한다

**구체적 실행**:
- 새 기능과 관련된 기존 컴포넌트/함수/타입 **전체** 읽기
- 비슷한 기능이 이미 있는지 **전체 코드베이스** 확인
- import/export 관계, 의존성 **완전히** 파악
- 필요시 Explore subagent로 병렬 탐색 (대규모 코드베이스)

**왜 전체를 읽어야 하는가**:
- 일부만 보면 기존 유틸/헬퍼 함수를 못 찾고 중복 구현함
- 네이밍 컨벤션, 에러 처리 패턴 등을 놓침
- 기존 코드와 스타일이 불일치하는 코드를 작성함

**필수 산출물**:
- 📂 프로젝트 구조 맵
- 🏗️ 기존 아키텍처 패턴 (실제 코드 기반, 추측 아님)
- 🔗 통합 지점 (새 기능 삽입 위치)
- 📝 읽은 파일 목록 (전체 코드 파악 증빙)
- ✔️ PHASE 2 검증 결과 (리서치 패턴 vs 프로젝트 구현)

**완료 표시**: TodoWrite로 "PHASE 3 완료" 마크

---

### ✅ PHASE 4: 구현 계획 및 최적 솔루션 선정

1. **PHASE 1, 2, 3 완료 확인** (미완료 시 구현 불가)

2. **Sequential Thinking MCP로 종합 분석**:
   - Context7 공식 가이드라인
   - 웹 최신모범사례 vs 안티패턴
   - 프로젝트 패턴 vs 통합 지점
   - 리스크 및 대안 평가

3. **AI 코딩 핵심 체크**:
   - **중복 제거 (SSOT)**: 같은 로직/상수 중복 여부
   - **보안 검증**: 민감 정보 노출, 입력 검증 누락
   - **컨텍스트 일관성**: 프로젝트 패턴 준수

4. **최소 3가지 구현 옵션 도출** (필수):
   - ⚠️ 모든 옵션은 엔터프라이즈 레벨 품질 기준 충족 필수 (임시 방편/우회 방법 제외)
   - 각 옵션마다 반드시 포함:
     - **개요**: 접근 방식 한 줄 요약
     - **변경 영역**: 수정할 컴포넌트/모듈/레이어 명시 (파일명 아닌 영역 수준)
     - **기술적 Trade-off**: 성능 vs 복잡도, 유연성 vs 학습비용 등
     - **리스크/주의사항**: 선택 시 주의할 점
     - **유지보수/확장성**: 장기적 관점에서의 영향
     - **사용자 영향**: 최종 결과물/UX 차이
     - **향후 변경 시**: 기능 추가/수정 시 영향
     - **권장 상황**: 어떤 경우에 이 옵션이 적합한지

5. **최적 솔루션 추천 + 객관적 비교**:
   - 평가 기준 명시: SSOT, 확장성, 유지보수성, 공식 권장사항, 업계 표준 등
   - 각 옵션을 기준별로 비교한 후 최적안 도출 (주관적 추천 아닌 객관적 비교)
   - ⚠️ **중요**: 작업량은 평가 대상 아님 (AI가 수행하므로 최종 품질만 고려)
   - ⚠️ **선정 원칙**: 리스크가 과도하지 않은 한, 항상 가장 근본적이고 완전한 솔루션 선택 (중간 타협안/절충안 지양)

6. **구현 계획 상세화** (필수):
   - 단순 체크리스트가 아닌 **변경 영역별 상세 설명**
   - 각 단계마다: 무엇을, 왜, 어떤 순서로 변경하는지 명시
   - 필요 시 10개 이상 항목도 OK (상세함 우선)

7. TodoWrite로 "옵션 A/B/C 도출, 최적 솔루션: [X]" 마크

⏸️ **승인 대기** (PHASE 5 진행 전 필수)
- 옵션 비교표 + 최적 솔루션 제시
- 선택지: **"1) 추천안 진행 / 2) 다른 옵션 선택 / 3) 수정 요청 / 4) 추가 탐색"**

✅ **승인 후 실행 흐름**:
- 사용자 승인 시 → PHASE 5 (구현 및 검증) 진행
- PHASE 5 완료 후 사용자에게 다음 단계 선택 요청

**필수 산출물**: 옵션 비교, 최적안 추천, 구체적 근거, 단계별 계획, 리스크 대응

---

### ✅ PHASE 5: 구현 및 검증

1. 승인된 계획에 따라 단계별 구현
2. 각 단계마다 TodoWrite 업데이트
3. PHASE 2, 3, 4 결과 준수 확인:
   - 공식 가이드라인 적용
   - 최신 엔터프라이즈급 모범사례 반영
   - 프로젝트 패턴 일관성
   - AI 핵심 체크 통과

4. 구현 완료 후 자동 품질 검증:

   #### 🔍 2개 병렬 검증

   **TypeCheck + Lint 병렬 실행** (단일 응답에서 2개 Bash 동시 호출)

   - 모든 검증 통과 → 사용자 선택 대기
   - 실패 시 → 자동 수정 후 재검증

---

⏸️ **PHASE 5 완료 후 사용자 선택** (AskUserQuestion)

검증 통과 후 사용자에게 다음 단계 선택 요청:
- **1) Cleanup → Build → Deploy 진행** 
- **2) Cleanup → Build만 실행** (배포 없음)
- **3) 추가 작업 (직접 입력)** → 사용자가 원하는 추가 작업 내용 입력 후 진행

---

### 🚀 PHASE 6: Build & Deploy

**실행 조건**: 사용자가 "1) Build + Deploy" 또는 "2) Build만" 선택 시

#### 🧹 STEP 1: Code Cleanup

**목적**: Build 전 최종 정리 - AI가 이번 세션에서 발생한 모든 정리 필요 사항을 자율 판단하여 처리

**정리 대상** (AI 자율 판단):
- 미사용 import/변수/함수 제거
- 임시 주석 및 디버그 코드 제거
- 불필요한 console.log 제거
- 세션 중 남겨둔 TODO 처리
- `pnpm lint --fix` 실행

---

#### 📦 STEP 2: Build

```bash
pnpm build
```

- 빌드 성공 → Deploy 진행 (옵션 1 선택 시) 또는 종료 (옵션 2 선택 시)
- 빌드 실패 → 자동 수정 후 재시도

---

#### 🚢 STEP 3: Deploy (옵션 1 선택 시만)

**조건**: Git 환경 확인 후 실행 (`.git` 없으면 스킵)

**커밋 형식**: Conventional Commits (`[prefix]([scope]): [설명]`)
```
feat(auth): Add Google OAuth login

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**워크플로우 분기**:
- **기본 (플래그 없음)**: `git commit` → `git push origin main`
- **`--pr`**: feature 브랜치 → `gh pr create` → CI 대기 (`gh pr checks --watch`) → 머지
- **`--pr --auto`**: feature 브랜치 → PR 생성 → auto-merge 설정 후 바로 종료

---

## 🎉 완료 시 출력

배포 정보 (커밋/PR/머지), 주요 변경사항, 검증 결과

---

## 🛡️ 체크포인트

- PHASE 1, 2, 3: **MANDATORY** (미완료 시 구현 불가)
- PHASE 4: 사용자 승인 필수 → 승인 후 PHASE 5 실행
- PHASE 5 완료: 사용자 선택 필수 (Build+Deploy / Build만 / 추가작업 직접 입력)
- 각 PHASE 완료 시 TodoWrite 필수
- `--skip N`: 해당 PHASE 스킵

---

## ⚠️ 멀티 세션 충돌 방지

**상황**: 여러 Claude 세션이 동시에 같은 프로젝트 작업 시

### Build 충돌 방지
- Build 전 `git status`로 다른 세션의 변경사항 확인
- 예상치 못한 변경 파일 발견 시 → **빌드 중단**, 사용자에게 보고
- **절대 금지**: 다른 세션이 수정 중인 파일 덮어쓰기

### Git 충돌 방지
- **커밋 범위**: 이번 세션에서 **직접 수정한 파일만** 커밋
- `git add .` 금지 → 개별 파일 명시적 add (`git add file1 file2`)
- 커밋 전 `git diff --cached`로 스테이징 내용 재확인
- 예상 외 파일 스테이징 발견 시 → **커밋 중단**, 사용자에게 확인

### 실행 규칙
```bash
# ✅ 올바른 방법
git add src/components/Button.tsx src/hooks/useAuth.ts
git commit -m "feat(auth): ..."

# ❌ 금지
git add .
git add -A
```

---

**버전**: 12.2.0

**백업**: 수정 후 dotfiles repo 커밋+푸시 필수
```bash
/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME add ~/.claude/commands/ri.md
/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME commit -m "chore(claude): update ri.md"
/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME push origin main
```
