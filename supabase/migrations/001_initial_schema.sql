-- ============================================================
-- OraclePath Platform — Production Database Schema
-- Parent: Ervion Technologies
-- PostgreSQL 15+ | Supabase (Row Level Security Enabled)
-- ============================================================
--
-- IMPORTANT: This file contains ONLY production schema — tables,
-- indexes, RLS policies, security functions, and triggers.
-- It does NOT contain demo seed data, fake business metrics,
-- or any development-only content.
--
-- For development/demo seed data, see: supabase/seed.sql
--
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- 1. PROFILES (extends auth.users)
-- ============================================================
CREATE TABLE public.profiles (
    id              uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
    email           text NOT NULL UNIQUE,
    full_name       text NOT NULL,
    role            text NOT NULL CHECK (role IN ('super_admin', 'admin', 'instructor', 'student')),
    avatar_url      text,
    phone           text,
    title           text,
    bio             text,
    linkedin_url    text,
    github_url      text,
    is_active       boolean DEFAULT true,
    last_seen_at    timestamptz DEFAULT now(),
    created_at      timestamptz DEFAULT now(),
    updated_at      timestamptz DEFAULT now()
);

COMMENT ON TABLE public.profiles IS 'Extended user profiles. Role is ALWAYS student on creation. Only administrators may change roles.';

-- ============================================================
-- 2. COURSES
-- ============================================================
CREATE TABLE public.courses (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           text NOT NULL,
    subtitle        text NOT NULL,
    slug            text UNIQUE NOT NULL,
    description     text NOT NULL,
    level           text NOT NULL CHECK (level IN ('Beginner', 'Intermediate', 'Advanced')),
    duration        text NOT NULL,
    lessons_count   int NOT NULL DEFAULT 0 CHECK (lessons_count >= 0),
    rating          numeric(3,2) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    price           numeric(10,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
    original_price  numeric(10,2) CHECK (original_price IS NULL OR original_price >= 0),
    currency        text DEFAULT 'USD',
    tags            text[] DEFAULT '{}',
    topics          text[] DEFAULT '{}',
    instructor_id   uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    instructor_name text NOT NULL,
    students_count  int NOT NULL DEFAULT 0 CHECK (students_count >= 0),
    featured        boolean DEFAULT false,
    status          text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'draft', 'archived')),
    thumbnail_url   text,
    promo_video_url text,
    seo_meta_title  text,
    seo_meta_desc   text,
    created_at      timestamptz DEFAULT now(),
    updated_at      timestamptz DEFAULT now()
);

CREATE INDEX idx_courses_status ON public.courses(status);
CREATE INDEX idx_courses_featured ON public.courses(featured) WHERE featured = true;
CREATE INDEX idx_courses_level ON public.courses(level);
CREATE INDEX idx_courses_instructor ON public.courses(instructor_id);

-- ============================================================
-- 3. LESSONS (Course Content / LMS)
-- ============================================================
CREATE TABLE public.lessons (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id       uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    module_id       uuid,
    title           text NOT NULL,
    description     text,
    lesson_type     text NOT NULL DEFAULT 'video' CHECK (lesson_type IN ('video', 'text', 'quiz', 'lab', 'assignment', 'project')),
    video_url       text,
    video_duration  int CHECK (video_duration IS NULL OR video_duration >= 0),
    content_body    text,
    lab_schema      text,
    lab_solution    text,
    lab_hints       text[],
    sort_order      int NOT NULL DEFAULT 0,
    is_free_preview boolean DEFAULT false,
    is_published    boolean DEFAULT false,
    created_at      timestamptz DEFAULT now(),
    updated_at      timestamptz DEFAULT now()
);

CREATE INDEX idx_lessons_course ON public.lessons(course_id);
CREATE INDEX idx_lessons_sort ON public.lessons(course_id, sort_order);

-- ============================================================
-- 4. QUIZZES & QUESTIONS
-- ============================================================
CREATE TABLE public.quizzes (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id       uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    title           text NOT NULL,
    passing_score   int NOT NULL DEFAULT 70 CHECK (passing_score >= 0 AND passing_score <= 100),
    time_limit      int CHECK (time_limit IS NULL OR time_limit > 0),
    max_attempts    int DEFAULT 3 CHECK (max_attempts >= 0),
    created_at      timestamptz DEFAULT now()
);

