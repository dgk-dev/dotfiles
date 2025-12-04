---
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, TodoWrite, AskUserQuestion, mcp__sequential-thinking__sequentialthinking]
description: "프로젝트 시작 워크플로우: MVP 정의 → 뼈대 구축 → 살 붙이기 (CLAUDE.md + progress.md 기반)"
argument-hint: "프로젝트 이름 (선택사항, 예: 'task-manager')"
---

# /project-start - AI 코딩 프로젝트 시작 워크플로우

**📌 목적**:
- **대상**: Solo + 팀 프로젝트 모두
- **전용 기술 스택**: Next.js 15 (App Router) + TypeScript + Drizzle ORM + Better Auth
- **철학**: Minimum Viable Documentation + 점진적 개발 (MVP → Features)

**철학**:
- **"문서는 짧게, 코드는 확실하게"** - CLAUDE.md (500단어)로 PRD 대체
- **"한 세션 = 하나의 목표"** - 토큰 절약 및 세션 복원 용이
- **"뼈대 먼저, 살은 나중에"** - 배포 가능한 MVP 우선, 기능은 점진적 추가

**사용법**:
```bash
# 새 프로젝트 디렉토리에서 실행
/project-start [프로젝트-이름]

# 예시
/project-start task-manager
```

---

## 🚨 강제 실행 단계

### ✅ PHASE 0: 프로젝트 정보 수집 (MANDATORY)

**Interactive 질문을 통해 정보 수집**:

AI가 다음 정보를 대화형으로 질문합니다:

1. **프로젝트 이름**: [예: "task-manager", "blog-platform"]
2. **프로젝트 목적 (1문장)**: [예: "팀 협업용 작업 관리 도구"]
3. **핵심 문제**: [예: "현재 작업 진행상황을 한눈에 파악하기 어려움"]
4. **Must-have 기능 3개**:
   - 기능 1: [예: "사용자 인증 및 권한 관리"]
   - 기능 2: [예: "작업 생성/수정/삭제"]
   - 기능 3: [예: "작업 상태 대시보드"]

**필수 산출물**:
- 📝 프로젝트 컨텍스트 정의
- 🎯 MVP 범위 명확화
- 🏗️ 기본 아키텍처 방향 설정

**완료 표시**: TodoWrite로 "PHASE 0 완료" 마크

---

### ✅ PHASE 1: 핵심 문서 생성 (MANDATORY)

**목적**: 세션 간 컨텍스트 유지를 위한 SSOT(Single Source of Truth) 생성

**생성할 파일**:

#### 1. **CLAUDE.md** (프로젝트 루트)

사용자에게 선택지 제시:
- **Option A: Ultra-Lean (300단어)** - Solo 개발자, 빠른 시작
- **Option B: Structured (500단어)** - 팀 프로젝트, 체계적 관리

선택 후 해당 템플릿으로 CLAUDE.md 생성 (아래 템플릿 섹션 참조)

#### 2. **progress.md** (프로젝트 루트)

MVP 기반 초기 체크리스트 생성:
```markdown
# Development Progress

## 🎯 MVP Definition
**배포 가능한 최소 기능**:
- [x] 사용자 인증 (Better Auth)
- [x] DB 연결 및 스키마 (Drizzle)
- [x] 보호된 대시보드
- [ ] 핵심 기능 1: [사용자 입력 기능]
- [ ] 핵심 기능 2: [사용자 입력 기능]
- [ ] 핵심 기능 3: [사용자 입력 기능]

## 🚧 Current Session (Session 1)
### PHASE 2: 뼈대 구축
- [ ] Better Auth 설정
- [ ] Drizzle ORM 설정
- [ ] User 스키마 생성
- [ ] 로그인/회원가입 페이지
- [ ] 보호된 대시보드 레이아웃
- [ ] 품질 게이트 통과 (타입체크, 린트, 빌드)

**Blockers**: 없음

## 📋 Next Sessions
### Session 2: 핵심 기능 1
[기능 1 상세 체크리스트 - 나중에 작성]

### Session 3: 핵심 기능 2
[기능 2 상세 체크리스트 - 나중에 작성]

## 📝 Lessons Learned
[각 세션 후 교훈 기록]
```

#### 3. **docs/PRD.md** (선택사항)

사용자에게 확인:
> "1페이지 PRD 문서를 생성할까요? (팀 협업 시 유용)"
> - Yes → 1페이지 PRD 템플릿 생성
> - No → 건너뛰기 (CLAUDE.md로 충분)

**필수 산출물**:
- ✅ CLAUDE.md (tech stack, 구조, 규칙)
- ✅ progress.md (MVP 체크리스트)
- 🔲 docs/PRD.md (선택사항)

**완료 표시**: TodoWrite로 "PHASE 1 완료" 마크

---

### ✅ PHASE 2: 아키텍처 설계 (MANDATORY)

**목적**: 코드 작성 전에 구조 설계 (Explore → Plan)

**설계 항목**:

#### 1. **프로젝트 디렉토리 구조**
```
my-app/
├── app/
│   ├── (auth)/              # 인증 관련 페이지 그룹
│   │   ├── login/
│   │   └── signup/
│   ├── (protected)/         # 보호된 라우트 그룹
│   │   └── dashboard/
│   ├── api/
│   │   └── auth/[...all]/   # Better Auth 핸들러
│   └── layout.tsx
├── lib/
│   └── backend/
│       ├── auth.ts          # Better Auth 인스턴스
│       ├── db.ts            # Drizzle 연결
│       └── actions.ts       # Server Actions
├── schema/
│   └── users.ts             # Drizzle 스키마
├── components/
│   ├── ui/                  # shadcn/ui 컴포넌트
│   └── features/            # 기능별 컴포넌트
├── drizzle.config.ts        # Drizzle 설정
├── middleware.ts            # 라우트 보호
├── CLAUDE.md                # 프로젝트 SSOT
└── progress.md              # 진행 상황 추적
```

