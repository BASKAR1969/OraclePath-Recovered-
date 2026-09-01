# OraclePath Source Changes

## Database

| File | Change | Reason | Status |
|------|--------|--------|--------|
| `supabase/migrations/001_initial_schema.sql` | Created production schema (15 tables, 24 indexes, 24 FKs, 41 RLS policies, 14 security functions, 16 triggers) | Production database structure | COMPLETED |
| `supabase/migrations/001_initial_schema.sql` | Hardened RLS: removed public profile read, removed user enrollment insert, removed user order insert, added column-level trigger restrictions | Prevent privilege escalation, payment fraud, data poisoning | COMPLETED |
| `supabase/migrations/001_initial_schema.sql` | Fixed invalid `FOR INSERT, UPDATE USING` combined syntax — split into separate INSERT and UPDATE policies | PostgreSQL syntax validity | COMPLETED |
| `supabase/migrations/001_initial_schema.sql` | Removed all demo seed INSERTs (moved to seed.sql) | Production schema must not contain fake data | COMPLETED |
| `supabase/seed.sql` | Created development-only seed file with courses, internships, resources, FAQ | Separated demo data from production schema | COMPLETED |

## Application Core

| File | Change | Reason | Status |
|------|--------|--------|--------|
| `src/main.tsx` | Created React 19 entry point with StrictMode, BrowserRouter | Application bootstrap | COMPLETED |
| `src/App.tsx` | Created main app with 17 routes, AuthProvider, Navbar, Footer, ProtectedRoute | Route configuration | COMPLETED |
| `src/index.css` | Configured Tailwind v4 with OraclePath theme (oracle-red, dark-bg, dark-surface, etc.) | Brand styling | COMPLETED |
| `index.html` | Set title to "OraclePath — Master SQL & PL/SQL", added Inter + JetBrains Mono fonts | SEO and branding | COMPLETED |
| `public/favicon.svg` | Created OraclePath "OP" monogram favicon in Oracle Red | Brand identity | COMPLETED |

## Supabase & Data Layer

| File | Change | Reason | Status |
|------|--------|--------|--------|
| `src/lib/supabase.ts` | Created real Supabase client with auth auto-refresh, session persistence, realtime | Production Supabase connection | COMPLETED |
| `src/lib/env.ts` | Created environment configuration (VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, VITE_USE_MOCK_DB) | Environment detection | COMPLETED |
| `src/lib/errors.ts` | Created error framework with 18 codes, wrapError, ServiceResult, isRetryableError | Structured error handling | COMPLETED |
| `src/lib/mockSupabase.ts` | Created mock Supabase client with localStorage persistence, auth simulation, PostgREST query builder, seed data | Development/preview testing | COMPLETED |
| `src/lib/mockSupabase.ts` | Hardened localStorage access with try/catch + _memoryStore fallback for sandboxed environments | Fix blank screen in iframe previews | COMPLETED |
| `src/lib/supabaseTypes.ts` | Created TypeScript interfaces for Supabase client abstraction | Type-safe mock implementation | COMPLETED |
| `src/services/adapter.ts` | Created service adapter routing to real Supabase or mock (dev-only, explicit opt-in) | Single bridge for data access | COMPLETED |
| `src/services/auth.ts` | Created auth service (signUp, signIn, signOut, getUser, updateUser, resetPassword) | Authentication operations | COMPLETED |
| `src/services/courses.ts` | Created course service (getAll, getById, create, update, delete, getLessons, getByInstructor) | Course data operations | COMPLETED |
| `src/services/enrollments.ts` | Created enrollment service (getByUser, getByCourse, create, getProgress, updateProgress, getAll) | Enrollment & progress operations | COMPLETED |
| `src/services/students.ts` | Created student service (getAllProfiles, getByIds) | Student profile operations | COMPLETED |
| `src/services/internships.ts` | Created internship service (getAll, getById, create, update, delete, getApplications, createApplication) | Internship operations | COMPLETED |
| `src/services/certificates.ts` | Created certificate service (getByUser, create, getAll, generateNumber) | Certificate operations | COMPLETED |
| `src/services/orders.ts` | Created order service (getByUser, create, getAll, generateOrderNumber) | Order/payment operations | COMPLETED |
| `src/services/index.ts` | Created service registry exporting all services + adapter utilities | Centralized service exports | COMPLETED |

## Types & Context

| File | Change | Reason | Status |
|------|--------|--------|--------|
| `src/types/domain.ts` | Created 22 domain types (Profile, Course, Enrollment, Order, Certificate, etc.) | Type-safe data layer | COMPLETED |
| `src/context/AuthContext.tsx` | Created AuthProvider with useAuth hook, profile loading, role-based access | Authentication state management | COMPLETED |
| `src/components/ProtectedRoute.tsx` | Created role-based route guard (student/instructor/admin) | Route security | COMPLETED |

## UI Components & Pages

