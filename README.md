# 엘림G브릿지 (elimgbridge)

이주민·유학생·청소년·다문화 가정·기업을 연결하는 글로컬 선교 통합 플랫폼.

## 사이트 구조

- `/` — 랜딩 (5개 서비스 카드)
- `/02_registration_form.html` — 통합 등록 폼
- `/04_biz_match_page.html` — 기업 매칭
- `/05a_youth_page.html` — 이주민 청소년 지원
- `/05b_student_page.html` — 유학생 허브
- `/07_dagachi.html` — 다가치 연동

## 백엔드 청사진 (`docs/`)

- `01_schema.sql` — Supabase 통합 DB 스키마 (7 테이블, 8 사용자 타입)
- `03_supabase_setup_guide.md` — Supabase 프로젝트 설정 가이드
- `06_youtube_content_plan.md` — YouTube 채널 운영 계획 (@elimgbridge)

## 배포

- 호스팅: Netlify (정적)
- 도메인: `elim-g-bridge.netlify.app` (임시) → 사용자 도메인 통일 예정

## 단계

- ✅ Phase 1: 정적 사이트 배포
- ⏳ Phase 2: Supabase DB 연결 (등록 폼 → DB)
- ⏳ Phase 3: YouTube 채널 + 콘텐츠

## 관계 도메인

- elimg.kr — 엘림G브릿지 선교회 (메인)
- elimg.com — GlocalBridge AI 컨설팅 (비즈)
- elim-g-bridge.netlify.app — 통합 플랫폼 (이 저장소)
