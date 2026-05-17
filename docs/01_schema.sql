-- ══════════════════════════════════════════════
-- 엘림G브릿지 (ElimG Bridge) — Supabase 통합 DB
-- 파일: 01_schema.sql
-- 실행: Supabase Studio > SQL Editor > 붙여넣기 > Run
-- ══════════════════════════════════════════════

-- 1. 사용자 유형 ENUM
CREATE TYPE user_type AS ENUM (
  'immigrant_worker',       -- 이주민 근로자
  'international_student',  -- 한국 내 외국인 유학생
  'overseas_student',       -- 해외 유학 준비생/재학생
  'immigrant_youth',        -- 이주민 청소년 (본인 등록)
  'multicultural_family',   -- 다문화 가정
  'parent',                 -- 이주민 자녀의 부모
  'volunteer',              -- 봉사자/사역자
  'church_partner'          -- 협력 교회/기관
);

-- 2. 통합 사용자 테이블
CREATE TABLE IF NOT EXISTS users (
  id                     UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at             TIMESTAMPTZ DEFAULT now(),
  user_type              user_type NOT NULL,

  -- 공통
  name                   TEXT NOT NULL,
  nationality            TEXT NOT NULL,
  age_group              TEXT,             -- '10대','20대','30대','40대이상'
  phone                  TEXT,
  kakao_id               TEXT,
  email                  TEXT,
  region                 TEXT,             -- '거제','김해','울산','창원','부산','서울','기타'
  language               TEXT DEFAULT 'ko',
  consent_personal_info  BOOLEAN DEFAULT false,
  site_source            TEXT,             -- 'elimg.kr','elimg.com','glocal-student' 등
  notes                  TEXT,

  -- 근로자 전용
  workplace              TEXT,
  kiip_level             INTEGER,          -- 0~5

  -- 유학생 전용 (international_student)
  university             TEXT,
  major                  TEXT,
  study_year             TEXT,             -- '1','2','3','4','대학원','어학연수'
  visa_type              TEXT,             -- 'D-2','D-4','기타'
  scholarship_interest   BOOLEAN DEFAULT false,
  parttime_job_need      BOOLEAN DEFAULT false,

  -- 해외 유학 전용 (overseas_student)
  target_country         TEXT,
  target_university      TEXT,
  departure_year         TEXT,
  mission_interest       BOOLEAN DEFAULT false,

  -- 청소년 전용 (immigrant_youth / multicultural_family)
  school_level           TEXT,             -- '초등학교','중학교','고등학교'
  school_name            TEXT,
  parent_nationality     TEXT,
  korean_proficiency     TEXT,             -- '상','중','하'
  career_interest        TEXT,
  counseling_need        BOOLEAN DEFAULT false,

  -- 서비스 관심 배열
  service_interest       TEXT[]
);

-- 3. 기업 테이블
CREATE TABLE IF NOT EXISTS companies (
  id                     UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at             TIMESTAMPTZ DEFAULT now(),
  company_name           TEXT NOT NULL,
  company_type           TEXT,             -- 'enterprise','partner','sme','social'
  industry               TEXT,             -- '조선','제조','농업','IT','서비스'
  region                 TEXT,
  contact_name           TEXT,
  contact_phone          TEXT,
  contact_email          TEXT,
  employee_count         INTEGER,
  foreign_worker_count   INTEGER,
  hiring_need            TEXT[],
  language_need          TEXT[],
  kiip_support           BOOLEAN DEFAULT false,
  is_verified            BOOLEAN DEFAULT false,
  memo                   TEXT
);

-- 4. 구인 공고 테이블
CREATE TABLE IF NOT EXISTS job_postings (
  id                     UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at             TIMESTAMPTZ DEFAULT now(),
  company_id             UUID REFERENCES companies(id),
  title                  TEXT NOT NULL,
  description            TEXT,
  required_nationality   TEXT[],
  required_language      TEXT[],
  required_kiip_level    INTEGER,
  salary_range           TEXT,
  work_region            TEXT,
  visa_sponsorship       BOOLEAN DEFAULT false,
  housing_support        BOOLEAN DEFAULT false,
  is_active              BOOLEAN DEFAULT true,
  deadline               DATE
);

-- 5. 사용자-기업 매칭 테이블
CREATE TABLE IF NOT EXISTS job_matches (
  id                     UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at             TIMESTAMPTZ DEFAULT now(),
  user_id                UUID REFERENCES users(id),
  job_id                 UUID REFERENCES job_postings(id),
  status                 TEXT DEFAULT 'applied', -- 'applied','reviewing','interview','hired','rejected'
  match_score            INTEGER,                -- AI 매칭 점수 0~100
  notes                  TEXT
);

-- 6. 지자체·기관 파트너 테이블
CREATE TABLE IF NOT EXISTS government_partners (
  id                     UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at             TIMESTAMPTZ DEFAULT now(),
  org_name               TEXT NOT NULL,
  org_type               TEXT,             -- 'central','provincial','municipal','agency'
  region                 TEXT,
  contact_name           TEXT,
  contact_email          TEXT,
  partnership_type       TEXT[],           -- ['MOU','사업위탁','보조금','데이터연계']
  budget_support         INTEGER,          -- 연간 지원 예산 (만원)
  mou_date               DATE,
  renewal_date           DATE,
  is_active              BOOLEAN DEFAULT true
);

-- 7. 정부 지원 사업 테이블
CREATE TABLE IF NOT EXISTS gov_programs (
  id                     UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at             TIMESTAMPTZ DEFAULT now(),
  partner_id             UUID REFERENCES government_partners(id),
  program_name           TEXT NOT NULL,
  program_type           TEXT,             -- 'KIIP','취업지원','다문화교육','창업지원','의료지원'
  target_group           TEXT[],           -- ['근로자','유학생','청소년','다문화가정']
  budget                 INTEGER,
  beneficiary_count      INTEGER,
  start_date             DATE,
  end_date               DATE,
  application_url        TEXT,
  notes                  TEXT
);

-- 8. 문의/상담 테이블
CREATE TABLE IF NOT EXISTS contacts (
  id                     UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at             TIMESTAMPTZ DEFAULT now(),
  name                   TEXT NOT NULL,
  contact                TEXT NOT NULL,
  message                TEXT NOT NULL,
  category               TEXT,             -- 'kiip','b2b','mission','academy','youth','student'
  site_source            TEXT,
  is_resolved            BOOLEAN DEFAULT false
);

-- ══════════════════════════════════════════════
-- RLS (Row Level Security) 설정
-- ══════════════════════════════════════════════

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_postings ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE government_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE gov_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

-- 익명 INSERT 허용 (등록 폼용)
CREATE POLICY "anon_insert_users"      ON users         FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_insert_companies"  ON companies     FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_insert_matches"    ON job_matches   FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_insert_contacts"   ON contacts      FOR INSERT TO anon WITH CHECK (true);

-- 구인공고는 누구나 조회 가능
CREATE POLICY "public_read_jobs"       ON job_postings  FOR SELECT TO anon USING (is_active = true);
CREATE POLICY "public_read_programs"   ON gov_programs  FOR SELECT TO anon USING (true);
