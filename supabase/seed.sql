-- ============================================================
-- OraclePath — Development Demo Seed Data
-- Parent: Ervion Technologies
-- This file is for LOCAL DEVELOPMENT and PREVIEW only.
-- Do NOT run in production environments.
--
-- Seed data includes: sample courses, internships, resources, FAQ.
-- All business metrics (student counts, ratings, company names,
-- stipend figures, deadlines) are synthetic for development purposes.
-- ============================================================

-- ============================================================
-- Seed sample courses (only if table is empty)
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.courses LIMIT 1) THEN
        INSERT INTO public.courses (id, title, subtitle, slug, description, level, duration, lessons_count, rating, price, original_price, tags, topics, instructor_name, students_count, featured, status)
        VALUES
        ('c-1-00000000-0000-0000-0000-000000000001', 'Oracle SQL Fundamentals', 'From Zero to Hero in Database Querying', 'oracle-sql-fundamentals', 'Master the art of querying Oracle databases with hands-on projects.', 'Beginner', '8 weeks', 64, 4.9, 199, 349, ARRAY['SQL', 'Database', 'Querying'], ARRAY['SELECT statements', 'JOINs', 'Aggregate functions', 'Subqueries', 'DML', 'DDL'], 'Dr. Maria Chen', 3840, true, 'active'),
        ('c-2-00000000-0000-0000-0000-000000000002', 'PL/SQL Programming Masterclass', 'Build Powerful Database Applications', 'plsql-masterclass', 'Unlock the full power of Oracle procedural language.', 'Intermediate', '10 weeks', 80, 4.8, 249, 399, ARRAY['PL/SQL', 'Procedural', 'Development'], ARRAY['Block structure', 'Control structures', 'Cursors', 'Stored procedures', 'Triggers', 'Packages', 'Exception handling'], 'James OConnell', 2150, true, 'active'),
        ('c-3-00000000-0000-0000-0000-000000000003', 'Advanced SQL Tuning & Optimization', 'Make Your Queries Lightning Fast', 'advanced-sql-tuning', 'Learn execution plans, indexing, hints, and partitioning.', 'Advanced', '6 weeks', 48, 4.9, 299, 449, ARRAY['Performance', 'Optimization', 'Tuning'], ARRAY['Execution plans', 'Index design', 'Query rewrite', 'Partitioning', 'Optimizer statistics', 'Case studies'], 'Rajesh Patel', 1280, false, 'active'),
        ('c-4-00000000-0000-0000-0000-000000000004', 'Oracle APEX Low-Code Development', 'Build Web Apps Without Traditional Coding', 'oracle-apex-development', 'Create enterprise web applications using Oracle APEX.', 'Intermediate', '8 weeks', 56, 4.7, 229, 379, ARRAY['APEX', 'Low-Code', 'Web Apps'], ARRAY['APEX architecture', 'Interactive grids', 'Dynamic actions', 'REST APIs', 'Authentication', 'Deployment'], 'Lisa Zhang', 1650, false, 'active'),
        ('c-5-00000000-0000-0000-0000-000000000005', 'Oracle DBA Essentials', 'Master Database Administration', 'oracle-dba-essentials', 'Install, configure, secure, and maintain Oracle databases.', 'Intermediate', '12 weeks', 96, 4.8, 349, 499, ARRAY['DBA', 'Administration', 'Infrastructure'], ARRAY['Installation', 'User management', 'Backup & recovery', 'RAC & Data Guard', 'Performance monitoring', 'Cloud'], 'Ahmed Hassan', 980, false, 'active'),
        ('c-6-00000000-0000-0000-0000-000000000006', 'SQL for Data Analytics', 'Transform Data into Insights', 'sql-data-analytics', 'Leverage Oracle analytic functions for complex business problems.', 'Intermediate', '6 weeks', 42, 4.8, 189, 299, ARRAY['Analytics', 'Window Functions', 'BI'], ARRAY['Window functions', 'Running totals', 'Ranking', 'Pivot operations', 'Pattern matching', 'Time-series'], 'Dr. Maria Chen', 1890, false, 'active');
    END IF;
END;
$$;

