-- Vocabulary eksik olan derslere otomatik 2 kelime ekle

-- İlk kelimeyi ekle
INSERT INTO lesson_vocabulary (lesson_id, term, definition, icon_path, display_order, target_language)
SELECT 
  l.id as lesson_id,
  'Word 1' as term,
  'First vocabulary word' as definition,
  'assets/icons/keyvoc1.svg' as icon_path,
  1 as display_order,
  l.target_language
FROM lessons l
WHERE NOT EXISTS (
  SELECT 1 FROM lesson_vocabulary lv 
  WHERE lv.lesson_id = l.id AND lv.display_order = 1
);

-- İkinci kelimeyi ekle
INSERT INTO lesson_vocabulary (lesson_id, term, definition, icon_path, display_order, target_language)
SELECT 
  l.id as lesson_id,
  'Word 2' as term,
  'Second vocabulary word' as definition,
  'assets/icons/keyvoc2.svg' as icon_path,
  2 as display_order,
  l.target_language
FROM lessons l
WHERE NOT EXISTS (
  SELECT 1 FROM lesson_vocabulary lv 
  WHERE lv.lesson_id = l.id AND lv.display_order = 2
);

-- Sonuçları göster
SELECT 'Vocabulary eklendi' as status;
SELECT target_language, COUNT(*) as vocab_count 
FROM lesson_vocabulary 
WHERE term LIKE 'Word %' 
GROUP BY target_language;
