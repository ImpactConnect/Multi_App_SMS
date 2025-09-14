-- Add test data to verify sync functionality after fixing RLS policies
-- This migration adds sample data to schools, classes, subjects, and students tables

-- First, insert a test school
INSERT INTO schools (id, name, address, phone, email, is_active, created_at, updated_at) VALUES
('440e8400-e29b-41d4-a716-446655440001', 'Test Elementary School', '123 Education Street, Learning City', '+1-555-0123', 'admin@testelemschool.edu', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert test parent users
INSERT INTO users (id, email, first_name, last_name, phone_number, role, access_code, school_id, is_active, username, password) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'john.doe@email.com', 'John', 'Doe', '+1-555-0201', 'parent', 'PAR001', '440e8400-e29b-41d4-a716-446655440001', true, 'john.doe', '$2b$10$example.hash.for.password123'),
('550e8400-e29b-41d4-a716-446655440002', 'jane.smith@email.com', 'Jane', 'Smith', '+1-555-0202', 'parent', 'PAR002', '440e8400-e29b-41d4-a716-446655440001', true, 'jane.smith', '$2b$10$example.hash.for.password456'),
('550e8400-e29b-41d4-a716-446655440003', 'mike.johnson@email.com', 'Mike', 'Johnson', '+1-555-0203', 'parent', 'PAR003', '440e8400-e29b-41d4-a716-446655440001', true, 'mike.johnson', '$2b$10$example.hash.for.password789'),
('550e8400-e29b-41d4-a716-446655440004', 'sarah.wilson@email.com', 'Sarah', 'Wilson', '+1-555-0204', 'parent', 'PAR004', '440e8400-e29b-41d4-a716-446655440001', true, 'sarah.wilson', '$2b$10$example.hash.for.password012'),
('550e8400-e29b-41d4-a716-446655440005', 'david.brown@email.com', 'David', 'Brown', '+1-555-0205', 'parent', 'PAR005', '440e8400-e29b-41d4-a716-446655440001', true, 'david.brown', '$2b$10$example.hash.for.password345')
ON CONFLICT (id) DO NOTHING;

-- Insert test classes
INSERT INTO classes (id, name, grade, section, school_id, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Grade 1A', '1', 'A', '440e8400-e29b-41d4-a716-446655440001', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440002', 'Grade 2B', '2', 'B', '440e8400-e29b-41d4-a716-446655440001', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440003', 'Grade 3C', '3', 'C', '440e8400-e29b-41d4-a716-446655440001', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert test subjects
INSERT INTO subjects (id, name, description, school_id, created_at, updated_at) VALUES
('660e8400-e29b-41d4-a716-446655440001', 'Mathematics', 'Basic mathematics and arithmetic', '440e8400-e29b-41d4-a716-446655440001', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440002', 'English Language', 'Reading, writing, and comprehension', '440e8400-e29b-41d4-a716-446655440001', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440003', 'Science', 'Basic science concepts and experiments', '440e8400-e29b-41d4-a716-446655440001', NOW(), NOW()),
('660e8400-e29b-41d4-a716-446655440004', 'Social Studies', 'History, geography, and civics', '440e8400-e29b-41d4-a716-446655440001', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert test students with parent relationships
INSERT INTO students (id, first_name, last_name, student_id, date_of_birth, class_id, school_id, parent_ids, created_at, updated_at) VALUES
('770e8400-e29b-41d4-a716-446655440001', 'John', 'Doe', 'STU001', '2015-03-15', '550e8400-e29b-41d4-a716-446655440001', '440e8400-e29b-41d4-a716-446655440001', ARRAY['550e8400-e29b-41d4-a716-446655440001']::UUID[], NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440002', 'Jane', 'Smith', 'STU002', '2014-07-22', '550e8400-e29b-41d4-a716-446655440002', '440e8400-e29b-41d4-a716-446655440001', ARRAY['550e8400-e29b-41d4-a716-446655440002']::UUID[], NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440003', 'Mike', 'Johnson', 'STU003', '2013-11-08', '550e8400-e29b-41d4-a716-446655440003', '440e8400-e29b-41d4-a716-446655440001', ARRAY['550e8400-e29b-41d4-a716-446655440003']::UUID[], NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440004', 'Sarah', 'Wilson', 'STU004', '2015-01-30', '550e8400-e29b-41d4-a716-446655440001', '440e8400-e29b-41d4-a716-446655440001', ARRAY['550e8400-e29b-41d4-a716-446655440004']::UUID[], NOW(), NOW()),
('770e8400-e29b-41d4-a716-446655440005', 'David', 'Brown', 'STU005', '2014-09-12', '550e8400-e29b-41d4-a716-446655440002', '440e8400-e29b-41d4-a716-446655440001', ARRAY['550e8400-e29b-41d4-a716-446655440005']::UUID[], NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Add comments
COMMENT ON TABLE classes IS 'Test data added for sync verification';
COMMENT ON TABLE subjects IS 'Test data added for sync verification';
COMMENT ON TABLE students IS 'Test data added for sync verification';

-- Verification queries
SELECT 'Schools inserted:' as info, COUNT(*) as count FROM schools;
SELECT 'Parent users inserted:' as info, COUNT(*) as count FROM users WHERE role = 'parent';
SELECT 'Classes inserted:' as info, COUNT(*) as count FROM classes;
SELECT 'Subjects inserted:' as info, COUNT(*) as count FROM subjects;
SELECT 'Students inserted:' as info, COUNT(*) as count FROM students;
SELECT 'Students with parents:' as info, COUNT(*) as count FROM students WHERE parent_ids IS NOT NULL AND array_length(parent_ids, 1) > 0;