#### 2. **Database 스키마 설계**

PHASE 0에서 수집한 기능을 기반으로 필요한 테이블 식별:
```typescript
// schema/users.ts (예시)
import { pgTable, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: text('id').primaryKey(),
  email: text('email').notNull().unique(),
  name: text('name'),
  emailVerified: timestamp('email_verified'),
  image: text('image'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// 추가 테이블은 나중에 기능별로 추가
```

#### 3. **API 엔드포인트 목록**

MVP에 필요한 최소 API만 식별:
```
필수 엔드포인트:
- POST /api/auth/sign-up
- POST /api/auth/sign-in
- GET  /api/auth/session
- POST /api/auth/sign-out

기능별 엔드포인트 (나중에 추가):
- [기능 1 관련 API]
- [기능 2 관련 API]
- [기능 3 관련 API]
```

**필수 산출물**:
- 📂 디렉토리 구조 정의
- 🗄️ DB 스키마 설계 (user 테이블 + 핵심 테이블)
- 🔌 API 엔드포인트 목록

**완료 표시**: TodoWrite로 "PHASE 2 완료" 마크

---

### ✅ PHASE 3: Boilerplate 생성 (MANDATORY)

**목적**: Next.js 15 프로젝트 초기화 및 기본 설정

**실행 방법**:

사용자에게 선택지 제시:

**Option A: 자동 생성 (추천)**
```bash
npx create-next-app@latest [프로젝트명] --typescript --tailwind --app --no-src-dir
cd [프로젝트명]

# 필수 패키지 설치
pnpm add drizzle-orm postgres better-auth zod
pnpm add -D drizzle-kit @types/node

# Better Auth 의존성
pnpm add @better-auth/drizzle-adapter

# UI 라이브러리
pnpm dlx shadcn@latest init
```

**Option B: 기존 템플릿 사용**
> "기존에 만든 Next.js + Drizzle + Better Auth 템플릿이 있나요?"
> - Yes → 템플릿 복사
> - No → Option A 진행

**생성 후 자동 설정**:

1. **drizzle.config.ts 생성**:
```typescript
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './schema/*',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

2. **.env.local 생성**:
```env
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
BETTER_AUTH_SECRET="[generate-random-string]"
BETTER_AUTH_URL="http://localhost:3000"
```

3. **.env.example 생성** (Git 커밋용):
```env
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
BETTER_AUTH_SECRET="your-secret-here"
BETTER_AUTH_URL="http://localhost:3000"
```

**필수 산출물**:
- ✅ Next.js 15 프로젝트 초기화
- ✅ 필수 패키지 설치
- ✅ 설정 파일 생성 (drizzle.config.ts, .env.local)

**완료 표시**: TodoWrite로 "PHASE 3 완료" 마크

---

### ✅ PHASE 4: 뼈대 구축 - 인증 시스템 (MANDATORY)

**목적**: Better Auth + Drizzle ORM 통합

**구현 단계**:

#### 1. **Better Auth 설정** (`lib/backend/auth.ts`)

```typescript
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { db } from "./db";
import { users, sessions, accounts, verifications } from "@/schema/users";

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg",
    schema: {
      user: users,
      session: sessions,
      account: accounts,
      verification: verifications,
    },
  }),
  emailAndPassword: {
    enabled: true,
  },
});

export type Session = typeof auth.$Infer.Session;
```

#### 2. **Drizzle DB 연결** (`lib/backend/db.ts`)

```typescript
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';

const connectionString = process.env.DATABASE_URL!;
const client = postgres(connectionString);