CREATE TABLE public.quiz_questions (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id         uuid NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
    question_text   text NOT NULL,
    question_type   text NOT NULL DEFAULT 'multiple_choice' CHECK (question_type IN ('multiple_choice', 'true_false', 'fill_blank', 'code_output')),
    options         jsonb,
    explanation     text,
    sort_order      int NOT NULL DEFAULT 0,
    points          int NOT NULL DEFAULT 1 CHECK (points > 0)
);

-- ============================================================
-- 5. ENROLLMENTS
-- ============================================================
CREATE TABLE public.enrollments (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id       uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    status          text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'dropped', 'paused')),
    progress_pct    int NOT NULL DEFAULT 0 CHECK (progress_pct >= 0 AND progress_pct <= 100),
    enrolled_at     timestamptz DEFAULT now(),
    completed_at    timestamptz,
    last_accessed_at timestamptz DEFAULT now(),
    UNIQUE(user_id, course_id)
);

CREATE INDEX idx_enrollments_user ON public.enrollments(user_id);
CREATE INDEX idx_enrollments_course ON public.enrollments(course_id);
CREATE INDEX idx_enrollments_status ON public.enrollments(status);

-- ============================================================
-- 6. LESSON PROGRESS
-- ============================================================
CREATE TABLE public.lesson_progress (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    lesson_id       uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    course_id       uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    is_completed    boolean DEFAULT false,
    time_spent_sec  int DEFAULT 0 CHECK (time_spent_sec >= 0),
    quiz_score      int CHECK (quiz_score IS NULL OR quiz_score >= 0),
    lab_attempts    int DEFAULT 0 CHECK (lab_attempts >= 0),
    lab_passed      boolean DEFAULT false,
    completed_at    timestamptz,
    UNIQUE(user_id, lesson_id)
);

CREATE INDEX idx_lesson_progress_user ON public.lesson_progress(user_id);
CREATE INDEX idx_lesson_progress_course ON public.lesson_progress(course_id);

-- ============================================================
-- 7. CERTIFICATES
-- ============================================================
CREATE TABLE public.certificates (
    id                  uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id           uuid NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    certificate_number  text NOT NULL UNIQUE,
    issued_at           timestamptz DEFAULT now(),
    status              text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'revoked', 'expired')),
    pdf_url             text,
    UNIQUE(user_id, course_id)
);

CREATE INDEX idx_certificates_user ON public.certificates(user_id);

-- ============================================================
-- 8. INTERNSHIPS
-- ============================================================
CREATE TABLE public.internships (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           text NOT NULL,
    company         text NOT NULL,
    company_logo_url text,
    location        text NOT NULL,
    type            text NOT NULL CHECK (type IN ('Remote', 'Hybrid', 'On-site')),
    duration        text NOT NULL,
    stipend         text,
    description     text NOT NULL,
    requirements    text[] DEFAULT '{}',
    skills          text[] DEFAULT '{}',
    openings        int NOT NULL DEFAULT 1 CHECK (openings >= 0),
    deadline        date,
    featured        boolean DEFAULT false,
    status          text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed', 'filled', 'on_hold')),
    contact_email   text,
    created_at      timestamptz DEFAULT now(),
    updated_at      timestamptz DEFAULT now()
);

CREATE INDEX idx_internships_status ON public.internships(status);
CREATE INDEX idx_internships_featured ON public.internships(featured) WHERE featured = true;

-- ============================================================
-- 9. INTERNSHIP APPLICATIONS
-- ============================================================
CREATE TABLE public.internship_applications (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    internship_id   uuid NOT NULL REFERENCES public.internships(id) ON DELETE CASCADE,
    status          text NOT NULL DEFAULT 'submitted' CHECK (status IN ('submitted', 'reviewing', 'interview_scheduled', 'accepted', 'rejected', 'withdrawn')),
    applied_at      timestamptz DEFAULT now(),
    resume_url      text,
    cover_letter    text,
    portfolio_url   text,
    notes           text,
    updated_at      timestamptz DEFAULT now(),
    UNIQUE(user_id, internship_id)
);