| File | Change | Reason | Status |
|------|--------|--------|--------|
| `src/components/Navbar.tsx` | Created responsive navbar with OraclePath branding, role-based menu, SupabaseStatus | Navigation | COMPLETED |
| `src/components/Footer.tsx` | Created footer with Ervion Technologies parent banner, links, contact | Site footer | COMPLETED |
| `src/components/Hero.tsx` | Created hero section with "OraclePath — An Ervion Technologies Company" | Landing hero | COMPLETED |
| `src/components/Features.tsx` | Created features grid highlighting Oracle SQL & PL/SQL specialization | Value proposition | COMPLETED |
| `src/components/FeaturedCourses.tsx` | Created featured courses carousel with 6 Oracle courses | Course showcase | COMPLETED |
| `src/components/Stats.tsx` | Created statistics section with course/internship/student counts | Social proof | COMPLETED |
| `src/components/Testimonials.tsx` | Created student testimonials | Social proof | COMPLETED |
| `src/components/CTA.tsx` | Created call-to-action section | Conversion | COMPLETED |
| `src/components/SupabaseStatus.tsx` | Created connection status indicator (real/mock/dead) | Diagnostics | COMPLETED |
| `src/components/StripeCheckout.tsx` | Created payment checkout placeholder | Payment flow | COMPLETED |
| `src/pages/Home.tsx` | Created homepage composing all landing sections | Landing page | COMPLETED |
| `src/pages/About.tsx` | Created about page with Ervion Technologies story | Company story | COMPLETED |
| `src/pages/Courses.tsx` | Created course listing with filters, search, pagination | Course catalog | COMPLETED |
| `src/pages/CourseDetails.tsx` | Created course detail with enrollment, payment, instructor info | Course detail | COMPLETED |
| `src/pages/CoursePlayer.tsx` | Created LMS course player with lessons, video, quiz, SQL sandbox | Learning environment | COMPLETED |
| `src/pages/Internships.tsx` | Created internship listing with filters, search | Opportunity catalog | COMPLETED |
| `src/pages/InternshipDetails.tsx` | Created internship detail with application workflow | Application flow | COMPLETED |
| `src/pages/Resources.tsx` | Created blog/resources listing with categories | Content hub | COMPLETED |
| `src/pages/FAQ.tsx` | Created FAQ with categories, search, 15 questions | Support | COMPLETED |
| `src/pages/Pricing.tsx` | Created pricing page with 3 plans (Starter/Pro/Enterprise) | Pricing | COMPLETED |
| `src/pages/Contact.tsx` | Created contact form with validation | Contact | COMPLETED |
| `src/pages/Login.tsx` | Created login with demo credentials display | Authentication | COMPLETED |
| `src/pages/Register.tsx` | Created registration form | Authentication | COMPLETED |
| `src/pages/ForgotPassword.tsx` | Created password reset flow | Authentication | COMPLETED |
| `src/pages/StudentDashboard.tsx` | Created student dashboard (7 tabs: courses, progress, certificates, internships, applications, orders, settings) | Student workspace | COMPLETED |
| `src/pages/InstructorDashboard.tsx` | Created instructor dashboard (6 tabs: courses, students, analytics, earnings, content, settings) | Instructor workspace | COMPLETED |
| `src/pages/AdminDashboard.tsx` | Created admin dashboard (9 tabs: overview, users, courses, enrollments, internships, applications, orders, certificates, settings) | Admin workspace | COMPLETED |
| `src/hooks/useSupabaseStatus.ts` | Created hook for connection status checking | Diagnostics | COMPLETED |

## Data Files

| File | Change | Reason | Status |
|------|--------|--------|--------|
| `src/data/courses.ts` | Created 6 Oracle SQL/PL/SQL courses with metadata | Static course data | COMPLETED |
| `src/data/internships.ts` | Created 6 Oracle database internships with metadata | Static internship data | COMPLETED |
| `src/data/testimonials.ts` | Created 6 student testimonials | Social proof | COMPLETED |
| `src/data/faq.ts` | Created 15 FAQ items across 5 categories | Support content | COMPLETED |
| `src/data/resources.ts` | Created 6 articles/resources | Content | COMPLETED |
| `src/data/pricing.ts` | Created 3 pricing tiers with features | Pricing | COMPLETED |

## Configuration

| File | Change | Reason | Status |
|------|--------|--------|--------|
| `.env` | Added VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY placeholder, VITE_USE_MOCK_DB | Environment configuration | COMPLETED |
| `vite.config.ts` | Configured Vite with React, Tailwind, env prefix | Build configuration | COMPLETED |

## Agent Status System

| File | Change | Reason | Status |
|------|--------|--------|--------|
| `.agent-status/CURRENT_STATUS.md` | Created current status tracker | Observable agent state | COMPLETED |
| `.agent-status/ACTIVITY_LOG.md` | Created chronological activity log | Audit trail | COMPLETED |
| `.agent-status/CHANGES.md` | Created source changes registry | Change tracking | COMPLETED |
| `.agent-status/BLOCKERS.md` | Created blocker tracker | Issue tracking | COMPLETED |
| `.agent-status/TASK_STATE.json` | Created machine-readable state JSON | Programmatic access | COMPLETED |
