---
allowed-tools: [Read, Write, Edit, MultiEdit, Bash, Glob, Grep, TodoWrite, Task, WebSearch, WebFetch, AskUserQuestion, mcp__context7-mcp__resolve-library-id, mcp__context7-mcp__get-library-docs, mcp__sequential-thinking__sequentialthinking, mcp__memory-bank__memory_bank_read, mcp__memory-bank__memory_bank_write, mcp__memory-bank__memory_bank_update, mcp__memory-bank__list_projects, mcp__memory-bank__list_project_files]
description: "Research-first workflow: 리서치 → 분석 → 구현/수정 → 검증 → 배포 (상황에 맞게 PHASE 자동 조절, --pr 플래그로 PR 워크플로우 전환)"
argument-hint: "feature description (예: 'user authentication' 또는 'dashboard UI component')"
---

## 🚩 플래그 옵션

| 플래그 | 설명 |
|--------|------|
| (없음) | **기본**: main 직접 푸시 |
| `--pr` | **Pull Request 워크플로우**: feature 브랜치 → PR 생성 → CI 대기 → 머지 |
| `--pr --auto` | **PR + Auto-merge**: PR 생성 → auto-merge 설정 → 바로 종료 (CI 대기 안 함) |
| `--sp N` | 특정 PHASE 스킵 (예: `--sp 2`) |

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

### 💾 PHASE 2: Memory Bank 이전 학습 조회 (조건부)

**실행 조건**: 유사 작업 존재, 반복 패턴, 이전 실패 회피 필요

**목적**: 검증된 접근법 재사용, 안티패턴 회피

**조회 전략**:
- **Collections 기반**: 관련 프로젝트/프레임워크 collection 식별
- **Tags 기반**: 기술스택, 패턴 유형으로 검색
- **Importance 기반**: 높은 점수 우선 조회
- 성공 패턴 (success tag) 재사용, 실패 패턴 (failure tag) 회피

**산출물**: 재사용 가능 패턴, 안티패턴, 검증된 접근법

---

### ✅ PHASE 3: 리서치 (MANDATORY)

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

**완료 표시**: TodoWrite로 "PHASE 3 완료" 마크

---

### ✅ PHASE 4: 코드베이스 전체 분석 (MANDATORY)

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
- ✔️ PHASE 3 검증 결과 (리서치 패턴 vs 프로젝트 구현)

**완료 표시**: TodoWrite로 "PHASE 4 완료" 마크

---

### ✅ PHASE 5: 구현 계획 및 최적 솔루션 선정

1. **PHASE 1, 3, 4 완료 확인** (미완료 시 구현 불가)

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
   - **번호 리스트 형식 사용** (터미널에서 테이블이 깨지므로 테이블 금지)
   - 각 옵션마다 반드시 포함:
     - **개요**: 접근 방식 한 줄 요약
     - **변경 영역**: 수정할 컴포넌트/모듈/레이어 명시 (파일명 아닌 영역 수준)
     - **기술적 Trade-off**: 성능 vs 복잡도, 유연성 vs 학습비용 등
     - **리스크/주의사항**: 선택 시 주의할 점
     - **유지보수/확장성**: 장기적 관점에서의 영향

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

⏸️ **승인 대기** (PHASE 6 진행 전 필수)
- 옵션 비교표 + 최적 솔루션 제시
- 선택지: **"1) 추천안 진행 / 2) 다른 옵션 선택 / 3) 수정 요청 / 4) 추가 탐색"**

✅ **승인 후 자동 실행 흐름**:
- 사용자 승인 시 → PHASE 6 (구현) → PHASE 7 (회고 + 배포) 자동 연속 실행
- 중간 사용자 개입 없이 main 푸시까지 완료

**필수 산출물**: 옵션 비교, 최적안 추천, 구체적 근거, 단계별 계획, 리스크 대응

---

### ✅ PHASE 6: 구현 및 검증