CREATE INDEX idx_internship_apps_user ON public.internship_applications(user_id);
CREATE INDEX idx_internship_apps_internship ON public.internship_applications(internship_id);
CREATE INDEX idx_internship_apps_status ON public.internship_applications(status);

-- ============================================================
-- 10. ORDERS / PAYMENTS
-- ============================================================
CREATE TABLE public.orders (
    id                  uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    order_number        text NOT NULL UNIQUE,
    status              text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded', 'cancelled')),
    total_amount        numeric(10,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    currency            text DEFAULT 'USD',
    payment_intent_id   text,
    payment_method      text,
    payment_provider    text DEFAULT 'stripe',
    receipt_url         text,
    invoice_url         text,
    tax_amount          numeric(10,2) DEFAULT 0 CHECK (tax_amount >= 0),
    discount_amount     numeric(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
    coupon_code         text,
    metadata            jsonb DEFAULT '{}',
    created_at          timestamptz DEFAULT now(),
    updated_at          timestamptz DEFAULT now()
);

CREATE INDEX idx_orders_user ON public.orders(user_id);
CREATE INDEX idx_orders_status ON public.orders(status);

-- ============================================================
-- 11. ORDER ITEMS
-- ============================================================
CREATE TABLE public.order_items (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id        uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    course_id       uuid NOT NULL REFERENCES public.courses(id) ON DELETE RESTRICT,
    course_title    text NOT NULL,
    unit_price      numeric(10,2) NOT NULL CHECK (unit_price >= 0),
    quantity        int NOT NULL DEFAULT 1 CHECK (quantity > 0),
    line_total      numeric(10,2) NOT NULL CHECK (line_total >= 0)
);

-- ============================================================
-- 12. RESOURCES (Blog/Articles)
-- ============================================================
CREATE TABLE public.resources (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           text NOT NULL,
    slug            text UNIQUE NOT NULL,
    excerpt         text NOT NULL,
    content         text NOT NULL,
    category        text NOT NULL CHECK (category IN ('SQL Tips', 'PL/SQL', 'Performance', 'Career', 'News', 'Tutorials')),
    author_id       uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    author_name     text NOT NULL,
    read_time       text,
    tags            text[] DEFAULT '{}',
    featured        boolean DEFAULT false,
    published_at    timestamptz,
    status          text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    created_at      timestamptz DEFAULT now(),
    updated_at      timestamptz DEFAULT now()
);

CREATE INDEX idx_resources_status ON public.resources(status);
CREATE INDEX idx_resources_category ON public.resources(category);

-- ============================================================
-- 13. FAQ
-- ============================================================
CREATE TABLE public.faq (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    question        text NOT NULL,
    answer          text NOT NULL,
    category        text NOT NULL,
    sort_order      int NOT NULL DEFAULT 0,
    is_published    boolean DEFAULT true,
    created_at      timestamptz DEFAULT now()
);

-- ============================================================
-- 14. ANALYTICS
-- ============================================================
CREATE TABLE public.analytics (
    id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type      text NOT NULL CHECK (event_type IN ('enrollment', 'purchase', 'course_complete', 'lesson_complete', 'certificate_issued', 'internship_apply')),
    user_id         uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    course_id       uuid REFERENCES public.courses(id) ON DELETE SET NULL,
    internship_id   uuid REFERENCES public.internships(id) ON DELETE SET NULL,
    amount          numeric(10,2) CHECK (amount IS NULL OR amount >= 0),
    currency        text DEFAULT 'USD',
    metadata        jsonb DEFAULT '{}',
    created_at      timestamptz DEFAULT now()
);

CREATE INDEX idx_analytics_event ON public.analytics(event_type);
CREATE INDEX idx_analytics_user ON public.analytics(user_id);
CREATE INDEX idx_analytics_created ON public.analytics(created_at);

-- ============================================================
-- ROW LEVEL SECURITY (RLS) — ENABLED ON ALL TABLES
-- ============================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.internships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.internship_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faq ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- SECURITY HELPER FUNCTIONS — WITH SAFE SEARCH_PATH
-- ============================================================

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    );
END;
$$;

CREATE OR REPLACE FUNCTION public.is_instructor()
RETURNS boolean
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role IN ('instructor', 'admin', 'super_admin')
    );
