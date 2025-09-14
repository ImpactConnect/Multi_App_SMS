-- Migration: Fix nullable columns and constraints
-- This addresses PostgrestException errors for NOT NULL constraint violations

-- Make username nullable (it was added with NOT NULL by default)
ALTER TABLE users ALTER COLUMN username DROP NOT NULL;

-- Make password nullable (since we're filtering it out and using password_hash instead)
ALTER TABLE users ALTER COLUMN password DROP NOT NULL;

-- Make other added columns explicitly nullable
ALTER TABLE users ALTER COLUMN address DROP NOT NULL;
ALTER TABLE users ALTER COLUMN date_of_birth DROP NOT NULL;
ALTER TABLE users ALTER COLUMN gender DROP NOT NULL;
ALTER TABLE users ALTER COLUMN national_id DROP NOT NULL;
ALTER TABLE users ALTER COLUMN emergency_contact DROP NOT NULL;
ALTER TABLE users ALTER COLUMN emergency_contact_relation DROP NOT NULL;
ALTER TABLE users ALTER COLUMN qualification DROP NOT NULL;
ALTER TABLE users ALTER COLUMN department DROP NOT NULL;
ALTER TABLE users ALTER COLUMN position DROP NOT NULL;
ALTER TABLE users ALTER COLUMN join_date DROP NOT NULL;
ALTER TABLE users ALTER COLUMN blood_group DROP NOT NULL;
ALTER TABLE users ALTER COLUMN medical_info DROP NOT NULL;
ALTER TABLE users ALTER COLUMN notes DROP NOT NULL;

-- Make schools columns nullable
ALTER TABLE schools ALTER COLUMN principal_name DROP NOT NULL;
ALTER TABLE schools ALTER COLUMN established_date DROP NOT NULL;
ALTER TABLE schools ALTER COLUMN description DROP NOT NULL;
ALTER TABLE schools ALTER COLUMN settings DROP NOT NULL;

-- Make students columns nullable
ALTER TABLE students ALTER COLUMN phone_number DROP NOT NULL;
ALTER TABLE students ALTER COLUMN email DROP NOT NULL;
ALTER TABLE students ALTER COLUMN parent_ids DROP NOT NULL;
ALTER TABLE students ALTER COLUMN emergency_contact DROP NOT NULL;
ALTER TABLE students ALTER COLUMN emergency_contact_relation DROP NOT NULL;
ALTER TABLE students ALTER COLUMN blood_group DROP NOT NULL;
ALTER TABLE students ALTER COLUMN medical_info DROP NOT NULL;
ALTER TABLE students ALTER COLUMN notes DROP NOT NULL;
ALTER TABLE students ALTER COLUMN profile_image_url DROP NOT NULL;

-- Make classes columns nullable
ALTER TABLE classes ALTER COLUMN capacity DROP NOT NULL;
ALTER TABLE classes ALTER COLUMN room_number DROP NOT NULL;

-- Make subjects columns nullable
ALTER TABLE subjects ALTER COLUMN credits DROP NOT NULL;

COMMIT;