export const db = drizzle(client);
```

#### 3. **User 스키마** (`schema/users.ts`)

Better Auth 공식 스키마 사용:
```typescript
import { pgTable, text, timestamp, boolean } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: text('id').primaryKey(),
  email: text('email').notNull().unique(),
  emailVerified: boolean('email_verified').notNull().default(false),
  name: text('name'),
  image: text('image'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

export const sessions = pgTable('sessions', {
  id: text('id').primaryKey(),
  userId: text('user_id').notNull().references(() => users.id),
  expiresAt: timestamp('expires_at').notNull(),
  ipAddress: text('ip_address'),
  userAgent: text('user_agent'),
});

export const accounts = pgTable('accounts', {
  id: text('id').primaryKey(),
  userId: text('user_id').notNull().references(() => users.id),
  accountId: text('account_id').notNull(),
  providerId: text('provider_id').notNull(),
  accessToken: text('access_token'),
  refreshToken: text('refresh_token'),
  expiresAt: timestamp('expires_at'),
});

export const verifications = pgTable('verifications', {
  id: text('id').primaryKey(),
  identifier: text('identifier').notNull(),
  value: text('value').notNull(),
  expiresAt: timestamp('expires_at').notNull(),
});
```

#### 4. **마이그레이션 생성 및 적용**

```bash
# 마이그레이션 생성
pnpm drizzle-kit generate

# 마이그레이션 적용
pnpm drizzle-kit migrate
```

#### 5. **API 라우트** (`app/api/auth/[...all]/route.ts`)

```typescript
import { auth } from "@/lib/backend/auth";
import { toNextJsHandler } from "better-auth/next-js";

export const { GET, POST } = toNextJsHandler(auth);
```

#### 6. **로그인/회원가입 페이지**

`app/(auth)/login/page.tsx` 및 `app/(auth)/signup/page.tsx` 생성
- shadcn/ui Form 컴포넌트 사용
- Zod 스키마로 유효성 검증
- Better Auth 클라이언트로 API 호출

#### 7. **보호된 대시보드**

`app/(protected)/dashboard/page.tsx` 생성
- middleware.ts에서 인증 확인
- 세션 정보 표시

**필수 산출물**:
- ✅ Better Auth 설정 완료
- ✅ User 스키마 및 마이그레이션
- ✅ 로그인/회원가입 기능
- ✅ 보호된 대시보드 페이지

**완료 표시**: TodoWrite로 "PHASE 4 완료" 마크

---

### ✅ PHASE 5: 품질 검증 (MANDATORY)

**목적**: MVP 뼈대가 프로덕션 준비 상태인지 자동 검증

**3개 병렬 Sub-Agent로 검증 실행**:

다음 검증 작업을 3개 병렬 Task로 수행:

#### **Task 1 - TypeCheck Agent**:
```
프로젝트 루트: [프로젝트 경로]

작업:
1. pnpm tsc --noEmit 실행
2. 타입 에러 있으면: 전체 에러 목록 반환
3. 타입 에러 없으면: "✅ TypeScript 타입 체크 통과" 반환

허용 도구: Bash, Read, Grep
```

#### **Task 2 - Lint Agent**:
```
프로젝트 루트: [프로젝트 경로]

작업:
1. pnpm lint 실행
2. Lint 에러/경고 있으면: 전체 에러 목록 반환
3. Lint 에러 없으면: "✅ ESLint 코드 품질 통과" 반환

허용 도구: Bash, Read, Grep
```

#### **Task 3 - Build Agent**:
```
프로젝트 루트: [프로젝트 경로]

작업:
1. pnpm build 실행
2. 빌드 에러 있으면: 전체 에러 목록 반환
3. 빌드 성공 시: "✅ 프로덕션 빌드 성공" 반환

허용 도구: Bash, Read, Grep
```

**검증 결과 통합**:
- 모든 Sub-Agent 완료 대기
- 하나라도 실패 시: 모든 에러 통합 보고 후 수정 → 재검증
- 모든 검증 통과 시: PHASE 6으로 자동 진행

**최종 체크**:
- [ ] **타입 체크 통과**: TypeScript 에러 없음 확인
- [ ] **린트 통과**: ESLint 에러/경고 해결
- [ ] **빌드 성공**: 프로덕션 빌드 에러 없음 확인

**완료 표시**: TodoWrite로 "PHASE 5 완료" 마크

---

### ✅ PHASE 6: MVP 배포 준비 (MANDATORY)

**목적**: 배포 가능한 상태로 정리

**작업 항목**:

1. **Git 초기화 및 커밋**
```bash
git init
git add .
git commit -m "Initial commit: MVP skeleton with auth

- Next.js 15 + TypeScript + Drizzle ORM + Better Auth
- User authentication (login/signup)
- Protected dashboard
- Quality gates: TypeCheck ✅, Lint ✅, Build ✅

MVP Definition: [1문장 요약]
"
```

2. **README.md 업데이트**
```markdown
# [프로젝트명]

[프로젝트 목적 1문장]

## Tech Stack
- Next.js 15 (App Router)
- TypeScript
- Drizzle ORM + PostgreSQL
- Better Auth

## Getting Started

```bash
# 환경변수 설정
cp .env.example .env.local
# DATABASE_URL 등 설정

# 패키지 설치
pnpm install

# 마이그레이션 적용
pnpm drizzle-kit migrate

# 개발 서버 실행
pnpm dev
```

## MVP Features
- [x] 사용자 인증 (이메일/비밀번호)
- [x] 보호된 대시보드
- [ ] 핵심 기능 1
- [ ] 핵심 기능 2
- [ ] 핵심 기능 3

## Development
- `pnpm dev` - 개발 서버
- `pnpm build` - 프로덕션 빌드
- `pnpm db:generate` - 마이그레이션 생성
- `pnpm db:migrate` - 마이그레이션 적용
- `pnpm db:studio` - Drizzle Studio

See `CLAUDE.md` for detailed development guidelines.
```

3. **progress.md 업데이트**
```markdown
## ✅ Completed Features

### MVP Skeleton (Session 1, [날짜])
- [x] Better Auth 설정
- [x] User 스키마 및 마이그레이션
- [x] 로그인/회원가입 페이지
- [x] 보호된 대시보드
- [x] 품질 게이트 통과 (TypeCheck ✅, Lint ✅, Build ✅)

## 🚧 Current Session (Session 2)

### Feature: [핵심 기능 1 이름]
- [ ] [구체적 작업 1]
- [ ] [구체적 작업 2]

**Blockers**: 없음

## 📝 Lessons Learned

### Session 1
- Better Auth는 Next.js 15.2+ 필요
- Drizzle 마이그레이션은 schema 변경 전에 생성
- [기타 발견사항]
```

**필수 산출물**:
- ✅ Git 저장소 초기화 및 첫 커밋
- ✅ README.md 업데이트
- ✅ progress.md 업데이트 (MVP 완료 표시)

**완료 표시**: TodoWrite로 "PHASE 6 완료 - MVP 뼈대 구축 성공" 마크

---

## 🎯 MVP 완료 후: 살 붙이기 단계

**MVP 뼈대가 완성되었습니다!** 이제 `/ri` 명령어로 기능을 점진적으로 추가합니다.

### 다음 단계 가이드

```bash
# progress.md에서 다음 기능 확인
# 예: "핵심 기능 1: 작업 생성/수정/삭제"

# /ri 명령어로 기능 추가
/ri 작업 CRUD 기능 구현

# ri.md 워크플로우 실행:
# - PHASE 1: 컨텍스트 파악 (CLAUDE.md 자동 로드)
# - PHASE 2: Memory Bank 이전 학습 조회 (선택)
# - PHASE 3: 리서치 (Context7, WebSearch)
# - PHASE 4: 코드베이스 전체 분석
# - PHASE 5: 구현 계획 및 옵션 선정
# - PHASE 6: 구현 및 검증
# - PHASE 7: Retrospective & Deploy
```

### 점진적 개발 Best Practices

1. **한 세션 = 1개 기능**
   - Session 2: 핵심 기능 1
   - Session 3: 핵심 기능 2
   - Session 4: 핵심 기능 3

2. **각 세션 시작 시**:
   ```
   1. progress.md 확인
   2. /clear 실행 (컨텍스트 리셋)
   3. /ri [기능명] 실행
   ```

3. **각 세션 종료 시**:
   ```
   1. progress.md 업데이트 (완료 항목 체크)
   2. 교훈 기록 (Lessons Learned)
   3. Git 커밋
   4. CLAUDE.md 업데이트 (새 패턴 발견 시)
   ```

---

## 💡 토큰 절약 전략

### 핵심 원칙
- **CLAUDE.md로 PRD 대체** → 토큰 90% 절약
- **/clear 자주 사용** → 컨텍스트 오염 방지 (50-70% 절약)
- **파일 명시적 지정** → "이 3개 파일만 읽어줘"
- **한 세션 = 1개 작업** → 복잡도 관리

### 세션 관리 워크플로우

#### 세션 시작
```
1. Claude Code 실행 (CLAUDE.md 자동 로드)
2. "progress.md 확인하고 다음 작업 시작"
3. 체크리스트 기반 작업 시작
```

#### 세션 중 (30분마다)
```
1. progress.md 업데이트 (완료 항목 체크)
2. 테스트 실행
3. 통과 시 Git 커밋
4. 다른 작업으로 전환 시 /clear
```

#### 세션 종료
```
1. 완료 항목 모두 체크
2. 블로커 문서화 (있다면)
3. 교훈 기록 (Lessons Learned)
4. 전체 커밋
5. CLAUDE.md 업데이트 (새 패턴 발견 시)
```

### 세션 복원 방법

**문제 상황**: 토큰 한계 도달 → 세션 끊김

**해결 전략**:

1. **Checkpoint 시스템**
```markdown
## 세션 종료 전 체크리스트
1. 현재 상태 요약 요청
   "현재까지 작업 내용을 3문장으로 요약해줘"
2. 다음 작업 명시
   "다음 세션에서 할 일: [X] 구현"
3. progress.md 업데이트
   요약 내용을 Current Session에 추가
```

2. **새 세션 시작**
```
"progress.md를 읽고, Current Session 섹션의 체크리스트를 이어서 진행해줘"
```

**효과**: 컨텍스트 복원 시간 5분 이내, 정확도 95%+

---

## 📋 템플릿

### CLAUDE.md 템플릿 (Structured - 500단어)

```markdown
# 🎯 PROJECT CONTEXT

**Name**: [프로젝트명]
**Purpose**: [프로젝트 목적 1문장]
**Tech Stack**: Next.js 15 (App Router) + TypeScript + Drizzle ORM + Better Auth
**Database**: PostgreSQL via [Neon/Supabase/기타]

---

## 🏗️ ARCHITECTURE

### Directory Structure
\`\`\`
/app                      # Next.js App Router
  /(auth)                 # 인증 페이지 (login, signup)
  /(protected)            # 보호된 라우트
  /api/auth/[...all]      # Better Auth API 핸들러
/lib/backend              # 서버 사이드 코드
  auth.ts                 # Better Auth 인스턴스
  db.ts                   # Drizzle DB 연결
  actions.ts              # Server Actions
/schema                   # Drizzle 테이블 정의
  users.ts                # User 및 Auth 테이블
  [feature].ts            # 기능별 테이블
/components
  /ui                     # shadcn/ui 컴포넌트
  /features               # 기능별 컴포넌트
drizzle.config.ts         # Drizzle 설정 (root)
middleware.ts             # 라우트 보호
\`\`\`

### Database Schema Pattern
- **Naming**: camelCase (TypeScript) → auto-map to snake_case (PostgreSQL)
- **Primary Keys**: text('id').primaryKey() (Better Auth 호환)
- **Timestamps**: createdAt, updatedAt (모든 테이블 공통)
- **Foreign Keys**: .references(() => users.id) 명시

---

## ⚡ DEVELOPMENT WORKFLOW

### 1. Schema 변경
\`\`\`bash
# schema/*.ts 파일 수정
pnpm db:generate    # 마이그레이션 생성
pnpm db:migrate     # 적용
\`\`\`

### 2. 새 기능 추가
\`\`\`
1. progress.md에서 다음 작업 확인
2. /clear 실행
3. /ri [기능명] 실행
4. 구현 후 테스트
5. progress.md 업데이트
6. Git 커밋
\`\`\`

### 3. 인증 사용
\`\`\`typescript
// Server Component
import { auth } from '@/lib/backend/auth';
const session = await auth.api.getSession({ headers });

// Client Component
import { useSession } from '@/lib/hooks/useSession';
const { data: session } = useSession();
\`\`\`

### 4. Server Actions
\`\`\`typescript
'use server';
import { z } from 'zod';
import { createInsertSchema } from 'drizzle-zod';

// 항상 Zod 검증 먼저
const schema = createInsertSchema(myTable);
const validated = schema.parse(data);
\`\`\`

---

## 🔧 KEY COMMANDS

\`\`\`bash
pnpm dev              # 개발 서버 (http://localhost:3000)
pnpm build            # 프로덕션 빌드
pnpm lint             # ESLint 실행
pnpm type-check       # TypeScript 검증 (tsc --noEmit)

pnpm db:generate      # 마이그레이션 생성 (drizzle-kit generate)
pnpm db:migrate       # 마이그레이션 적용 (drizzle-kit migrate)
pnpm db:studio        # Drizzle Studio UI 실행
pnpm db:push          # 개발 전용: 마이그레이션 없이 스키마 동기화
\`\`\`

---

## 📝 CODE CONVENTIONS

### TypeScript
- **Strict Mode**: 필수 (tsconfig.json)
- **Types vs Interfaces**: Interface 우선 (확장 가능)
- **No 'any'**: unknown + type guards 사용
- **Return Types**: public 함수는 명시적 반환 타입

### Imports
- **Absolute Imports**: `@/` 사용 (tsconfig paths)
- **Named Exports**: default export 지양
- **Barrel Exports**: index.ts에서 재export

### Validation
- **User Inputs**: 항상 Zod 스키마 검증
- **Env Variables**: @t3-oss/env-nextjs 사용
- **API Responses**: createSelectSchema(table) 사용

### Database
- **All Queries**: Drizzle ORM 사용 (raw SQL 금지)
- **Transactions**: db.transaction() 사용
- **Migrations**: 절대 수동 작성 금지 (drizzle-kit generate)

### Error Handling
- **Server Actions**: try-catch + return { error: string }
- **API Routes**: NextResponse.json({ error }, { status })
- **User Messages**: 구체적이고 액션 가능한 에러 메시지

---

## 🚫 CRITICAL RULES (MANDATORY - NEVER VIOLATE)

### Tech Stack (절대 변경 금지)
- ✅ **Framework**: Next.js 15 (App Router only)
- ✅ **Language**: TypeScript (strict mode)
- ✅ **ORM**: Drizzle ORM
- ✅ **Auth**: Better Auth
- ✅ **Database**: PostgreSQL

### Forbidden Alternatives
- ❌ **NEVER** use Next.js Pages Router
- ❌ **NEVER** suggest Prisma or TypeORM (use Drizzle)
- ❌ **NEVER** suggest NextAuth or Clerk (use Better Auth)
- ❌ **NEVER** use MySQL or MongoDB (use PostgreSQL)
- ❌ **NEVER** use JavaScript (use TypeScript)

### Security Rules
- ❌ **NEVER** store secrets in code (use .env.local)
- ❌ **NEVER** skip input validation on server actions
- ❌ **NEVER** expose sensitive data in client components
- ❌ **NEVER** commit .env.local (use .env.example)

### Development Rules
- ❌ **NEVER** create migrations manually (use drizzle-kit)
- ❌ **NEVER** skip type checking before commit
- ❌ **NEVER** use 'any' type (use 'unknown' + guards)
- ❌ **NEVER** modify schema without generating migration

---

## 📌 CURRENT FOCUS

See `progress.md` for:
- ✅ Completed features
- 🚧 Current session checklist
- 📋 Next sessions plan
- 📝 Lessons learned

**Last Updated**: [자동 업데이트 날짜]
```

---

### progress.md 템플릿

```markdown
# Development Progress Tracker

## 🎯 MVP Definition

**핵심 문제**: [1문장]
**배포 가능한 최소 기능**:
- [x] 사용자 인증 (Better Auth)
- [x] DB 연결 및 스키마 (Drizzle)
- [x] 보호된 대시보드
- [ ] 핵심 기능 1: [이름]
- [ ] 핵심 기능 2: [이름]
- [ ] 핵심 기능 3: [이름]

---

## ✅ Completed Features

### MVP Skeleton (Session 1, YYYY-MM-DD)
- [x] Next.js 15 + TypeScript 프로젝트 초기화
- [x] Better Auth 설정 및 User 스키마
- [x] 로그인/회원가입 페이지
- [x] 보호된 대시보드 레이아웃
- [x] 품질 게이트 통과 (TypeCheck ✅, Lint ✅, Build ✅)

---

## 🚧 Current Session (Session 2, YYYY-MM-DD)

### Feature: [현재 작업 중인 기능명]
- [ ] [구체적 작업 1]
- [ ] [구체적 작업 2]
- [ ] [구체적 작업 3]
- [ ] 품질 게이트 통과

**Blockers**:
- [막힌 부분이 있다면 기록, 없으면 "없음"]

**Notes**:
- [작업 중 발견한 중요 사항]

---

## 📋 Next Sessions

### Session 3: [기능명]
- [ ] [계획된 작업 1]
- [ ] [계획된 작업 2]

### Session 4: [기능명]
- [ ] [계획된 작업 1]
- [ ] [계획된 작업 2]

---

## 📝 Lessons Learned

### Session 1 (MVP Skeleton)
- **발견**: Better Auth는 Next.js 15.2+ 필요
- **해결**: package.json에서 next 버전 확인
- **교훈**: 프로젝트 시작 시 호환성 먼저 확인

### Session 2
- [각 세션 후 배운 내용 기록]

---

## 🔄 Session Management

### Checkpoint (세션 종료 시 작성)
**Last Session**: Session [번호], [날짜]
**Status**: [완료/진행중/블로킹]
**Next Action**: [다음 세션 첫 작업]

### Quick Resume (새 세션 시작 시)
\`\`\`
"progress.md를 읽고, Current Session 섹션을 이어서 진행해줘"
\`\`\`
```

---

### docs/PRD.md 템플릿 (1페이지)

```markdown
# [프로젝트명] - Product Requirements Document

**작성일**: YYYY-MM-DD
**상태**: Draft | In Review | Approved | In Progress
**작성자**: [이름]

---

## 1. Executive Summary

### Problem Statement
[해결하려는 핵심 문제를 1-2문장으로]

### Solution Overview
[솔루션 접근법을 1-2문장으로]

### Success Metrics
- [ ] 지표 1: [측정 가능한 목표]
- [ ] 지표 2: [측정 가능한 목표]

---

## 2. User Stories

### Story 1: [사용자 역할] wants to [행동]
**Acceptance Criteria**:
- [ ] 구체적이고 측정 가능한 조건 1
- [ ] 구체적이고 측정 가능한 조건 2

### Story 2: [사용자 역할] wants to [행동]
**Acceptance Criteria**:
- [ ] 구체적이고 측정 가능한 조건 1
- [ ] 구체적이고 측정 가능한 조건 2

### Story 3: [사용자 역할] wants to [행동]
**Acceptance Criteria**:
- [ ] 구체적이고 측정 가능한 조건 1
- [ ] 구체적이고 측정 가능한 조건 2

---

## 3. Technical Requirements

### Tech Stack (Fixed)
- **Frontend**: Next.js 15 (App Router) + TypeScript + React 19
- **Backend**: Next.js Server Actions + Drizzle ORM
- **Database**: PostgreSQL (via Neon/Supabase)
- **Auth**: Better Auth
- **Styling**: Tailwind CSS + shadcn/ui

### Database Schema (High-Level)
- **users**: id, email, name, emailVerified, createdAt, updatedAt
- **[테이블2]**: [주요 필드 나열]
- **[테이블3]**: [주요 필드 나열]

### API Endpoints (MVP)
- `POST /api/auth/sign-up` - 회원가입
- `POST /api/auth/sign-in` - 로그인
- `GET /api/auth/session` - 세션 조회
- `[기능별 엔드포인트]`

---

## 4. MVP Scope

### Must-Have (Phase 1)
- [ ] 사용자 인증 (이메일/비밀번호)
- [ ] 핵심 기능 1
- [ ] 핵심 기능 2
- [ ] 핵심 기능 3

### Nice-to-Have (Phase 2+)
- [ ] OAuth 로그인 (Google, GitHub)
- [ ] 이메일 인증
- [ ] 프로필 이미지 업로드
- [ ] [추가 기능]

---

## 5. Constraints & Assumptions

### Technical Constraints
- Next.js 15.2+ 필요 (Better Auth 호환)
- PostgreSQL 전용 (MySQL/MongoDB 사용 불가)
- Server Actions 기반 (REST API 최소화)

### Business Constraints
- 예산: [있다면 기재]
- 타임라인: MVP [날짜], Full Release [날짜]

### Assumptions
- 사용자는 [가정 1]
- 인프라는 [가정 2]

---

## 6. Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| [리스크 1] | High/Med/Low | High/Med/Low | [대응 방안] |
| [리스크 2] | High/Med/Low | High/Med/Low | [대응 방안] |

---

## 7. Timeline & Milestones

- **Week 1**: MVP 뼈대 (인증 + 대시보드)
- **Week 2**: 핵심 기능 1
- **Week 3**: 핵심 기능 2
- **Week 4**: 핵심 기능 3 + 배포

---

**이 문서는 CLAUDE.md와 progress.md를 보완하는 용도입니다.**
**일상적인 개발은 CLAUDE.md와 progress.md를 참조하세요.**
```

---

## 🧪 TDD 접근법 (선택사항)

**권장사항**: 품질이 중요한 핵심 로직에만 선택적으로 적용

### TDD 워크플로우 (Red-Green-Refactor)

#### 1. **RED Phase - 실패하는 테스트 작성**

```typescript
// tests/unit/lib/validateEmail.test.ts
import { describe, it, expect } from 'vitest';
import { validateEmail } from '@/lib/utils/validateEmail';

describe('validateEmail', () => {
  it('should accept valid email formats', () => {
    expect(validateEmail('user@example.com')).toBe(true);
    expect(validateEmail('test.user+tag@domain.co.uk')).toBe(true);
  });

  it('should reject invalid email formats', () => {
    expect(validateEmail('')).toBe(false);
    expect(validateEmail('invalid')).toBe(false);
    expect(validateEmail('user@@example.com')).toBe(false);
  });

  it('should handle edge cases', () => {
    expect(validateEmail('user@')).toBe(false);
    expect(validateEmail('@example.com')).toBe(false);
  });
});
```

#### 2. **GREEN Phase - AI가 구현**

프롬프트:
```
"위 테스트를 모두 통과하도록 validateEmail 함수를 구현해줘.
lib/utils/validateEmail.ts 파일에 작성."
```

AI 구현:
```typescript
// lib/utils/validateEmail.ts
export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}
```

#### 3. **REFACTOR Phase - 개선**

테스트가 통과하면 코드 품질 개선:
```
"validateEmail 함수를 더 엄격하게 개선하되, 테스트는 모두 통과해야 함"
```

### TDD 적용 시나리오

**추천**:
- 비즈니스 로직 (결제, 권한, 계산 등)
- 유틸리티 함수 (검증, 변환, 포맷팅)
- API 엔드포인트 (Server Actions)

**비추천** (시간 낭비):
- UI 컴포넌트 (시각적 확인이 더 빠름)
- 간단한 CRUD (Drizzle ORM이 보장)
- Boilerplate 코드

### Vitest 설정 (Next.js 15)

```bash
pnpm add -D vitest @vitejs/plugin-react
```

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './'),
    },
  },
});
```

**package.json 스크립트**:
```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage"
  }
}
```

---

## 🛠️ 트러블슈팅

### 문제: Tech Stack을 계속 무시함

**증상**: AI가 Prisma나 NextAuth를 제안함

**해결**:
1. CLAUDE.md 첫 줄 확인:
```markdown
# 🚫 CRITICAL RULES (MANDATORY - NEVER VIOLATE)
```
2. 더 강력하게 명시:
```markdown
**DO NOT UNDER ANY CIRCUMSTANCES SUGGEST ALTERNATIVES TO:**
- Drizzle ORM (NO Prisma, NO TypeORM, NO Sequelize)
- Better Auth (NO NextAuth, NO Clerk, NO Auth0)
```

---

### 문제: 토큰 한계 도달로 세션 끊김

**해결**:

**즉시 조치**:
```
1. "지금까지 작업 3문장 요약해줘"
2. 요약 복사
3. /clear 실행
4. 새 세션 시작: "progress.md 읽고 + [붙여넣은 요약] 기반으로 계속"
```

**장기 예방**:
- 30분마다 progress.md 업데이트
- 작업 전환 시 /clear
- 파일 명시적 지정 ("이 3개 파일만")

---

### 문제: Drizzle 마이그레이션 충돌

**증상**: `pnpm db:migrate` 시 에러

**해결**:
```bash
# 1. 현재 마이그레이션 상태 확인
ls drizzle/