END;
$$;

CREATE OR REPLACE FUNCTION public.is_course_instructor(course_uuid uuid)
RETURNS boolean
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.courses
        WHERE id = course_uuid AND instructor_id = auth.uid()
    );
END;
$$;

-- ============================================================
-- COLUMN-LEVEL RESTRICTION TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION public.enforce_profile_update_restrictions()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NOT public.is_admin() THEN
        IF OLD.role IS DISTINCT FROM NEW.role THEN
            RAISE EXCEPTION 'Unauthorized: role can only be changed by an administrator';
        END IF;
        IF OLD.is_active IS DISTINCT FROM NEW.is_active THEN
            RAISE EXCEPTION 'Unauthorized: account status can only be changed by an administrator';
        END IF;
        IF OLD.email IS DISTINCT FROM NEW.email THEN
            RAISE EXCEPTION 'Unauthorized: email can only be changed by an administrator';
        END IF;
        IF OLD.id IS DISTINCT FROM NEW.id THEN
            RAISE EXCEPTION 'Unauthorized: user id cannot be changed';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enforce_profile_restrictions
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_profile_update_restrictions();

CREATE OR REPLACE FUNCTION public.enforce_internship_app_restrictions()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NOT public.is_admin() THEN
        IF OLD.status IS DISTINCT FROM NEW.status THEN
            RAISE EXCEPTION 'Unauthorized: application status can only be changed by an administrator';
        END IF;
        IF OLD.notes IS DISTINCT FROM NEW.notes THEN
            RAISE EXCEPTION 'Unauthorized: admin notes can only be changed by an administrator';
        END IF;
        IF OLD.user_id IS DISTINCT FROM NEW.user_id THEN
            RAISE EXCEPTION 'Unauthorized: user_id cannot be changed';
        END IF;
        IF OLD.internship_id IS DISTINCT FROM NEW.internship_id THEN
            RAISE EXCEPTION 'Unauthorized: internship_id cannot be changed';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enforce_internship_app_restrictions
    BEFORE UPDATE ON public.internship_applications
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_internship_app_restrictions();

CREATE OR REPLACE FUNCTION public.enforce_enrollment_restrictions()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NOT public.is_admin() THEN
        IF OLD.status IS DISTINCT FROM NEW.status THEN
            RAISE EXCEPTION 'Unauthorized: enrollment status can only be changed by server logic or administrators';
        END IF;
        IF OLD.progress_pct IS DISTINCT FROM NEW.progress_pct THEN
            RAISE EXCEPTION 'Unauthorized: enrollment progress is computed automatically and cannot be changed directly';
        END IF;
        IF OLD.completed_at IS DISTINCT FROM NEW.completed_at THEN
            RAISE EXCEPTION 'Unauthorized: completion date is set automatically by the system';
        END IF;
        IF OLD.user_id IS DISTINCT FROM NEW.user_id THEN
            RAISE EXCEPTION 'Unauthorized: user_id cannot be changed';
        END IF;
        IF OLD.course_id IS DISTINCT FROM NEW.course_id THEN
            RAISE EXCEPTION 'Unauthorized: course_id cannot be changed';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enforce_enrollment_restrictions
    BEFORE UPDATE ON public.enrollments
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_enrollment_restrictions();

