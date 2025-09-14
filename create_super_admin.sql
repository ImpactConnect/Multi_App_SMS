-- Super Admin User Creation Script
-- Run this script in your Supabase SQL Editor (Dashboard > SQL Editor)
-- Email: teay361@gmail.com
-- Password: 123456 (will be hashed)
-- UID: d2fc70d3-bcfa-4c38-be23-a860e2f71115

-- Insert Super Admin User
INSERT INTO users (
    id,
    email,
    first_name,
    last_name,
    phone_number,
    role,
    is_active,
    username,
    password,
    access_code,
    created_at,
    updated_at
) VALUES (
    'd2fc70d3-bcfa-4c38-be23-a860e2f71115'::uuid,
    'teay361@gmail.com',
    'Super',
    'Admin',
    '+1234567890',
    'superAdmin',
    true,
    'superadmin',
    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- bcrypt hash of '123456'
    'SA001',
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    role = EXCLUDED.role,
    updated_at = NOW();

-- Verify the user was created successfully
SELECT 
    id, 
    email, 
    first_name, 
    last_name, 
    role, 
    is_active, 
    access_code,
    created_at 
FROM users 
WHERE id = 'd2fc70d3-bcfa-4c38-be23-a860e2f71115'::uuid;

-- Display success message
SELECT 'Super Admin user created successfully!' as message;