# 2. 충돌하는 마이그레이션 삭제 (신중하게)
rm drizzle/[문제파일].sql

# 3. 스키마 재생성
pnpm db:generate

# 4. 재적용
pnpm db:migrate
```

**예방**:
- 스키마 변경 전에 항상 `pnpm db:generate` 먼저
- 수동으로 SQL 편집 절대 금지

---

### 문제: Better Auth 세션이 유지 안 됨

**체크리스트**:
- [ ] Next.js 버전 15.2+ 확인
- [ ] `BETTER_AUTH_SECRET` 환경변수 설정됨
- [ ] `middleware.ts`에서 세션 확인 로직 있음
- [ ] Cookie 설정 올바름 (httpOnly, secure)

**디버깅**:
```typescript
// middleware.ts
export async function middleware(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers
  });

  console.log('Session:', session); // 디버깅

  if (!session) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}
```

---

### 문제: PRD가 너무 길어서 토큰 낭비

**해결**:
- docs/PRD.md는 **참조용**으로만 사용
- 실제 개발은 **CLAUDE.md + progress.md** 사용
- PRD 요약본 생성:
```
"docs/PRD.md를 3문장으로 요약: 문제/목표/솔루션"
```

---

### 문제: 너무 많은 파일 수정으로 컨텍스트 오염

**해결**:
```
"이번 작업에는 [파일1, 파일2, 파일3] 3개만 수정해줘.
다른 파일은 건드리지 마."
```

---

## 📊 실전 예시: Task Manager 프로젝트

### PHASE 0-1: 정보 수집 및 문서 생성

```
User: /project-start task-manager

