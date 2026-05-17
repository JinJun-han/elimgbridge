# Supabase 설정 가이드 — 엘림G브릿지

## 1단계: 프로젝트 생성

1. [supabase.com](https://supabase.com) → **Start your project** → GitHub 로그인
2. **New project** 클릭
   - Name: `elimgbridge`
   - Database Password: 안전한 비밀번호 기록해두기
   - Region: **Northeast Asia (Seoul)** 선택
3. 약 2분 대기 (프로젝트 초기화)

---

## 2단계: 스키마 실행

1. 좌측 메뉴 → **SQL Editor**
2. `+ New query` 클릭
3. `01_schema.sql` 전체 내용 붙여넣기
4. **Run** (Ctrl+Enter)
5. 완료 메시지 확인: `Success. No rows returned`

> **확인**: 좌측 메뉴 → Table Editor → 7개 테이블이 보이면 성공
> users / companies / job_postings / job_matches / government_partners / gov_programs / contacts

---

## 3단계: API 키 복사

1. 좌측 메뉴 → **Project Settings** → **API**
2. 두 값을 복사:

```
Project URL:  https://xxxxxxxxxxxxxx.supabase.co
anon public:  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 4단계: 등록 폼에 키 삽입

`02_registration_form.html` 파일 열기 → 상단 설정 부분 수정:

```javascript
// 변경 전
const SUPABASE_URL  = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON = 'YOUR_ANON_KEY';

// 변경 후 (본인 값으로)
const SUPABASE_URL  = 'https://abcdefghijklmn.supabase.co';
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## 5단계: 사이트에 폼 삽입

### 방법 A — iframe 삽입 (가장 간단)

`02_registration_form.html`을 Netlify에 별도 배포 후:

```html
<!-- elimg.kr index.html의 #register 섹션에 추가 -->
<iframe
  src="https://elimgbridge-form.netlify.app"
  width="100%" height="800"
  frameborder="0" style="border-radius:12px;">
</iframe>
```

### 방법 B — 직접 삽입

`02_registration_form.html`의 `<style>`, `<div class="form-container">`, `<script>` 블록을
elimg.kr의 해당 섹션에 직접 복사.

---

## 6단계: 테스트

1. 브라우저에서 `02_registration_form.html` 열기
2. 유형 선택 → 정보 입력 → 동의 → 등록 완료
3. Supabase → Table Editor → `users` 테이블 → 데이터 확인

---

## 관리자 대시보드 (무료)

Supabase Table Editor에서 바로 데이터 조회/수정/내보내기 가능:
- **Table Editor** → users 테이블 → Filter/Sort/CSV export
- **SQL Editor**에서 쿼리:

```sql
-- 오늘 등록자 수
SELECT user_type, COUNT(*) FROM users
WHERE created_at > now() - interval '24 hours'
GROUP BY user_type;

-- 지역별 이주민 근로자
SELECT region, COUNT(*) FROM users
WHERE user_type = 'immigrant_worker'
GROUP BY region ORDER BY count DESC;

-- 연락처 미확인 문의
SELECT name, contact, message, category, created_at
FROM contacts WHERE is_resolved = false
ORDER BY created_at DESC;
```

---

## 무료 플랜 한도

| 항목 | 무료 한도 |
|------|----------|
| DB 용량 | 500 MB |
| 월 API 요청 | 무제한 |
| 동시 연결 | 60개 |
| 파일 스토리지 | 1 GB |

> 등록자 10만 명 기준 약 50MB — 무료 플랜으로 충분히 운영 가능

---

## 문제 해결

**등록 시 CORS 오류**
→ Supabase 프로젝트 Settings → API → Allowed origins에 사이트 도메인 추가
예: `https://elimg.kr`, `https://elimg.com`

**"relation users does not exist"**
→ 01_schema.sql을 다시 실행 (SQL Editor)

**anon INSERT 거부**
→ SQL Editor에서 RLS 정책 확인:
```sql
SELECT * FROM pg_policies WHERE tablename = 'users';
```
`anon_insert_users` 정책이 있어야 함.