1. 승인된 계획에 따라 단계별 구현
2. 각 단계마다 TodoWrite 업데이트
3. PHASE 3, 4, 5 결과 준수 확인:
   - 공식 가이드라인 적용
   - 최신 엔터프라이즈급 모범사례 반영
   - 프로젝트 패턴 일관성
   - AI 핵심 체크 통과

4. 구현 완료 후 자동 품질 검증:

   #### 📦 STEP 1: Code Cleanup

   **목적**: AI 코딩으로 발생할 수 있는 미사용 코드 정리

   ```bash
   pnpm lint --fix  # 또는 프로젝트 lint 도구의 자동 수정 명령
   ```

   **정리 대상**: 미사용 import, 미사용 변수, 포맷팅

   ---

   #### 🔍 STEP 2: 3개 병렬 Sub-Agent로 검증 실행

   다음 검증 작업을 **3개 병렬 Task**로 수행하세요:

   **Task 1 - TypeCheck Agent**:
   ```
   변경된 파일: [구현된 파일 목록]
   프로젝트 루트: [프로젝트 경로]

   작업:
   1. pnpm tsc --noEmit 또는 npm run type-check 실행
   2. 타입 에러 있으면: 전체 에러 목록 반환
   3. 타입 에러 없으면: "✅ TypeScript 타입 체크 통과" 반환

   허용 도구: Bash, Read, Grep
   ```

   **Task 2 - Lint Agent**:
   ```
   변경된 파일: [구현된 파일 목록]
   프로젝트 루트: [프로젝트 경로]

   작업:
   1. pnpm lint 또는 npm run lint 실행
   2. Lint 에러/경고 있으면: 전체 에러 목록 반환
   3. Lint 에러 없으면: "✅ ESLint 코드 품질 통과" 반환

   허용 도구: Bash, Read, Grep
   ```

   **Task 3 - Build Agent**:
   ```
   프로젝트 루트: [프로젝트 경로]

   작업:
   1. pnpm build 또는 npm run build 실행
   2. 빌드 에러 있으면: 전체 에러 목록 반환
   3. 빌드 성공 시: "✅ 프로덕션 빌드 성공" 반환

   허용 도구: Bash, Read, Grep
   ```

   ---

   **검증 결과 통합**:
   - 모든 Sub-Agent 완료 대기
   - 모든 검증 통과 시: PHASE 7 병렬 실행으로 자동 진행
   - **하나라도 실패 시: 자동 수정 후 재검증**:
     1. 에러 분석 후 자동 수정 시도
     2. 수정 완료 후 3개 검증 Agent 재실행

**최종 체크**:
- [ ] **타입 체크 통과**: TypeScript 에러 없음 확인
- [ ] **린트 통과**: ESLint 에러/경고 해결
- [ ] **빌드 성공**: 프로덕션 빌드 에러 없음 확인

⚡ **PHASE 6 완료 후 즉시 PHASE 7 병렬 실행** (사용자 개입 없음)

---

### 📚🚀 PHASE 7: Retrospective & Deploy (PARALLEL AUTO-EXECUTE)

**자동 실행**: PHASE 6 검증 통과 즉시 (사용자 개입 없음)

**2개 병렬 Sub-Agent로 동시 실행**:

---

#### **Task 1 - Retrospective Agent**

**목적**: 구현 학습 저장 및 세션 간 지식 축적

**입력 컨텍스트**:
```
구현 정보:
- 선택된 옵션: [PHASE 5에서 선택한 옵션]
- 변경된 파일: [파일 목록]
- 핵심 기능: [구현 요약]
- 검증 결과: TypeCheck ✅, Lint ✅, Build ✅

프로젝트 기술 스택:
- Framework: [프레임워크 정보]
- 주요 라이브러리: [라이브러리 목록]
```

**실행 내용**:

1. **구현 결과 평가**:
   - 예상 vs 실제 결과 비교
   - PHASE 5 선택 옵션 검증
   - 예상치 못한 발견사항