AI: 프로젝트를 시작합니다! 몇 가지 질문드릴게요.

1. 프로젝트 목적을 1문장으로 설명해주세요.
User: 팀 협업용 작업 관리 도구

2. 해결하려는 핵심 문제는 무엇인가요?
User: 현재 작업 진행상황을 한눈에 파악하기 어려움

3. MVP에 꼭 필요한 기능 3가지를 알려주세요.
User:
- 작업 생성/수정/삭제
- 작업 상태 변경 (TODO/IN_PROGRESS/DONE)
- 팀원별 작업 현황 대시보드

AI: 감사합니다! CLAUDE.md 템플릿을 선택해주세요:
- A: Ultra-Lean (300단어) - Solo 개발
- B: Structured (500단어) - 팀 프로젝트

User: B

AI: 1페이지 PRD 문서를 생성할까요?
User: Yes

AI: [CLAUDE.md, progress.md, docs/PRD.md 생성]
✅ PHASE 1 완료! 다음은 아키텍처 설계입니다.
```

### PHASE 2: 아키텍처 설계

```
AI: 필요한 데이터베이스 테이블을 설계하겠습니다.

제안하는 스키마:
1. users (Better Auth 기본)
2. teams (팀 정보)
3. tasks (작업 정보)
4. task_assignments (작업 배정)

