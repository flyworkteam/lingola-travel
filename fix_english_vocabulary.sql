-- Fix English Basics vocabulary with meaningful words

-- Lesson 1: Greetings - Hello, Good morning
UPDATE lesson_vocabulary 
SET term = 'Hello', 
    definition = 'A greeting used when meeting someone'
WHERE lesson_id = '632065d4-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 1;

UPDATE lesson_vocabulary 
SET term = 'Good morning', 
    definition = 'A greeting used in the morning'
WHERE lesson_id = '632065d4-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 2;

-- Lesson 2: Numbers & Dates - One, March
UPDATE lesson_vocabulary 
SET term = 'One', 
    definition = 'The number 1'
WHERE lesson_id = '63209ab8-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 1;

UPDATE lesson_vocabulary 
SET term = 'March', 
    definition = 'The third month of the year'
WHERE lesson_id = '63209ab8-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 2;

-- Lesson 3: Common Phrases - Excuse me, Thank you
UPDATE lesson_vocabulary 
SET term = 'Excuse me', 
    definition = 'A polite phrase to get attention'
WHERE lesson_id = '63209e96-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 1;

UPDATE lesson_vocabulary 
SET term = 'Thank you', 
    definition = 'An expression of gratitude'
WHERE lesson_id = '63209e96-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 2;

-- Lesson 4: Questions & Answers - How much, Where
UPDATE lesson_vocabulary 
SET term = 'How much', 
    definition = 'Used to ask about price or quantity'
WHERE lesson_id = '6320a148-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 1;

UPDATE lesson_vocabulary 
SET term = 'Where', 
    definition = 'Used to ask about location'
WHERE lesson_id = '6320a148-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 2;

-- Lesson 5: Emergency Basics - Help, Emergency
UPDATE lesson_vocabulary 
SET term = 'Help', 
    definition = 'Used when you need assistance'
WHERE lesson_id = '6320a508-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 1;

UPDATE lesson_vocabulary 
SET term = 'Emergency', 
    definition = 'An urgent situation requiring immediate action'
WHERE lesson_id = '6320a508-0eb9-11f1-a94c-670d0a0d2286' AND display_order = 2;

SELECT 'English Basics vocabulary updated successfully!' as Result;
