-- Seed Data: 021_seed_dictionary_categories.sql
-- Description: Insert 10 dictionary categories
-- Date: 2026-02-08

INSERT INTO dictionary_categories (id, name, icon_path, color, display_order, item_count) VALUES
(UUID(), 'Airport', 'assets/icons/airport.png', '#2E48F0', 1, 0),
(UUID(), 'Accommodation', 'assets/icons/accommodation.png', '#F0722E', 2, 0),
(UUID(), 'Transportation', 'assets/icons/transportation.png', '#F0CC2E', 3, 0),
(UUID(), 'Food & Drink', 'assets/icons/food_drink.png', '#F02E2E', 4, 0),
(UUID(), 'Shopping', 'assets/icons/shopping.png', '#8BD99D', 5, 0),
(UUID(), 'Culture', 'assets/icons/culture.png', '#70CDBB', 6, 0),
(UUID(), 'Meeting', 'assets/icons/meeting.png', '#FDB0B0', 7, 0),
(UUID(), 'Sport', 'assets/icons/sport.png', '#FCD5F0', 8, 0),
(UUID(), 'Health', 'assets/icons/health.png', '#86E17C', 9, 0),
(UUID(), 'Business', 'assets/icons/business.png', '#53BAF5', 10, 0);
