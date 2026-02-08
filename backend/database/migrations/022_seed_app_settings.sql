-- Seed Data: 022_seed_app_settings.sql
-- Description: Insert default app settings
-- Date: 2026-02-08

INSERT INTO app_settings (setting_key, setting_value, data_type, description) VALUES
('api_version', 'v1', 'string', 'Current API version'),
('maintenance_mode', 'false', 'boolean', 'Enable maintenance mode'),
('premium_trial_days', '1', 'number', 'Free trial duration in days'),
('min_app_version_ios', '1.0.0', 'string', 'Minimum required iOS app version'),
('min_app_version_android', '1.0.0', 'string', 'Minimum required Android app version'),
('force_update', 'false', 'boolean', 'Force users to update app'),
('show_premium_promo', 'true', 'boolean', 'Show premium promotion notifications');
