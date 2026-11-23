-- Run this once in Supabase: SQL Editor > New query > paste > Run

create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  summary text not null,
  tech text[] not null default '{}',
  github_url text,
  live_url text,
  image_url text,
  figma_url text,
  status text default 'Completed',
  featured boolean not null default false,
  sort_order int not null default 100,
  created_at timestamptz not null default now()
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 100),
  email text not null check (char_length(email) between 3 and 200),
  message text not null check (char_length(message) between 1 and 2000),
  created_at timestamptz not null default now()
);

create table if not exists cv_downloads (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now()
);

-- Row Level Security: visitors can read projects and insert messages / downloads.
-- Nobody using the anon key can read messages or edit projects.
alter table projects enable row level security;
alter table messages enable row level security;
alter table cv_downloads enable row level security;

create policy "Anyone can read projects" on projects for select to anon, authenticated using (true);
create policy "Anyone can send a message" on messages for insert to anon, authenticated with check (true);
create policy "Anyone can log a CV download" on cv_downloads for insert to anon, authenticated with check (true);

-- Public bucket for your CV. Upload a file named cv.pdf in Storage > cv.
insert into storage.buckets (id, name, public) values ('cv', 'cv', true) on conflict (id) do nothing;

insert into storage.buckets (id, name, public) values ('project-images', 'project-images', true) on conflict (id) do nothing;

-- Starter projects (edit or delete these in Table Editor)
insert into projects (title, summary, tech, github_url, status, featured, sort_order) values
('Student Enrollment System', 'ASP.NET Core MVC application for managing student enrollment, with role-based access for users and administrators.', '{C#,ASP.NET Core,Entity Framework,SQL}', '', 'Completed', false, 1),
('Skool-Comm', 'Websites for a primary school: behavioural points, parent communication and Attendance recording.', '{JavaScript,Supabase,Flutter,Dart,ASP.NET MVC,C#,HTML,CSS}', '', 'Completed', false, 2),
('Portfolio Website', 'This site. A static front end with a Supabase back end for projects, contact messages, CV downloads and email alerts.', '{JavaScript,Supabase,PostgreSQL,HTML,CSS}', '', 'Live', false, 3),
('Transport Registration App', 'Two Flutter apps (rider and staff) sharing one database to replace a manual transport registration process.', '{Flutter,Dart,Supabase}', '', 'Concept', false, 4),
('Skool-Comm UI Design', 'Web interface design for a primary school: behavioural points, parent communication and the database design behind them.', '{Figma,UI/UX,CSS}', '', 'Design', false, 5);