-- ============================================================
-- Seed sample internships (only if table is empty)
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.internships LIMIT 1) THEN
        INSERT INTO public.internships (id, title, company, location, type, duration, stipend, description, requirements, skills, openings, deadline, featured, status)
        VALUES
        ('i-1-00000000-0000-0000-0000-000000000001', 'Oracle Database Developer Intern', 'DataFlow Solutions', 'Remote', 'Remote', '3 months', '$2,500/month', 'Work on real enterprise database projects, developing stored procedures, functions, and optimizing queries for a fintech platform serving 2M+ users.', ARRAY['Strong SQL & PL/SQL knowledge', 'Basic understanding of database design', 'Problem-solving mindset', 'Available 20+ hours/week'], ARRAY['SQL', 'PL/SQL', 'Oracle 19c', 'Git'], 4, '2025-07-15', true, 'open'),
        ('i-2-00000000-0000-0000-0000-000000000002', 'PL/SQL Engineer Intern', 'Oracle Systems Inc.', 'Austin, TX', 'Hybrid', '6 months', '$3,200/month', 'Join the core database team at Oracle. Contribute to package development, API design, and performance optimization for Oracle Cloud Infrastructure services.', ARRAY['Completed PL/SQL coursework or equivalent', 'Understanding of Oracle architecture', 'Familiarity with Linux environments', 'Pursuing CS/IT/related degree'], ARRAY['PL/SQL', 'Oracle Cloud', 'Linux', 'Performance Tuning'], 2, '2025-06-30', true, 'open'),
        ('i-3-00000000-0000-0000-0000-000000000003', 'Oracle APEX Developer Intern', 'AppNexus Technologies', 'Remote', 'Remote', '4 months', '$2,200/month', 'Build low-code enterprise applications for healthcare clients. Work on dashboards, reporting modules, and interactive data entry forms using Oracle APEX.', ARRAY['Knowledge of Oracle APEX or similar low-code platforms', 'HTML/CSS/JavaScript basics', 'SQL proficiency required', 'Portfolio or project examples preferred'], ARRAY['Oracle APEX', 'SQL', 'JavaScript', 'REST APIs'], 3, '2025-08-01', false, 'open'),
        ('i-4-00000000-0000-0000-0000-000000000004', 'Junior Oracle DBA Intern', 'GlobalBank Financial', 'New York, NY', 'On-site', '6 months', '$3,500/month', 'Learn enterprise database administration from senior DBAs. Monitor production databases, assist with backup procedures, and contribute to migration projects.', ARRAY['Oracle SQL/PL-SQL certification or equivalent experience', 'Basic Linux command-line knowledge', 'Strong attention to detail', 'Willingness to work on-call rotations'], ARRAY['Oracle DBA', 'Linux', 'Backup/Recovery', 'Shell Scripting'], 2, '2025-07-20', false, 'open'),
        ('i-5-00000000-0000-0000-0000-000000000005', 'SQL Data Analyst Intern', 'RetailMax Analytics', 'Chicago, IL', 'Hybrid', '3 months', '$2,800/month', 'Analyze retail sales data using advanced SQL techniques. Create reports, dashboards, and predictive models to support business decision-making across 500+ stores.', ARRAY['Advanced SQL & window functions knowledge', 'Data visualization interest', 'Statistical thinking', 'Business acumen'], ARRAY['SQL', 'Analytics', 'Oracle BI', 'Excel/Python'], 5, '2025-08-15', false, 'open'),
        ('i-6-00000000-0000-0000-0000-000000000006', 'ETL/Database Integration Intern', 'CloudSync Data', 'Remote', 'Remote', '4 months', '$2,600/month', 'Design and implement data pipelines between Oracle databases and cloud data warehouses. Work with Oracle Data Integrator and modern cloud ETL tools.', ARRAY['SQL & PL/SQL strong foundation', 'Interest in data engineering', 'Cloud concepts (AWS/Azure/GCP)', 'Python or Java basics'], ARRAY['SQL', 'PL/SQL', 'ETL', 'Oracle Data Integrator', 'Python'], 3, '2025-09-01', false, 'open');
    END IF;
END;
$$;