CREATE OR REPLACE FUNCTION public.enforce_order_restrictions()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NOT public.is_admin() THEN
        IF OLD.status IS DISTINCT FROM NEW.status THEN
            RAISE EXCEPTION 'Unauthorized: order status can only be changed by payment webhooks or administrators';
        END IF;
        IF OLD.payment_intent_id IS DISTINCT FROM NEW.payment_intent_id THEN
            RAISE EXCEPTION 'Unauthorized: payment information is system-managed only';
        END IF;
        IF OLD.payment_method IS DISTINCT FROM NEW.payment_method THEN
            RAISE EXCEPTION 'Unauthorized: payment information is system-managed only';
        END IF;
        IF OLD.payment_provider IS DISTINCT FROM NEW.payment_provider THEN
            RAISE EXCEPTION 'Unauthorized: payment information is system-managed only';
        END IF;
        IF OLD.total_amount IS DISTINCT FROM NEW.total_amount THEN
            RAISE EXCEPTION 'Unauthorized: order amount is set at creation time by the system';
        END IF;
        IF OLD.tax_amount IS DISTINCT FROM NEW.tax_amount THEN
            RAISE EXCEPTION 'Unauthorized: tax amount is system-managed only';
        END IF;
        IF OLD.discount_amount IS DISTINCT FROM NEW.discount_amount THEN
            RAISE EXCEPTION 'Unauthorized: discount amount is system-managed only';
        END IF;
        IF OLD.coupon_code IS DISTINCT FROM NEW.coupon_code THEN
            RAISE EXCEPTION 'Unauthorized: coupon code is system-managed only';
        END IF;
        IF OLD.metadata IS DISTINCT FROM NEW.metadata THEN
            RAISE EXCEPTION 'Unauthorized: order metadata is system-managed only';
        END IF;
        IF OLD.receipt_url IS DISTINCT FROM NEW.receipt_url THEN
            RAISE EXCEPTION 'Unauthorized: receipt information is system-managed only';
        END IF;
        IF OLD.invoice_url IS DISTINCT FROM NEW.invoice_url THEN
            RAISE EXCEPTION 'Unauthorized: invoice information is system-managed only';
        END IF;
        IF OLD.user_id IS DISTINCT FROM NEW.user_id THEN
            RAISE EXCEPTION 'Unauthorized: user_id cannot be changed';
        END IF;
        IF OLD.order_number IS DISTINCT FROM NEW.order_number THEN
            RAISE EXCEPTION 'Unauthorized: order_number cannot be changed';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enforce_order_restrictions
    BEFORE UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_order_restrictions();

CREATE OR REPLACE FUNCTION public.enforce_lesson_progress_restrictions()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.user_id != auth.uid() AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: you may only modify your own lesson progress';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enforce_lesson_progress_restrictions
    BEFORE INSERT OR UPDATE ON public.lesson_progress
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_lesson_progress_restrictions();

CREATE OR REPLACE FUNCTION public.enforce_certificate_restrictions()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: certificates are system-managed and cannot be modified by users';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enforce_certificate_restrictions
    BEFORE UPDATE ON public.certificates
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_certificate_restrictions();

-- ============================================================
-- RLS POLICIES — VALIDATED SYNTAX
-- ============================================================

-- ─── PROFILES ───
CREATE POLICY "Profiles: read own" ON public.profiles
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Profiles: admin read all" ON public.profiles
    FOR SELECT USING (public.is_admin());
CREATE POLICY "Profiles: own update" ON public.profiles
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "Profiles: admin write" ON public.profiles
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── COURSES ───
CREATE POLICY "Courses: public read active" ON public.courses
    FOR SELECT USING (status = 'active');
CREATE POLICY "Courses: admin all" ON public.courses
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Courses: instructor update own" ON public.courses
    FOR UPDATE USING (public.is_course_instructor(id))
    WITH CHECK (public.is_course_instructor(id));
CREATE POLICY "Courses: instructor delete own" ON public.courses
    FOR DELETE USING (public.is_course_instructor(id));

-- ─── LESSONS ───
CREATE POLICY "Lessons: read if access" ON public.lessons
    FOR SELECT USING (
        public.is_admin()
        OR EXISTS (SELECT 1 FROM public.enrollments
                   WHERE user_id = auth.uid() AND course_id = lessons.course_id)
        OR is_free_preview = true
    );
CREATE POLICY "Lessons: admin write" ON public.lessons
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Lessons: instructor write own course" ON public.lessons
    FOR ALL USING (public.is_course_instructor(lessons.course_id))
    WITH CHECK (public.is_course_instructor(lessons.course_id));