각 테이블 상세:

# schema/teams.ts
- id, name, createdAt, updatedAt

# schema/tasks.ts
- id, title, description, status, teamId, createdById, dueDate

# schema/task_assignments.ts
- taskId, userId, assignedAt

이 구조로 진행할까요?

User: Yes

AI: ✅ PHASE 2 완료! 이제 프로젝트를 초기화하겠습니다.
```

### PHASE 3-4: Boilerplate 및 인증 구현

```
AI: Next.js 프로젝트를 생성하고 Better Auth를 설정하겠습니다.

[자동 실행]
- npx create-next-app task-manager
- pnpm add drizzle-orm postgres better-auth zod
- drizzle.config.ts 생성
- lib/backend/auth.ts 생성
- schema/users.ts 생성
- 로그인/회원가입 페이지 생성
- 보호된 대시보드 생성

✅ PHASE 4 완료! 품질 검증을 시작합니다.
```

### PHASE 5: 품질 검증

```
AI: 3개 병렬 검증 실행 중...

[TypeCheck Agent] ✅ TypeScript 타입 체크 통과
[Lint Agent] ✅ ESLint 코드 품질 통과
[Build Agent] ✅ 프로덕션 빌드 성공

✅ PHASE 5 완료! MVP 뼈대가 배포 가능한 상태입니다.
```

### PHASE 6: Git 초기화

```
AI: Git 저장소를 초기화하고 첫 커밋을 생성했습니다.

