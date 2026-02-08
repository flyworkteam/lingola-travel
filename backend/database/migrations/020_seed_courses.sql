-- Seed Data: 020_seed_courses.sql
-- Description: Insert 11 course categories
-- Date: 2026-02-08

INSERT INTO courses (id, category, title, description, display_order, is_free, total_lessons) VALUES
(UUID(), 'General', 'Daily Conversation', 'Master everyday expressions and basic interactions', 1, TRUE, 12),
(UUID(), 'Trip', 'Terminal Talk', 'Essential phrases for airports and travel terminals', 2, FALSE, 12),
(UUID(), 'Food & Drink', 'Place an order', 'Navigate restaurants, cafes, and food markets', 3, FALSE, 12),
(UUID(), 'Accommodation', 'I have a reservation', 'Hotel check-in, requests, and problem-solving', 4, FALSE, 12),
(UUID(), 'Culture', 'Cultural phrases', 'Understand local customs and cultural expressions', 5, FALSE, 12),
(UUID(), 'Shopping', 'How much is this?', 'Shopping vocabulary and negotiation phrases', 6, FALSE, 12),
(UUID(), 'Direction & Navigation', 'How can I get there?', 'Ask for and understand directions', 7, FALSE, 12),
(UUID(), 'Sport', 'Is there a gym?', 'Sports facilities and recreational activities', 8, FALSE, 12),
(UUID(), 'Health', 'Where is the pharmacy?', 'Medical emergencies and health-related phrases', 9, FALSE, 12),
(UUID(), 'Business', 'We have a meeting', 'Business English for professional contexts', 10, FALSE, 12),
(UUID(), 'Emergency', 'Call the police', 'Emergency situations and urgent requests', 11, FALSE, 12);