-- ─── QUIZZES ───
CREATE POLICY "Quizzes: read if access" ON public.quizzes
    FOR SELECT USING (
        public.is_admin()
        OR EXISTS (SELECT 1 FROM public.lessons l
                   JOIN public.enrollments e ON e.course_id = l.course_id
                   WHERE l.id = quizzes.lesson_id AND e.user_id = auth.uid())
    );
CREATE POLICY "Quizzes: admin write" ON public.quizzes
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Quizzes: instructor write own" ON public.quizzes
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.lessons l
                JOIN public.courses c ON c.id = l.course_id
                WHERE l.id = quizzes.lesson_id AND c.instructor_id = auth.uid())
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM public.lessons l
                JOIN public.courses c ON c.id = l.course_id
                WHERE l.id = quizzes.lesson_id AND c.instructor_id = auth.uid())
    );

-- ─── QUIZ QUESTIONS ───
CREATE POLICY "QuizQuestions: read if access" ON public.quiz_questions
    FOR SELECT USING (
        public.is_admin()
        OR EXISTS (SELECT 1 FROM public.quizzes q
                   JOIN public.lessons l ON l.id = q.lesson_id
                   JOIN public.enrollments e ON e.course_id = l.course_id
                   WHERE q.id = quiz_questions.quiz_id AND e.user_id = auth.uid())
    );
CREATE POLICY "QuizQuestions: admin write" ON public.quiz_questions
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "QuizQuestions: instructor write own" ON public.quiz_questions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.quizzes q
                JOIN public.lessons l ON l.id = q.lesson_id
                JOIN public.courses c ON c.id = l.course_id
                WHERE q.id = quiz_questions.quiz_id AND c.instructor_id = auth.uid())
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM public.quizzes q
                JOIN public.lessons l ON l.id = q.lesson_id
                JOIN public.courses c ON c.id = l.course_id
                WHERE q.id = quiz_questions.quiz_id AND c.instructor_id = auth.uid())
    );

-- ─── ENROLLMENTS ───
-- Students may NOT create their own enrollment. Server-side only after payment.
CREATE POLICY "Enrollments: read own" ON public.enrollments
    FOR SELECT USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Enrollments: admin all" ON public.enrollments
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── LESSON PROGRESS ───
-- FIXED: Split into two valid policies (INSERT has no USING clause, only WITH CHECK)
CREATE POLICY "LessonProgress: read own" ON public.lesson_progress
    FOR SELECT USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "LessonProgress: insert own" ON public.lesson_progress
    FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "LessonProgress: update own" ON public.lesson_progress
    FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- NOTE: No DELETE policy — students may not delete their own progress.

-- ─── CERTIFICATES ───
CREATE POLICY "Certificates: read own" ON public.certificates
    FOR SELECT USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Certificates: admin write" ON public.certificates
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── INTERNSHIPS ───
CREATE POLICY "Internships: public read open" ON public.internships
    FOR SELECT USING (status = 'open' OR public.is_admin());
CREATE POLICY "Internships: admin all" ON public.internships
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── INTERNSHIP APPLICATIONS ───
CREATE POLICY "Applications: read own" ON public.internship_applications
    FOR SELECT USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Applications: insert own" ON public.internship_applications
    FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Applications: update own" ON public.internship_applications
    FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Applications: admin all" ON public.internship_applications
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── ORDERS ───
-- Students may read only. No INSERT/UPDATE/DELETE by users.
CREATE POLICY "Orders: read own" ON public.orders
    FOR SELECT USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Orders: admin all" ON public.orders
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── ORDER ITEMS ───
CREATE POLICY "OrderItems: read own" ON public.order_items
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.orders o
                WHERE o.id = order_items.order_id
                AND (o.user_id = auth.uid() OR public.is_admin()))
    );
CREATE POLICY "OrderItems: admin all" ON public.order_items
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── RESOURCES ───
CREATE POLICY "Resources: public read published" ON public.resources
    FOR SELECT USING (status = 'published' OR public.is_admin());
