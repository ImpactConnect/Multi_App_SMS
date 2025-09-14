# Development Login Credentials

This file contains development login credentials for testing the School Management System.

## Super Admin Login

**Access Code:** `SUPER_ADMIN_001`  
**Password:** `dev123456`  
**Email:** `superadmin@schoolsystem.dev`  
**Name:** John Administrator  
**Phone:** +1-555-0001  
**Role:** Super Admin  

## Admin Login

**Access Code:** `ADMIN_001`  
**Password:** `admin123456`  
**Email:** `admin@schoolsystem.dev`  
**Name:** Jane Admin  
**Phone:** +1-555-0002  
**Role:** Admin  

## Teacher Login

**Access Code:** `TEACHER_001`  
**Password:** `teacher123456`  
**Email:** `teacher@schoolsystem.dev`  
**Name:** Mike Teacher  
**Phone:** +1-555-0003  
**Role:** Teacher  

## Development Notes

- These credentials are for development and testing purposes only
- In production, use strong passwords and secure access codes
- The authentication system requires both access code and password
- Users must be created in the Supabase database with these credentials

## Database Setup Required

To use these credentials, you need to:

1. Set up Supabase project
2. Create the `users` table with the required schema
3. Insert these test users into the database
4. Configure Supabase authentication

## Quick Test Instructions

For immediate testing of the Super Admin app:
1. Use Access Code: `SUPER_ADMIN_001`
2. Use Password: `dev123456`
3. Make sure the user exists in your Supabase database

---
**⚠️ IMPORTANT:** Never commit real credentials to version control!