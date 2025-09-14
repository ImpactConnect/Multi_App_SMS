# Development Setup Guide

This guide helps you set up the School Management System for development and testing.

## Prerequisites

- Flutter SDK installed
- Supabase account and project
- Git (for version control)

## Quick Start

### 1. Supabase Configuration

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Go to your project's SQL Editor
3. Run the SQL commands from `dev_seed_data.sql` to create the users table and test data
4. Go to Authentication > Users in your Supabase dashboard
5. Create auth users manually with these credentials:

   | Email | Password | Role |
   |-------|----------|------|
   | superadmin@schoolsystem.dev | dev123456 | Super Admin |
   | admin@schoolsystem.dev | admin123456 | Admin |
   | teacher@schoolsystem.dev | teacher123456 | Teacher |
   | accountant@schoolsystem.dev | accountant123456 | Accountant |
   | parent@schoolsystem.dev | parent123456 | Parent |

### 2. Environment Configuration

1. Copy your Supabase URL and anon key from Project Settings > API
2. Update the Supabase configuration in your Flutter app
3. Make sure the `supabase_flutter` package is properly initialized

### 3. Testing the Super Admin App

1. Navigate to the super_admin app directory:
   ```bash
   cd apps/super_admin
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run -d windows
   ```

4. Use these login credentials:
   - **Access Code:** `SUPER_ADMIN_001`
   - **Password:** `dev123456`

## Development Credentials

See `dev_credentials.md` for complete list of test accounts.

### Super Admin Login (Primary for testing)
- Access Code: `SUPER_ADMIN_001`
- Password: `dev123456`
- Email: superadmin@schoolsystem.dev

## Features Available for Testing

✅ **Implemented:**
- User authentication with access codes
- Dashboard with metrics and analytics
- School management (CRUD operations)
- User profile display
- Logout functionality

🚧 **In Development:**
- User management system
- System settings
- Data import/export

## Troubleshooting

### Authentication Issues

1. **"Invalid access code or role"**
   - Verify the user exists in Supabase users table
   - Check that `is_active` is true
   - Ensure the role matches exactly (case-sensitive)

2. **"Authentication failed"**
   - Verify the Supabase Auth user exists
   - Check that email and password match
   - Ensure Supabase configuration is correct

3. **App won't start**
   - Run `flutter clean` and `flutter pub get`
   - Check that all dependencies are installed
   - Verify Flutter and Dart SDK versions

### Database Issues

1. **Users table doesn't exist**
   - Run the SQL from `dev_seed_data.sql`
   - Check table permissions in Supabase

2. **No test data**
   - Re-run the INSERT statements from `dev_seed_data.sql`
   - Verify data with: `SELECT * FROM users;`

## Development Workflow

1. **Making Changes:**
   - Test with Super Admin credentials first
   - Use different role credentials to test role-based features
   - Always test authentication flow

2. **Adding New Features:**
   - Update the appropriate app (super_admin, admin, etc.)
   - Test with relevant user roles
   - Update this documentation if needed

3. **Database Changes:**
   - Update `dev_seed_data.sql` with new schema
   - Test migrations on development database first

## Security Notes

⚠️ **Important:**
- These credentials are for development only
- Never use these credentials in production
- Always use environment variables for sensitive configuration
- Regularly rotate development credentials

## Next Steps

1. Set up your Supabase project
2. Run the seed data script
3. Test the Super Admin login
4. Explore the dashboard and school management features
5. Start developing additional features

For questions or issues, refer to the project documentation or create an issue in the repository.