CREATE POLICY "Resources: admin all" ON public.resources
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Resources: instructor write own" ON public.resources
    FOR ALL USING (author_id = auth.uid() AND public.is_instructor())
    WITH CHECK (author_id = auth.uid() AND public.is_instructor());

-- ─── FAQ ───
CREATE POLICY "FAQ: public read published" ON public.faq
    FOR SELECT USING (is_published = true OR public.is_admin());
CREATE POLICY "FAQ: admin all" ON public.faq
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── ANALYTICS ───
-- Admin-only. No public read. No client insert.
CREATE POLICY "Analytics: admin read" ON public.analytics
    FOR SELECT USING (public.is_admin());
CREATE POLICY "Analytics: admin write" ON public.analytics
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ============================================================
-- TIMESTAMP AUTO-UPDATE TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER courses_updated_at BEFORE UPDATE ON public.courses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER lessons_updated_at BEFORE UPDATE ON public.lessons
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER internships_updated_at BEFORE UPDATE ON public.internships
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER orders_updated_at BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER resources_updated_at BEFORE UPDATE ON public.resources
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER internship_applications_updated_at BEFORE UPDATE ON public.internship_applications
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- TRIGGER: Auto-create profile on auth signup (role = student)
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        'student'
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- TRIGGER: Auto-update course students_count on enrollment change
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_course_students_count()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.courses SET students_count = students_count + 1 WHERE id = NEW.course_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.courses SET students_count = students_count - 1 WHERE id = OLD.course_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER enrollment_count_trigger
    AFTER INSERT OR DELETE ON public.enrollments
    FOR EACH ROW EXECUTE FUNCTION public.update_course_students_count();

-- ============================================================
-- TRIGGER: Auto-update enrollment progress from lesson_progress
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_enrollment_progress()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    total_lessons int;
    completed_lessons int;
    course_id_var uuid;
    user_id_var uuid;
BEGIN
    IF TG_OP = 'DELETE' THEN
        course_id_var := OLD.course_id;
        user_id_var := OLD.user_id;
    ELSE
        course_id_var := NEW.course_id;
        user_id_var := NEW.user_id;
    END IF;

    SELECT COUNT(*) INTO total_lessons FROM public.lessons WHERE course_id = course_id_var;
    SELECT COUNT(*) INTO completed_lessons FROM public.lesson_progress
    WHERE course_id = course_id_var AND user_id = user_id_var AND is_completed = true;

    IF total_lessons > 0 THEN
        UPDATE public.enrollments
        SET progress_pct = LEAST(100, ROUND((completed_lessons::numeric / total_lessons) * 100)),
            status = CASE WHEN completed_lessons = total_lessons THEN 'completed' ELSE status END,
            completed_at = CASE WHEN completed_lessons = total_lessons THEN COALESCE(completed_at, now()) ELSE completed_at END
        WHERE user_id = user_id_var AND course_id = course_id_var;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER lesson_progress_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.lesson_progress
    FOR EACH ROW EXECUTE FUNCTION public.update_enrollment_progress();

-- ============================================================
-- TRIGGER: Auto-issue certificate on course completion
-- ============================================================

CREATE OR REPLACE FUNCTION public.auto_issue_certificate()
RETURNS TRIGGER
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    cert_num text;
    existing_count int;
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        SELECT COUNT(*) INTO existing_count FROM public.certificates
        WHERE user_id = NEW.user_id AND course_id = NEW.course_id;

        IF existing_count = 0 THEN
            cert_num := 'OP-' || to_char(now(), 'YYYY') || '-' || LPAD(
                (SELECT COUNT(*) + 1 FROM public.certificates)::text, 5, '0'
            );
            INSERT INTO public.certificates (user_id, course_id, certificate_number, status)
            VALUES (NEW.user_id, NEW.course_id, cert_num, 'active');
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER auto_certificate_trigger
    AFTER UPDATE ON public.enrollments
    FOR EACH ROW WHEN (NEW.status = 'completed' AND OLD.status != 'completed')
    EXECUTE FUNCTION public.auto_issue_certificate();