2. **패턴 추출**:
   - 성공 패턴 (재사용 가능한 접근법)
   - 안티패턴 (회피해야 할 방법)
   - 프레임워크별 인사이트

3. **Memory Bank 저장**:
   - **Collections**: 프로젝트별/프레임워크별 (예: "nextjs-auth", "react-patterns")
   - **Tags**: 기술스택, 패턴 유형, 성공/실패 (예: ["next.js", "authentication", "success"])
   - **Importance**: 재사용 가능성 점수 0.0-1.0
     - 범용 패턴: 0.8-1.0
     - 프로젝트 특화: 0.5-0.7
     - 일회성: 0.3-0.4
   - **Metadata**: `{"framework": "next.js@15", "pattern": "auth", "status": "success"}`
   - 핵심 태그 3-5개만 (과도한 태그는 검색 노이즈)

**허용 도구**: Read, Glob, Grep, mcp__memory-bank__*

**산출물**: 회고 보고서, Memory Bank 업데이트 확인

**효과**: 반복 작업 -50%, 구현 속도 +30%, 의사결정 오류 감소

---

#### **Task 2 - Deploy Agent**

**자동 실행 조건**:
- PHASE 6 검증 통과 시 자동 실행
- Git 환경 아닌 경우만 자동 스킵

**입력 컨텍스트**:
```
구현 정보:
- 기능명: [기능 이름]
- 선택된 옵션: [PHASE 5 옵션]
- 변경된 파일: [파일 목록]
- 검증 결과: TypeCheck ✅, Lint ✅, Build ✅
- 플래그: [--pr 여부]
```

**실행 내용**:

1. **Git 환경 확인**:
   - `.git` 폴더 존재 여부 확인
   - 환경 확인 실패 시 → 스킵 사유 안내 후 종료

---

##### 🔀 **`--pr` 플래그 사용 시: PR 기반 워크플로우**

0. **브랜치 상태 확인 및 분기** (필수):
   ```bash
   git status   # 현재 브랜치 확인
   gh pr view   # 현재 브랜치에 열린 PR 있는지 확인
   ```

   **분기 로직**:
   - **Case A**: 이미 feature 브랜치에 있고 + 열린 PR 있음
     → Step 1 (브랜치 생성) **스킵**
     → Step 2 (커밋) 실행
     → Step 3 (PR 생성) **스킵** - `git push`만 실행
     → Step 4 (CI 대기 + 머지) 실행 - 기존 PR 번호 사용

   - **Case B**: main에 있거나 + PR 없는 브랜치
     → 전체 Step 1-4 순차 실행
     ```bash
     git checkout main && git pull
     git checkout -b [새 브랜치]
     ```

1. **브랜치 생성** (Case B만, Conventional Commits prefix 사용):
   ```bash
   git checkout -b [prefix]/[scope]-[description]
   # 예: feat/auth-google-oauth, fix/chat-order, chore/ci-setup
   ```

2. **변경사항 커밋** (Conventional Commits 형식):
   ```bash
   git add -A
   git commit -m "$(cat <<'EOF'
   [prefix]([scope]): [간단한 설명]

   [상세 설명 (선택)]

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```
   - prefix: 브랜치 prefix와 동일하게 (feat, fix, chore 등)
   - scope: 변경 영역 (auth, chat, ui 등)
   - 설명: 명령형 현재시제 ("Add..." not "Added...")

3. **브랜치 푸시 및 PR 생성**:

   **Case A (기존 PR 있음)**: 푸시만 실행
   ```bash
   git push   # 기존 PR에 커밋 추가됨
   ```

   **Case B (새 PR 필요)**: 푸시 + PR 생성
   ```bash
   git push -u origin [branch-name]

   gh pr create --title "[prefix]([scope]): [설명]" --body "$(cat <<'EOF'
   ## Summary
   - [변경 내용 요약]

   ## Changes
   - [변경된 파일/기능 목록]

   ## Test Plan
   - [ ] TypeScript 타입 체크 통과
   - [ ] ESLint 통과
   - [ ] 프로덕션 빌드 성공
   - [ ] CI 통과 확인

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   EOF
   )"
   ```