-- ============================================================
-- Seed sample resources (only if table is empty)
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.resources LIMIT 1) THEN
        INSERT INTO public.resources (title, slug, excerpt, content, category, author_name, read_time, tags, featured, status, published_at)
        VALUES
        ('10 Advanced SQL Window Functions Every Oracle Developer Should Know', 'advanced-sql-window-functions', 'Window functions are the most powerful feature in Oracle SQL. Learn how to use ROW_NUMBER, RANK, DENSE_RANK, LEAD, LAG, and more for real-world analytics.', 'Window functions allow you to perform calculations across a set of rows related to the current row. Unlike aggregate functions, they do not collapse rows. Use the OVER() clause to define the window...', 'SQL Tips', 'Dr. Maria Chen', '8 min', ARRAY['Window Functions', 'SQL', 'Analytics'], true, 'published', now()),
        ('PL/SQL Package Design: Best Practices from Oracle Architects', 'plsql-package-design-best-practices', 'Learn how to structure PL/SQL packages for maintainability, performance, and security from engineers who have built Oracle Cloud infrastructure.', 'PL/SQL packages are the cornerstone of modular Oracle development. Group related procedures and functions together. Use the package specification for the public interface...', 'PL/SQL', 'James OConnell', '12 min', ARRAY['PL/SQL', 'Packages', 'Architecture'], true, 'published', now()),
        ('Execution Plan Deep Dive: How the Oracle Optimizer Works', 'execution-plan-deep-dive', 'Understanding execution plans is the key to SQL performance tuning. This article explains every operation you will see in an EXPLAIN PLAN output.', 'The Oracle optimizer evaluates multiple execution plans and chooses the one with the lowest estimated cost. An execution plan shows operations like TABLE ACCESS FULL, INDEX RANGE SCAN...', 'Performance', 'Rajesh Patel', '15 min', ARRAY['Performance', 'Tuning', 'Execution Plans'], true, 'published', now()),
        ('From Bootcamp to Oracle DBA: A Career Roadmap', 'bootcamp-to-oracle-dba', 'A step-by-step guide for transitioning into Oracle database administration, including certifications, skills, and salary expectations.', 'The path to becoming an Oracle DBA starts with mastering SQL and PL/SQL fundamentals...', 'Career', 'Ahmed Hassan', '10 min', ARRAY['Career', 'DBA', 'Certification'], false, 'published', now()),
        ('Oracle Autonomous Database: What Developers Need to Know', 'oracle-autonomous-database', 'Oracle autonomous database is changing how developers work. Here is what you need to know to stay relevant.', 'Oracle Autonomous Database handles tuning, patching, backup, and scaling automatically...', 'News', 'Lisa Zhang', '7 min', ARRAY['Autonomous DB', 'Cloud', 'Oracle'], false, 'published', now()),
        ('Building a Real-Time Analytics Dashboard with Oracle SQL and APEX', 'real-time-analytics-dashboard', 'Step-by-step tutorial for creating a live analytics dashboard using Oracle analytic SQL and Oracle APEX low-code platform.', 'Combine Oracle SQL analytic functions with APEX interactive grids to build powerful dashboards...', 'Tutorials', 'Dr. Maria Chen', '20 min', ARRAY['APEX', 'Analytics', 'Tutorial'], false, 'published', now());
    END IF;
END;
$$;

-- ============================================================
-- Seed FAQ entries (only if table is empty)
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.faq LIMIT 1) THEN
        INSERT INTO public.faq (question, answer, category, sort_order)
        VALUES
        ('What is OraclePath and who owns it?', 'OraclePath is a specialized learning platform under Ervion Technologies, dedicated exclusively to Oracle SQL and PL/SQL education.', 'General', 1),
        ('Why does OraclePath focus only on Oracle SQL and PL/SQL?', 'Oracle is the world most widely deployed enterprise database. OraclePath specializes exclusively in Oracle technologies because we believe depth beats breadth.', 'General', 2),
        ('How do I enroll in a course?', 'Browse our Courses page, select the course you want, and complete secure checkout. Once enrolled, you get immediate lifetime access.', 'Courses', 1),
        ('Do I need prior database experience?', 'Not for our beginner courses. Oracle SQL Fundamentals assumes zero prior knowledge.', 'Courses', 2),
        ('How do the hands-on labs work?', 'Every course includes interactive SQL sandboxes running real Oracle 19c databases. You write, execute, and debug queries directly in your browser.', 'Courses', 3),
        ('How does the internship program work?', 'Top-performing students are eligible for guaranteed internship placements with our partner companies.', 'Internships', 1),
        ('Are internships paid?', 'Yes, all internships listed on OraclePath are paid positions. Stipends range from $2,200 to $3,500 per month.', 'Internships', 2),
        ('What payment methods are accepted?', 'We accept all major credit cards, PayPal, and bank transfers. All payments are processed through PCI-compliant gateways.', 'Payments', 1),
        ('Do you offer refunds?', 'Yes, we offer a 14-day no-questions-asked refund policy for all courses.', 'Payments', 2),
        ('Do you issue certificates?', 'Yes, upon completing a course with 100% progress, you receive a verified digital certificate with a unique certificate number.', 'Certificates', 1),
        ('Do you help with Oracle certification exams?', 'Absolutely. Our courses are designed to prepare you for Oracle certification exams (1Z0-071, 1Z0-149, etc.).', 'Certificates', 2),
        ('Is there a community for students?', 'Yes, all students get access to our private community forum and Discord server.', 'Platform', 1);
    END IF;
END;
$$;