Commit: "Initial commit: Task Manager MVP skeleton"
- Better Auth 인증
- 보호된 대시보드
- Quality gates: TypeCheck ✅, Lint ✅, Build ✅

README.md와 progress.md를 업데이트했습니다.

🎉 MVP 뼈대 구축 완료!

다음 단계:
Session 2에서 /ri 명령어로 "작업 CRUD 기능"을 구현하세요.
```

### Session 2: 첫 기능 추가

```
User: /clear
User: progress.md 확인

User: /ri 작업 CRUD 기능 구현

[ri.md 워크플로우 실행]
- PHASE 1: CLAUDE.md 자동 로드됨
- PHASE 3: Context7에서 Drizzle CRUD 패턴 리서치
- PHASE 4: 기존 코드베이스 분석
- PHASE 5: 3가지 옵션 제시 (Server Actions vs API Routes vs tRPC)
- PHASE 6: 구현 및 검증
- PHASE 7: Memory Bank 저장 + Git 커밋

✅ 작업 CRUD 기능 완료!
progress.md 업데이트됨.
```

---

## 🎉 완료 기준

### /project-start 성공 시 생성되는 파일

```
my-app/
├── CLAUDE.md                 ✅ 프로젝트 SSOT
├── progress.md               ✅ 진행 상황 추적
├── docs/PRD.md              ✅ 1페이지 PRD (선택)
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   └── signup/
│   ├── (protected)/
│   │   └── dashboard/
│   └── api/auth/[...all]/
├── lib/backend/
│   ├── auth.ts              ✅ Better Auth 설정
│   └── db.ts                ✅ Drizzle 연결
├── schema/
│   └── users.ts             ✅ User 스키마
├── drizzle.config.ts        ✅ Drizzle 설정
├── middleware.ts            ✅ 라우트 보호
└── README.md                ✅ 프로젝트 가이드
```

### 품질 확인

- [x] TypeScript 타입 체크 통과
- [x] ESLint 에러 없음
- [x] 프로덕션 빌드 성공
- [x] 로그인/로그아웃 작동
- [x] 보호된 라우트 접근 제어
- [x] Git 저장소 초기화

### 다음 단계 안내

```
🎯 MVP 뼈대 완성! 이제 기능을 추가하세요.