4. **CI 및 머지 처리**:

   **`--pr` (기본 - 블로킹)**: CI 끝날 때까지 대기 후 머지
   ```bash
   gh pr checks [PR번호] --watch              # CI 완료까지 대기 (2-3분)
   gh pr merge [PR번호] --squash --delete-branch  # 머지 실행
   ```

   **`--pr --auto` (논블로킹)**: auto-merge 설정하고 바로 종료
   ```bash
   gh pr merge [PR번호] --squash --auto --delete-branch
   # 바로 리턴, GitHub이 CI 통과 후 자동 머지
   ```

   옵션 설명:
   - `--squash`: 여러 커밋을 1개로 합쳐서 깔끔한 히스토리 유지
   - `--delete-branch`: 머지 후 feature 브랜치 자동 삭제
   - `--auto`: GitHub에 auto-merge 설정 (CI 통과 시 자동 머지)

5. **PR URL 및 머지 결과 출력**

**산출물**: 브랜치명, 커밋 해시, PR URL, 머지 완료 확인

---

##### 🚀 **기본 워크플로우 (--pr 미사용): main 직접 푸시**

1. **현재 브랜치 확인**:
   - 현재 브랜치가 main인지 확인
   - main이 아니면 checkout

2. **변경사항 커밋**:
   ```bash
   git add -A
   git commit -m "$(cat <<'EOF'
   [prefix]([scope]): [간단한 설명]

   [상세 설명 (선택)]

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```
   - prefix: feat, fix, refactor, docs, chore 등
   - scope: 변경 영역 (예: voice, auth, ui)

3. **main 직접 푸시**:
   ```bash
   git push origin main
   ```

**산출물**: 커밋 해시, 푸시 결과

---

**허용 도구**: Bash, Read, Grep

**자동 스킵 조건**:
- Git 저장소가 아닌 환경 (`.git` 폴더 없음)
- 커밋할 변경사항이 없는 경우

---

**병렬 실행 완료 후 통합**:
- Retrospective Agent 결과 + Deploy Agent 결과 통합
- 사용자에게 커밋 정보 및 학습 내용 제공

**효과**:
- **즉시 배포**: main 푸시 → Vercel 자동 배포
- **브랜치 충돌 없음**: 여러 AI 세션이 동시에 작업해도 안전
- **회고록이 Memory Bank에 저장됨** (세션 간 지식 축적)
- **병렬 실행으로 시간 절약** (약 40% 단축)

---

## 🎉 전체 완료 요약

**PHASE 7 완료 후 반드시 제공**:

### 📌 배포 정보

**`--pr` 플래그 사용 시**:
- **브랜치**: [feature-branch-name]
- **커밋**: [커밋 해시] - [커밋 메시지]
- **PR**: [PR URL]
- **CI 상태**: ✅ 통과
- **머지**: ✅ 스쿼시 머지 완료 → Vercel 자동 배포 트리거됨

**`--pr --auto` 플래그 사용 시**:
- **브랜치**: [feature-branch-name]
- **커밋**: [커밋 해시] - [커밋 메시지]
- **PR**: [PR URL]
- **Auto-merge**: ✅ 설정됨 (CI 통과 시 GitHub이 자동 머지)
- **다음 단계**: GitHub에서 PR 상태 확인

**기본 워크플로우 (main 직접 푸시)**:
- **커밋**: [커밋 해시] - [커밋 메시지]
- **브랜치**: main
- **배포 상태**: ✅ Vercel 자동 배포 트리거됨

### ✅ 주요 변경사항
- **선택된 옵션**: PHASE 5에서 선택한 옵션 (예: 옵션 B)
- **변경된 파일**: [파일 목록]
- **핵심 구현 내용**: [간략 요약]

### 🧪 검증 결과
- **TypeScript 타입 체크**: ✅ 통과
- **ESLint 코드 품질**: ✅ 통과
- **프로덕션 빌드**: ✅ 성공

### 📚 학습 내용
- **Memory Bank 저장 완료**: [저장된 패턴/인사이트]
- **다음 유사 작업 시 참고사항**: [...]

---

## 🛡️안전장치

**체크포인트**:
- PHASE 1: 항상 실행 (MANDATORY)
- PHASE 2: 유사 작업 존재 시 Memory Bank 조회 (조건부)
- PHASE 3, 4: 미완료 시 구현 불가 (MANDATORY)
- PHASE 5: 옵션 비교 없이 PHASE 6 진입 불가 (MANDATORY) → **사용자 승인 필요**
- PHASE 6 → 7: **승인 후 자동 병렬 실행** (사용자 개입 없음)
  - PHASE 6: 구현 및 검증 (MANDATORY)
    - **STEP 1**: Code Cleanup - 미사용 변수/import 정리
    - **STEP 2 검증 병렬화**: TypeCheck + Lint + Build (3개 Sub-Agent 병렬 실행)
    - 하나라도 실패 시 워크플로우 중단
  - PHASE 7: **병렬 자동 실행** (2개 Sub-Agent 동시 실행)
    - Retrospective Agent: Memory Bank 저장
    - Deploy Agent: main 직접 커밋 + 푸시 (Git 환경 아니면 자동 스킵)
- 각 PHASE 완료 시 TodoWrite 필수
- `--pr` 사용 시: feature 브랜치 → PR 생성 → CI 대기 → 머지
- `--pr --auto` 사용 시: feature 브랜치 → PR 생성 → auto-merge 설정 후 바로 종료
- `--sp N` 명시적 요청 시 해당 단계 스킵 가능

## 핵심 원칙

**워크플로우 필수 요소**:
1. **리서치 우선**: PHASE 3, 4 완료 없이 구현 금지
2. **옵션 비교**: PHASE 5에서 최소 2개 접근법 제시 후 최적안 선정
3. **학습 저장**: PHASE 7로 Memory Bank에 성공/실패 패턴 축적

**자율성 보장**:
- 도구 선택 자유 (Glob, Grep, Read, Explore subagent 등 상황에 맞게)
- 파일 탐색 전략 (검색 키워드, 우선순위)
- 상세 실행 방법 (단, 필수 산출물은 충족)

**절대 금지 사항**:
- 토큰 절약을 이유로 코드를 일부만 읽거나 리서치를 생략
- 빠른 구현을 위해 임시 방편/우회 방법 선택 (반드시 공식 패턴 + 최신 기업급 표준인 궁극적인 솔루션 선택)
- 작업량이 많다는 이유로 품질 타협
- 검증되지 않은 최신 기술만 추구 (공식 + 검증된 것만)

---

## 📊 커뮤니케이션 가이드

**각 PHASE 완료 시 포함 요소**:
- ✅ 완료 여부 및 조건부 실행 사유
- 🎯 핵심 발견사항
- 🔗 다음 PHASE로 전달할 정보

**PHASE 5 옵션 제시 형식**:
- 모든 옵션을 상세히 설명
- 각 옵션: 개요 + 변경 영역 + Trade-off + 리스크 + 유지보수성
- 객관적 비교 후 최적안 도출 (평가 기준 명시)
- 구현 계획: 변경 영역별 상세 설명, 항목 수 제한 없음
- 승인 대기: "1) 추천안 진행 / 2) 다른 옵션 / 3) 수정 요청 / 4) 추가 탐색"

**스타일 원칙**:
- 구조화된 간결함 우선, 불필요한 장황함 배제

---

**버전**: 11.4.3

**백업**: 수정 후 dotfiles repo 커밋+푸시 필수
```bash
/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME add ~/.claude/commands/ri.md
/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME commit -m "chore(claude): update ri.md"
/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME push origin main
```