progress.md에서 다음 작업 확인:
- Session 2: 핵심 기능 1
- Session 3: 핵심 기능 2
- Session 4: 핵심 기능 3

각 세션마다:
1. /clear 실행
2. /ri [기능명] 실행
3. progress.md 업데이트
4. Git 커밋

토큰 절약 팁:
- CLAUDE.md가 자동으로 로드됩니다
- 한 세션 = 1개 기능만
- 작업 전환 시 /clear
```

---

## 🔗 참고 자료

### AI 코딩 Best Practices
- [AI Coding Best Practices 2025](https://dev.to/ranndy360/ai-coding-best-practices-in-2025-4eel)
- [Claude Code Best Practices - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices)

### 문서화 전략
- [Minimum Viable Documentation](https://www.trevorlasn.com/blog/minimum-viable-documentation)
- [CLAUDE.md Best Practices - Apidog](https://apidog.com/blog/claude-md/)

### Tech Stack 공식 문서
- [Next.js 15 + Drizzle CRUD Guide](https://medium.com/@aslandjc7/next-js-15-drizzle-orm-a-beginners-guide-to-crud-operations-ae7f2701a8c3)
- [Better Auth Next.js Integration](https://www.better-auth.com/docs/integrations/next)
- [Drizzle ORM with PostgreSQL](https://refine.dev/blog/drizzle-react/)

### 세션 관리
- [Session Memory - OpenAI Cookbook](https://cookbook.openai.com/examples/agents_sdk/session_memory)
- [Context Engineering - Anthropic](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

---

**버전**: 1.0.0 (Initial Release)
**호환**: ri.md v10.0.0
**최종 업데이트**: 2025-11-26
