/// App-wide localization class.
/// Usage: AppLocalizations.of(langCode).someKey
class AppLocalizations {
  final String langCode;
  const AppLocalizations._(this.langCode);

  static AppLocalizations of(String code) => AppLocalizations._(code);

  // ─── Shared ────────────────────────────────────────────────────────────────
  String get back => _t({
    'en': 'Back',
    'tr': 'Geri',
    'es': 'Atrás',
    'fr': 'Retour',
    'de': 'Zurück',
    'it': 'Indietro',
    'pt': 'Voltar',
    'ru': 'Назад',
    'ja': '戻る',
    'ko': '뒤로',
    'hi': 'वापस',
  });

  String get continueBtn => _t({
    'en': 'Continue',
    'tr': 'Devam Et',
    'es': 'Continuar',
    'fr': 'Continuer',
    'de': 'Weiter',
    'it': 'Continua',
    'pt': 'Continuar',
    'ru': 'Продолжить',
    'ja': '続ける',
    'ko': '계속',
    'hi': 'जारी रखें',
  });

  String get save => _t({
    'en': 'Save',
    'tr': 'Kaydet',
    'es': 'Guardar',
    'fr': 'Enregistrer',
    'de': 'Speichern',
    'it': 'Salva',
    'pt': 'Salvar',
    'ru': 'Сохранить',
    'ja': '保存',
    'ko': '저장',
    'hi': 'सहेजें',
  });

  String get seeAll => _t({
    'en': 'See All',
    'tr': 'Tümünü Gör',
    'es': 'Ver Todo',
    'fr': 'Voir Tout',
    'de': 'Alle Ansehen',
    'it': 'Vedi Tutto',
    'pt': 'Ver Tudo',
    'ru': 'Все',
    'ja': 'すべて見る',
    'ko': '모두 보기',
    'hi': 'सब देखें',
  });

  // ─── Onboarding Step 1 ─────────────────────────────────────────────────────
  String get step1of4 => _t({
    'en': 'STEP 1 / 4',
    'tr': 'ADIM 1 / 4',
    'es': 'PASO 1 / 4',
    'fr': 'ÉTAPE 1 / 4',
    'de': 'SCHRITT 1 / 4',
    'it': 'PASSO 1 / 4',
    'pt': 'PASSO 1 / 4',
    'ru': 'ШАГ 1 / 4',
    'ja': 'ステップ 1 / 4',
    'ko': '단계 1 / 4',
    'hi': 'चरण 1 / 4',
  });

  String get step1Title => _t({
    'en': 'Choose the language\nyou want to learn',
    'tr': 'Öğrenmek istediğiniz\ndili seçin',
    'es': 'Elige el idioma\nque quieres aprender',
    'fr': 'Choisissez la langue\nque vous voulez apprendre',
    'de': 'Wähle die Sprache\ndie du lernen möchtest',
    'it': 'Scegli la lingua\nche vuoi imparare',
    'pt': 'Escolha o idioma\nque você quer aprender',
    'ru': 'Выберите язык\nкоторый хотите учить',
    'ja': '学びたい言語を\n選んでください',
    'ko': '배우고 싶은 언어를\n선택하세요',
    'hi': 'वह भाषा चुनें\nजो आप सीखना चाहते हैं',
  });

  String get step1Subtitle => _t({
    'en': 'Please choose the language\nyou want to learn',
    'tr': 'Lütfen öğrenmek istediğiniz\ndili seçin',
    'es': 'Por favor elige el idioma\nque quieres aprender',
    'fr': 'Veuillez choisir la langue\nque vous voulez apprendre',
    'de': 'Bitte wähle die Sprache\ndie du lernen möchtest',
    'it': 'Si prega di scegliere la lingua\nche si vuole imparare',
    'pt': 'Por favor escolha o idioma\nque você quer aprender',
    'ru': 'Пожалуйста, выберите язык\nкоторый хотите учить',
    'ja': '学びたい言語を\n選択してください',
    'ko': '배우고 싶은 언어를\n선택해 주세요',
    'hi': 'कृपया वह भाषा चुनें\nजो आप सीखना चाहते हैं',
  });

  // ─── Onboarding Step 2 ─────────────────────────────────────────────────────
  String get step2of4 => _t({
    'en': 'STEP 2 / 4',
    'tr': 'ADIM 2 / 4',
    'es': 'PASO 2 / 4',
    'fr': 'ÉTAPE 2 / 4',
    'de': 'SCHRITT 2 / 4',
    'it': 'PASSO 2 / 4',
    'pt': 'PASSO 2 / 4',
    'ru': 'ШАГ 2 / 4',
    'ja': 'ステップ 2 / 4',
    'ko': '단계 2 / 4',
    'hi': 'चरण 2 / 4',
  });

  String get step2Title => _t({
    'en': 'What Is Your\nProfession?',
    'tr': 'Mesleğiniz\nNedir?',
    'es': '¿Cuál Es Tu\nProfesión?',
    'fr': 'Quelle Est Votre\nProfession?',
    'de': 'Was Ist Ihr\nBeruf?',
    'it': 'Qual È La Tua\nProfessione?',
    'pt': 'Qual É A Sua\nProfissão?',
    'ru': 'Какова Ваша\nПрофессия?',
    'ja': 'あなたの職業は\n何ですか？',
    'ko': '당신의 직업은\n무엇입니까?',
    'hi': 'आपका पेशा\nक्या है?',
  });

  String get step2Subtitle => _t({
    'en': 'We\'ll customize your language journey\nbased on your background',
    'tr': 'Geçmişinize göre dil yolculuğunuzu\nözelleştireceğiz',
    'es': 'Personalizaremos tu viaje lingüístico\nsegún tu experiencia',
    'fr':
        'Nous personnaliserons votre parcours\nlinguistique selon votre expérience',
    'de':
        'Wir personalisieren Ihre Sprachreise\nbasierend auf Ihrem Hintergrund',
    'it':
        'Personalizzeremo il tuo percorso\nlinguistico in base alla tua esperienza',
    'pt': 'Personalizaremos sua jornada\nlinguística com base no seu histórico',
    'ru': 'Мы настроим ваше путешествие\nпо языку на основе вашего опыта',
    'ja': 'あなたの経歴に基づいて\n言語の旅をカスタマイズします',
    'ko': '귀하의 배경을 바탕으로\n언어 여정을 맞춤화합니다',
    'hi': 'हम आपकी पृष्ठभूमि के आधार पर\nआपकी भाषा यात्रा को अनुकूलित करेंगे',
  });

  // ─── Profession Names ───────────────────────────────────────────────────────
  String get profStudent => _t({
    'en': 'Student',
    'tr': 'Öğrenci',
    'es': 'Estudiante',
    'fr': 'Étudiant',
    'de': 'Student',
    'it': 'Studente',
    'pt': 'Estudante',
    'ru': 'Студент',
    'ja': '学生',
    'ko': '학생',
    'hi': 'छात्र',
  });

  String get profStudentSub => _t({
    'en': 'University or\nhigh school',
    'tr': 'Üniversite veya\nlise',
    'es': 'Universidad o\nbachillerato',
    'fr': 'Université ou\nlycée',
    'de': 'Universität oder\nGymnasium',
    'it': 'Università o\nliceo',
    'pt': 'Universidade ou\nensino médio',
    'ru': 'Университет или\nшкола',
    'ja': '大学または\n高校',
    'ko': '대학교 또는\n고등학교',
    'hi': 'विश्वविद्यालय या\nहाई स्कूल',
  });

  String get profProfessional => _t({
    'en': 'Professional',
    'tr': 'Profesyonel',
    'es': 'Profesional',
    'fr': 'Professionnel',
    'de': 'Fachkraft',
    'it': 'Professionista',
    'pt': 'Profissional',
    'ru': 'Специалист',
    'ja': 'プロフェッショナル',
    'ko': '전문가',
    'hi': 'पेशेवर',
  });

  String get profProfessionalSub => _t({
    'en': 'Corporate or\nfreelance',
    'tr': 'Kurumsal veya\nserbest',
    'es': 'Corporativo o\nfreelance',
    'fr': 'Entreprise ou\nindépendant',
    'de': 'Unternehmen oder\nFreelancer',
    'it': 'Aziendale o\nfreelance',
    'pt': 'Corporativo ou\nfreelancer',
    'ru': 'Корпоративный или\nфриланс',
    'ja': '企業または\nフリーランス',
    'ko': '기업 또는\n프리랜서',
    'hi': 'कॉर्पोरेट या\nफ्रीलांस',
  });

  String get profTechnology => _t({
    'en': 'Technology',
    'tr': 'Teknoloji',
    'es': 'Tecnología',
    'fr': 'Technologie',
    'de': 'Technologie',
    'it': 'Tecnologia',
    'pt': 'Tecnologia',
    'ru': 'Технологии',
    'ja': 'テクノロジー',
    'ko': '기술',
    'hi': 'प्रौद्योगिकी',
  });

  String get profTechnologySub => _t({
    'en': 'IT, software\nor data',
    'tr': 'BT, yazılım\nveya veri',
    'es': 'TI, software\no datos',
    'fr': 'Informatique, logiciel\nou données',
    'de': 'IT, Software\noder Daten',
    'it': 'IT, software\no dati',
    'pt': 'TI, software\nou dados',
    'ru': 'ИТ, программное\nили данные',
    'ja': 'IT、ソフトウェア\nまたはデータ',
    'ko': 'IT, 소프트웨어\n또는 데이터',
    'hi': 'आईटी, सॉफ्टवेयर\nया डेटा',
  });

  String get profHealthcare => _t({
    'en': 'Healthcare',
    'tr': 'Sağlık',
    'es': 'Salud',
    'fr': 'Santé',
    'de': 'Gesundheit',
    'it': 'Sanità',
    'pt': 'Saúde',
    'ru': 'Здравоохранение',
    'ja': '医療',
    'ko': '의료',
    'hi': 'स्वास्थ्य सेवा',
  });

  String get profHealthcareSub => _t({
    'en': 'Medicine or\nnursing',
    'tr': 'Tıp veya\nhemşirelik',
    'es': 'Medicina o\nenfermería',
    'fr': 'Médecine ou\ninfirmerie',
    'de': 'Medizin oder\nPflege',
    'it': 'Medicina o\ninfermieristica',
    'pt': 'Medicina ou\nenfermagem',
    'ru': 'Медицина или\nсестринское дело',
    'ja': '医学または\n看護',
    'ko': '의학 또는\n간호',
    'hi': 'चिकित्सा या\nनर्सिंग',
  });

  String get profArtsMedia => _t({
    'en': 'Arts & Media',
    'tr': 'Sanat & Medya',
    'es': 'Arte & Medios',
    'fr': 'Arts & Médias',
    'de': 'Kunst & Medien',
    'it': 'Arte & Media',
    'pt': 'Arte & Mídia',
    'ru': 'Искусство & СМИ',
    'ja': 'アート & メディア',
    'ko': '예술 & 미디어',
    'hi': 'कला & मीडिया',
  });

  String get profArtsMediaSub => _t({
    'en': 'Design, film\nor writing',
    'tr': 'Tasarım, film\nveya yazarlık',
    'es': 'Diseño, cine\no escritura',
    'fr': 'Design, cinéma\nou écriture',
    'de': 'Design, Film\noder Schreiben',
    'it': 'Design, cinema\no scrittura',
    'pt': 'Design, cinema\nou escrita',
    'ru': 'Дизайн, кино\nили писательство',
    'ja': 'デザイン、映画\nまたは執筆',
    'ko': '디자인, 영화\n또는 글쓰기',
    'hi': 'डिज़ाइन, फिल्म\nया लेखन',
  });

  String get profOther => _t({
    'en': 'Other',
    'tr': 'Diğer',
    'es': 'Otro',
    'fr': 'Autre',
    'de': 'Andere',
    'it': 'Altro',
    'pt': 'Outro',
    'ru': 'Другое',
    'ja': 'その他',
    'ko': '기타',
    'hi': 'अन्य',
  });

  String get profOtherSub => _t({
    'en': 'None of\nthe above',
    'tr': 'Yukarıdakilerin\nhiçbiri',
    'es': 'Ninguna de\nlas anteriores',
    'fr': 'Aucune de\nces réponses',
    'de': 'Keine der\nobigen',
    'it': 'Nessuna delle\nprecedenti',
    'pt': 'Nenhuma das\nanteriores',
    'ru': 'Ни одно из\nвышеперечисленных',
    'ja': '上記のいずれでも\nない',
    'ko': '위의 항목에\n해당 없음',
    'hi': 'इनमें से\nकोई नहीं',
  });

  // ─── Onboarding Step 3 ─────────────────────────────────────────────────────
  String get step3of4 => _t({
    'en': 'STEP 3 / 4',
    'tr': 'ADIM 3 / 4',
    'es': 'PASO 3 / 4',
    'fr': 'ÉTAPE 3 / 4',
    'de': 'SCHRITT 3 / 4',
    'it': 'PASSO 3 / 4',
    'pt': 'PASSO 3 / 4',
    'ru': 'ШАГ 3 / 4',
    'ja': 'ステップ 3 / 4',
    'ko': '단계 3 / 4',
    'hi': 'चरण 3 / 4',
  });

  String get step3Title => _t({
    'en': 'What is your\nlevel?',
    'tr': 'Seviyeniz\nnedir?',
    'es': '¿Cuál es tu\nnivel?',
    'fr': 'Quel est votre\nniveau?',
    'de': 'Was ist Ihr\nNiveau?',
    'it': 'Qual è il tuo\nlivello?',
    'pt': 'Qual é o seu\nnível?',
    'ru': 'Каков ваш\nуровень?',
    'ja': 'あなたのレベルは\n何ですか？',
    'ko': '당신의 수준은\n무엇입니까?',
    'hi': 'आपका स्तर\nक्या है?',
  });

  String get step3Subtitle => _t({
    'en': 'We\'ll customize your language journey\nbased on your background',
    'tr': 'Geçmişinize göre dil yolculuğunuzu\nözelleştireceğiz',
    'es': 'Personalizaremos tu viaje lingüístico\nsegún tu experiencia',
    'fr':
        'Nous personnaliserons votre parcours\nlinguistique selon votre expérience',
    'de':
        'Wir personalisieren Ihre Sprachreise\nbasierend auf Ihrem Hintergrund',
    'it':
        'Personalizzeremo il tuo percorso\nlinguistico in base alla tua esperienza',
    'pt': 'Personalizaremos sua jornada\nlinguística com base no seu histórico',
    'ru': 'Мы настроим ваше путешествие\nпо языку на основе вашего опыта',
    'ja': 'あなたの経歴に基づいて\n言語の旅をカスタマイズします',
    'ko': '귀하의 배경을 바탕으로\n언어 여정을 맞춤화합니다',
    'hi': 'हम आपकी पृष्ठभूमि के आधार पर\nआपकी भाषा यात्रा को अनुकूलित करेंगे',
  });

  // ─── Level Names ─────────────────────────────────────────────────────────
  String get levelBeginner => _t({
    'en': 'Beginner',
    'tr': 'Başlangıç',
    'es': 'Principiante',
    'fr': 'Débutant',
    'de': 'Anfänger',
    'it': 'Principiante',
    'pt': 'Iniciante',
    'ru': 'Начинающий',
    'ja': '初心者',
    'ko': '초급',
    'hi': 'शुरुआती',
  });

  String get levelBeginnerDesc => _t({
    'en': 'Can understand and use everyday expressions.',
    'tr': 'Günlük ifadeleri anlayabilir ve kullanabilir.',
    'es': 'Puede entender y usar expresiones cotidianas.',
    'fr': 'Peut comprendre et utiliser des expressions quotidiennes.',
    'de': 'Kann Alltagsausdrücke verstehen und verwenden.',
    'it': 'Può capire e usare espressioni quotidiane.',
    'pt': 'Pode entender e usar expressões cotidianas.',
    'ru': 'Может понимать и использовать повседневные выражения.',
    'ja': '日常的な表現を理解し使用できます。',
    'ko': '일상적인 표현을 이해하고 사용할 수 있습니다.',
    'hi': 'रोज़मर्रा की अभिव्यक्तियों को समझ और उपयोग कर सकते हैं।',
  });

  String get levelElementary => _t({
    'en': 'Elementary',
    'tr': 'Temel',
    'es': 'Elemental',
    'fr': 'Élémentaire',
    'de': 'Grundstufe',
    'it': 'Elementare',
    'pt': 'Elementar',
    'ru': 'Элементарный',
    'ja': '初級',
    'ko': '기초',
    'hi': 'प्राथमिक',
  });

  String get levelElementaryDesc => _t({
    'en': 'Can communicate in simple and routine tasks.',
    'tr': 'Basit ve rutin görevlerde iletişim kurabilir.',
    'es': 'Puede comunicarse en tareas simples y rutinarias.',
    'fr': 'Peut communiquer dans des tâches simples et routinières.',
    'de': 'Kann sich bei einfachen Routineaufgaben verständigen.',
    'it': 'Può comunicare in compiti semplici e routinari.',
    'pt': 'Pode se comunicar em tarefas simples e rotineiras.',
    'ru': 'Может общаться при выполнении простых и обычных задач.',
    'ja': '簡単なルーティンタスクでコミュニケーションできます。',
    'ko': '간단하고 일상적인 작업에서 의사소통할 수 있습니다.',
    'hi': 'सरल और नियमित कार्यों में संवाद कर सकते हैं।',
  });

  String get levelIntermediate => _t({
    'en': 'Intermediate',
    'tr': 'Orta',
    'es': 'Intermedio',
    'fr': 'Intermédiaire',
    'de': 'Mittelstufe',
    'it': 'Intermedio',
    'pt': 'Intermediário',
    'ru': 'Средний',
    'ja': '中級',
    'ko': '중급',
    'hi': 'मध्यवर्ती',
  });

  String get levelIntermediateDesc => _t({
    'en': 'Can handle situations while travelling.',
    'tr': 'Seyahat ederken karşılaşılabilecek durumlarla başa çıkabilir.',
    'es': 'Puede manejar situaciones mientras viaja.',
    'fr': 'Peut gérer des situations lors de voyages.',
    'de': 'Kann Situationen beim Reisen bewältigen.',
    'it': 'Può gestire situazioni durante i viaggi.',
    'pt': 'Pode lidar com situações durante viagens.',
    'ru': 'Может справляться с ситуациями во время путешествий.',
    'ja': '旅行中の状況に対処できます。',
    'ko': '여행 중 상황을 처리할 수 있습니다.',
    'hi': 'यात्रा के दौरान परिस्थितियों को संभाल सकते हैं।',
  });

  String get levelUpperIntermediate => _t({
    'en': 'Upper Intermediate',
    'tr': 'İleri Orta',
    'es': 'Intermedio Alto',
    'fr': 'Intermédiaire Supérieur',
    'de': 'Obere Mittelstufe',
    'it': 'Intermedio Superiore',
    'pt': 'Intermediário Superior',
    'ru': 'Выше среднего',
    'ja': '中上級',
    'ko': '중상급',
    'hi': 'उच्च मध्यवर्ती',
  });

  String get levelUpperIntermediateDesc => _t({
    'en': 'Can comfortably manage business meetings.',
    'tr': 'İş toplantılarını rahatça yönetebilir.',
    'es': 'Puede gestionar reuniones de negocios cómodamente.',
    'fr': 'Peut gérer confortablement des réunions d\'affaires.',
    'de': 'Kann Geschäftstreffen problemlos leiten.',
    'it': 'Può gestire comodamente le riunioni di lavoro.',
    'pt': 'Pode conduzir reuniões de negócios confortavelmente.',
    'ru': 'Может уверенно проводить деловые встречи.',
    'ja': 'ビジネスミーティングを快適に管理できます。',
    'ko': '비즈니스 회의를 편안하게 진행할 수 있습니다.',
    'hi': 'व्यावसायिक बैठकों को आराम से संभाल सकते हैं।',
  });

  // ─── Onboarding Step 4 ─────────────────────────────────────────────────────
  String get step4of4 => _t({
    'en': 'STEP 4 / 4',
    'tr': 'ADIM 4 / 4',
    'es': 'PASO 4 / 4',
    'fr': 'ÉTAPE 4 / 4',
    'de': 'SCHRITT 4 / 4',
    'it': 'PASSO 4 / 4',
    'pt': 'PASSO 4 / 4',
    'ru': 'ШАГ 4 / 4',
    'ja': 'ステップ 4 / 4',
    'ko': '단계 4 / 4',
    'hi': 'चरण 4 / 4',
  });

  String get step4Title => _t({
    'en': 'What is your\ndaily goal?',
    'tr': 'Günlük hedefiniz\nnedir?',
    'es': '¿Cuál es tu\nobjetivo diario?',
    'fr': 'Quel est votre\nobjectif quotidien?',
    'de': 'Was ist Ihr\ntägliches Ziel?',
    'it': 'Qual è il tuo\nobbiettivo giornaliero?',
    'pt': 'Qual é o seu\nobjetivo diário?',
    'ru': 'Какова ваша\nежедневная цель?',
    'ja': 'あなたの毎日の\n目標は何ですか？',
    'ko': '당신의 일일 목표는\n무엇입니까?',
    'hi': 'आपका दैनिक लक्ष्य\nक्या है?',
  });

  String get step4Subtitle => _t({
    'en':
        'Choose how much time you want to spend\nlearning. You can change this later.',
    'tr':
        'Öğrenmeye ne kadar zaman ayırmak istediğinizi\nseçin. Bunu daha sonra değiştirebilirsiniz.',
    'es':
        'Elige cuánto tiempo quieres dedicar\naprender. Puedes cambiar esto más tarde.',
    'fr':
        'Choisissez combien de temps vous voulez\nconsacrer à l\'apprentissage. Vous pouvez le changer.',
    'de':
        'Wählen Sie, wie viel Zeit Sie fürs Lernen\naufwenden möchten. Sie können dies später ändern.',
    'it':
        'Scegli quanto tempo vuoi dedicare\nall\'apprendimento. Puoi cambiarlo in seguito.',
    'pt':
        'Escolha quanto tempo quer dedicar\naos estudos. Você pode mudar isso depois.',
    'ru':
        'Выберите, сколько времени вы хотите\nпосвятить обучению. Это можно изменить.',
    'ja': '学習に費やしたい時間を選んでください。\n後で変更できます。',
    'ko': '학습에 얼마나 시간을 쓸지 선택하세요.\n나중에 변경할 수 있습니다.',
    'hi':
        'चुनें कि आप कितना समय सीखने में लगाना चाहते हैं।\nआप इसे बाद में बदल सकते हैं।',
  });

  // ─── Goal Titles ────────────────────────────────────────────────────────────
  String get goalCasual => _t({
    'en': 'Casual',
    'tr': 'Hafif',
    'es': 'Casual',
    'fr': 'Décontracté',
    'de': 'Locker',
    'it': 'Casual',
    'pt': 'Leve',
    'ru': 'Лёгкий',
    'ja': 'カジュアル',
    'ko': '가볍게',
    'hi': 'हल्का',
  });

  String get goalCasualDuration => _t({
    'en': '5 min/day',
    'tr': '5 dk/gün',
    'es': '5 min/día',
    'fr': '5 min/jour',
    'de': '5 Min/Tag',
    'it': '5 min/giorno',
    'pt': '5 min/dia',
    'ru': '5 мин/день',
    'ja': '5分/日',
    'ko': '5분/일',
    'hi': '5 मिनट/दिन',
  });

  String get goalRegular => _t({
    'en': 'Regular',
    'tr': 'Normal',
    'es': 'Regular',
    'fr': 'Régulier',
    'de': 'Regelmäßig',
    'it': 'Regolare',
    'pt': 'Regular',
    'ru': 'Обычный',
    'ja': 'レギュラー',
    'ko': '보통',
    'hi': 'नियमित',
  });

  String get goalRegularDuration => _t({
    'en': '15 min/day',
    'tr': '15 dk/gün',
    'es': '15 min/día',
    'fr': '15 min/jour',
    'de': '15 Min/Tag',
    'it': '15 min/giorno',
    'pt': '15 min/dia',
    'ru': '15 мин/день',
    'ja': '15分/日',
    'ko': '15분/일',
    'hi': '15 मिनट/दिन',
  });

  String get goalSerious => _t({
    'en': 'Serious',
    'tr': 'Ciddi',
    'es': 'Serio',
    'fr': 'Sérieux',
    'de': 'Ernsthaft',
    'it': 'Serio',
    'pt': 'Sério',
    'ru': 'Серьёзный',
    'ja': '真剣',
    'ko': '진지하게',
    'hi': 'गंभीर',
  });

  String get goalSeriousDuration => _t({
    'en': '30 min/day',
    'tr': '30 dk/gün',
    'es': '30 min/día',
    'fr': '30 min/jour',
    'de': '30 Min/Tag',
    'it': '30 min/giorno',
    'pt': '30 min/dia',
    'ru': '30 мин/день',
    'ja': '30分/日',
    'ko': '30분/일',
    'hi': '30 मिनट/दिन',
  });

  // ─── Home ──────────────────────────────────────────────────────────────────
  String get homeTitle => _t({
    'en': 'Master Languages\nWhile Exploring',
    'tr': 'Keşfederken\nDil Öğren',
    'es': 'Domina Idiomas\nMientras Exploras',
    'fr': 'Maîtriser les Langues\nEn Explorant',
    'de': 'Sprachen Meistern\nBeim Erkunden',
    'it': 'Padroneggia le Lingue\nEsplorando',
    'pt': 'Domine Idiomas\nEnquanto Explora',
    'ru': 'Осваивай Языки\nПутешествуя',
    'ja': '探索しながら\n言語をマスター',
    'ko': '탐험하며\n언어 마스터',
    'hi': 'खोज करते हुए\nभाषा सीखें',
  });

  String get quickPhrasebook => _t({
    'en': 'Quick Phrasebook',
    'tr': 'Hızlı İfade Kitabı',
    'es': 'Libro de Frases Rápido',
    'fr': 'Guide de Phrases Rapide',
    'de': 'Schnelles Sprachbuch',
    'it': 'Frasario Rapido',
    'pt': 'Guia de Frases Rápido',
    'ru': 'Быстрый Разговорник',
    'ja': 'クイックフレーズブック',
    'ko': '빠른 어구집',
    'hi': 'त्वरित वाक्यांश पुस्तक',
  });

  String get quickActions => _t({
    'en': 'Quick Actions',
    'tr': 'Hızlı Eylemler',
    'es': 'Acciones Rápidas',
    'fr': 'Actions Rapides',
    'de': 'Schnellaktionen',
    'it': 'Azioni Rapide',
    'pt': 'Ações Rápidas',
    'ru': 'Быстрые Действия',
    'ja': 'クイックアクション',
    'ko': '빠른 작업',
    'hi': 'त्वरित क्रियाएं',
  });

  String get selectLanguage => _t({
    'en': 'Select Language',
    'tr': 'Dil Seç',
    'es': 'Seleccionar Idioma',
    'fr': 'Sélectionner la Langue',
    'de': 'Sprache Auswählen',
    'it': 'Seleziona Lingua',
    'pt': 'Selecionar Idioma',
    'ru': 'Выбрать Язык',
    'ja': '言語を選択',
    'ko': '언어 선택',
    'hi': 'भाषा चुनें',
  });

  String get categoriesNotFound => _t({
    'en': 'Categories not found',
    'tr': 'Kategori bulunamadı',
    'es': 'Categorías no encontradas',
    'fr': 'Catégories introuvables',
    'de': 'Kategorien nicht gefunden',
    'it': 'Categorie non trovate',
    'pt': 'Categorias não encontradas',
    'ru': 'Категории не найдены',
    'ja': 'カテゴリが見つかりません',
    'ko': '카테고리를 찾을 수 없습니다',
    'hi': 'श्रेणियाँ नहीं मिलीं',
  });

  // ─── Profile ───────────────────────────────────────────────────────────────
  String get profile => _t({
    'en': 'Profile',
    'tr': 'Profil',
    'es': 'Perfil',
    'fr': 'Profil',
    'de': 'Profil',
    'it': 'Profilo',
    'pt': 'Perfil',
    'ru': 'Профиль',
    'ja': 'プロフィール',
    'ko': '프로필',
    'hi': 'प्रोफ़ाइल',
  });

  String get accountSettings => _t({
    'en': 'ACCOUNT SETTINGS',
    'tr': 'HESAP AYARLARI',
    'es': 'CONFIGURACIÓN DE CUENTA',
    'fr': 'PARAMÈTRES DU COMPTE',
    'de': 'KONTOEINSTELLUNGEN',
    'it': 'IMPOSTAZIONI ACCOUNT',
    'pt': 'CONFIGURAÇÕES DA CONTA',
    'ru': 'НАСТРОЙКИ АККАУНТА',
    'ja': 'アカウント設定',
    'ko': '계정 설정',
    'hi': 'खाता सेटिंग',
  });

  String get profileSettings => _t({
    'en': 'Profile Settings',
    'tr': 'Profil Ayarları',
    'es': 'Configuración de Perfil',
    'fr': 'Paramètres du Profil',
    'de': 'Profileinstellungen',
    'it': 'Impostazioni Profilo',
    'pt': 'Configurações de Perfil',
    'ru': 'Настройки Профиля',
    'ja': 'プロフィール設定',
    'ko': '프로필 설정',
    'hi': 'प्रोफ़ाइल सेटिंग',
  });

  String get notifications => _t({
    'en': 'Notifications',
    'tr': 'Bildirimler',
    'es': 'Notificaciones',
    'fr': 'Notifications',
    'de': 'Benachrichtigungen',
    'it': 'Notifiche',
    'pt': 'Notificações',
    'ru': 'Уведомления',
    'ja': '通知',
    'ko': '알림',
    'hi': 'सूचनाएं',
  });

  String get premium => _t({
    'en': 'Premium',
    'tr': 'Premium',
    'es': 'Premium',
    'fr': 'Premium',
    'de': 'Premium',
    'it': 'Premium',
    'pt': 'Premium',
    'ru': 'Премиум',
    'ja': 'プレミアム',
    'ko': '프리미엄',
    'hi': 'प्रीमियम',
  });

  String get premiumBadgePassive => _t({
    'en': 'Passive',
    'tr': 'Pasif',
    'es': 'Pasivo',
    'fr': 'Passif',
    'de': 'Passiv',
    'it': 'Passivo',
    'pt': 'Passivo',
    'ru': 'Неактивно',
    'ja': '未加入',
    'ko': '미가입',
    'hi': 'निष्क्रिय',
  });

  String get general => _t({
    'en': 'GENERAL',
    'tr': 'GENEL',
    'es': 'GENERAL',
    'fr': 'GÉNÉRAL',
    'de': 'ALLGEMEIN',
    'it': 'GENERALE',
    'pt': 'GERAL',
    'ru': 'ОСНОВНЫЕ',
    'ja': '一般',
    'ko': '일반',
    'hi': 'सामान्य',
  });

  String get appLanguage => _t({
    'en': 'App Language',
    'tr': 'Uygulama Dili',
    'es': 'Idioma de la App',
    'fr': 'Langue de l\'Application',
    'de': 'App-Sprache',
    'it': 'Lingua dell\'App',
    'pt': 'Idioma do Aplicativo',
    'ru': 'Язык Приложения',
    'ja': 'アプリの言語',
    'ko': '앱 언어',
    'hi': 'ऐप भाषा',
  });

  String get shareFriend => _t({
    'en': 'Share Friend',
    'tr': 'Arkadaşla Paylaş',
    'es': 'Compartir con Amigo',
    'fr': 'Partager avec un Ami',
    'de': 'Mit Freund Teilen',
    'it': 'Condividi con Amico',
    'pt': 'Compartilhar com Amigo',
    'ru': 'Поделиться с Другом',
    'ja': '友達に共有',
    'ko': '친구와 공유',
    'hi': 'दोस्त के साथ शेयर करें',
  });

  String get rateUs => _t({
    'en': 'Rate Us',
    'tr': 'Bizi Oyla',
    'es': 'Calificarnos',
    'fr': 'Notez-Nous',
    'de': 'Bewerten Sie Uns',
    'it': 'Valutaci',
    'pt': 'Avalie-nos',
    'ru': 'Оцените Нас',
    'ja': '評価する',
    'ko': '평가하기',
    'hi': 'हमें रेट करें',
  });

  String get faq => _t({
    'en': 'F.A.Q.',
    'tr': 'S.S.S.',
    'es': 'P.F.R.',
    'fr': 'F.A.Q.',
    'de': 'H.A.F.',
    'it': 'D.F.R.',
    'pt': 'P.F.',
    'ru': 'Ч.В.О.',
    'ja': 'よくある質問',
    'ko': '자주 묻는 질문',
    'hi': 'अक्सर पूछे जाने वाले प्रश्न',
  });

  String get logOut => _t({
    'en': 'Log Out',
    'tr': 'Çıkış Yap',
    'es': 'Cerrar Sesión',
    'fr': 'Se Déconnecter',
    'de': 'Abmelden',
    'it': 'Disconnettersi',
    'pt': 'Sair',
    'ru': 'Выйти',
    'ja': 'ログアウト',
    'ko': '로그아웃',
    'hi': 'लॉग आउट',
  });

  String get freeVersion => _t({
    'en': 'Free Version',
    'tr': 'Ücretsiz Sürüm',
    'es': 'Versión Gratuita',
    'fr': 'Version Gratuite',
    'de': 'Kostenlose Version',
    'it': 'Versione Gratuita',
    'pt': 'Versão Gratuita',
    'ru': 'Бесплатная Версия',
    'ja': '無料版',
    'ko': '무료 버전',
    'hi': 'मुफ़्त संस्करण',
  });

  String get statDayStreak => _t({
    'en': 'DAY\nSTREAK',
    'tr': 'GÜN\nSERİSİ',
    'es': 'RACHA\nDIARIA',
    'fr': 'SÉRIE\nDU JOUR',
    'de': 'TAGES\nSTREAK',
    'it': 'SERIE\nDEL GIORNO',
    'pt': 'SEQUÊNCIA\nDIÁRIA',
    'ru': 'СЕРИЯ\nДНЕЙ',
    'ja': '連続\n日数',
    'ko': '연속\n일수',
    'hi': 'दैनिक\nसिलसिला',
  });

  String get statWordsLearned => _t({
    'en': 'WORDS\nLEARNED',
    'tr': 'ÖĞRENILEN\nKELİMELER',
    'es': 'PALABRAS\nAPRENDIDAS',
    'fr': 'MOTS\nAPPRIS',
    'de': 'GELERNTE\nWÖRTER',
    'it': 'PAROLE\nAPPRESE',
    'pt': 'PALAVRAS\nAPRENDIDAS',
    'ru': 'ИЗУЧЕННЫХ\nСЛОВ',
    'ja': '学習した\n単語',
    'ko': '학습한\n단어',
    'hi': 'सीखे गए\nशब्द',
  });

  String get statProgress => _t({
    'en': 'PROGRESS',
    'tr': 'İLERLEME',
    'es': 'PROGRESO',
    'fr': 'PROGRÈS',
    'de': 'FORTSCHRITT',
    'it': 'PROGRESSO',
    'pt': 'PROGRESSO',
    'ru': 'ПРОГРЕСС',
    'ja': '進捗',
    'ko': '진행도',
    'hi': 'प्रगति',
  });

  // ─── Profile Settings ──────────────────────────────────────────────────────
  String get fullName => _t({
    'en': 'Full Name',
    'tr': 'Ad Soyad',
    'es': 'Nombre Completo',
    'fr': 'Nom Complet',
    'de': 'Vollständiger Name',
    'it': 'Nome Completo',
    'pt': 'Nome Completo',
    'ru': 'Полное Имя',
    'ja': '氏名',
    'ko': '전체 이름',
    'hi': 'पूरा नाम',
  });

  String get enterYourName => _t({
    'en': 'Enter your name',
    'tr': 'Adınızı girin',
    'es': 'Ingresa tu nombre',
    'fr': 'Entrez votre nom',
    'de': 'Geben Sie Ihren Namen ein',
    'it': 'Inserisci il tuo nome',
    'pt': 'Digite seu nome',
    'ru': 'Введите ваше имя',
    'ja': '名前を入力してください',
    'ko': '이름을 입력하세요',
    'hi': 'अपना नाम दर्ज करें',
  });

  String get email => _t({
    'en': 'E-mail',
    'tr': 'E-posta',
    'es': 'Correo Electrónico',
    'fr': 'E-mail',
    'de': 'E-Mail',
    'it': 'E-mail',
    'pt': 'E-mail',
    'ru': 'Эл. почта',
    'ja': 'メール',
    'ko': '이메일',
    'hi': 'ईमेल',
  });

  String get enterYourEmail => _t({
    'en': 'Enter your email',
    'tr': 'E-postanızı girin',
    'es': 'Ingresa tu correo',
    'fr': 'Entrez votre email',
    'de': 'Geben Sie Ihre E-Mail ein',
    'it': 'Inserisci la tua email',
    'pt': 'Digite seu e-mail',
    'ru': 'Введите ваш email',
    'ja': 'メールアドレスを入力',
    'ko': '이메일을 입력하세요',
    'hi': 'अपना ईमेल दर्ज करें',
  });

  String get age => _t({
    'en': 'Age',
    'tr': 'Yaş',
    'es': 'Edad',
    'fr': 'Âge',
    'de': 'Alter',
    'it': 'Età',
    'pt': 'Idade',
    'ru': 'Возраст',
    'ja': '年齢',
    'ko': '나이',
    'hi': 'उम्र',
  });

  String get enterYourAge => _t({
    'en': 'Enter your age',
    'tr': 'Yaşınızı girin',
    'es': 'Ingresa tu edad',
    'fr': 'Entrez votre âge',
    'de': 'Geben Sie Ihr Alter ein',
    'it': 'Inserisci la tua età',
    'pt': 'Digite sua idade',
    'ru': 'Введите ваш возраст',
    'ja': '年齢を入力してください',
    'ko': '나이를 입력하세요',
    'hi': 'अपनी उम्र दर्ज करें',
  });

  String get gender => _t({
    'en': 'Gender',
    'tr': 'Cinsiyet',
    'es': 'Género',
    'fr': 'Genre',
    'de': 'Geschlecht',
    'it': 'Genere',
    'pt': 'Gênero',
    'ru': 'Пол',
    'ja': '性別',
    'ko': '성별',
    'hi': 'लिंग',
  });

  String get male => _t({
    'en': 'Male',
    'tr': 'Erkek',
    'es': 'Masculino',
    'fr': 'Homme',
    'de': 'Männlich',
    'it': 'Maschio',
    'pt': 'Masculino',
    'ru': 'Мужской',
    'ja': '男性',
    'ko': '남성',
    'hi': 'पुरुष',
  });

  String get female => _t({
    'en': 'Female',
    'tr': 'Kadın',
    'es': 'Femenino',
    'fr': 'Femme',
    'de': 'Weiblich',
    'it': 'Femmina',
    'pt': 'Feminino',
    'ru': 'Женский',
    'ja': '女性',
    'ko': '여성',
    'hi': 'महिला',
  });

  String get selectLearnLanguage => _t({
    'en': 'Select Learn Language',
    'tr': 'Öğrenmek İstediğiniz Dili Seçin',
    'es': 'Seleccionar Idioma a Aprender',
    'fr': 'Sélectionner la Langue à Apprendre',
    'de': 'Lernsprache Auswählen',
    'it': 'Seleziona Lingua da Imparare',
    'pt': 'Selecionar Idioma para Aprender',
    'ru': 'Выбрать Язык для Изучения',
    'ja': '学習言語を選択',
    'ko': '학습 언어 선택',
    'hi': 'सीखने की भाषा चुनें',
  });

  String get changePhoto => _t({
    'en': 'Change Photo',
    'tr': 'Fotoğrafı Değiştir',
    'es': 'Cambiar Foto',
    'fr': 'Changer la Photo',
    'de': 'Foto Ändern',
    'it': 'Cambia Foto',
    'pt': 'Alterar Foto',
    'ru': 'Изменить Фото',
    'ja': '写真を変更',
    'ko': '사진 변경',
    'hi': 'फोटो बदलें',
  });

  String get saveChanges => _t({
    'en': 'Save Changes',
    'tr': 'Değişiklikleri Kaydet',
    'es': 'Guardar Cambios',
    'fr': 'Enregistrer les Modifications',
    'de': 'Änderungen Speichern',
    'it': 'Salva le Modifiche',
    'pt': 'Salvar Alterações',
    'ru': 'Сохранить Изменения',
    'ja': '変更を保存',
    'ko': '변경 사항 저장',
    'hi': 'परिवर्तन सहेजें',
  });

  String get profileUpdated => _t({
    'en': 'Profile updated successfully',
    'tr': 'Profil başarıyla güncellendi',
    'es': 'Perfil actualizado con éxito',
    'fr': 'Profil mis à jour avec succès',
    'de': 'Profil erfolgreich aktualisiert',
    'it': 'Profilo aggiornato con successo',
    'pt': 'Perfil atualizado com sucesso',
    'ru': 'Профиль успешно обновлен',
    'ja': 'プロフィールが正常に更新されました',
    'ko': '프로필이 성공적으로 업데이트되었습니다',
    'hi': 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई',
  });

  String get failedToUpdate => _t({
    'en': 'Failed to update profile. Please try again.',
    'tr': 'Profil güncellenemedi. Lütfen tekrar deneyin.',
    'es': 'Error al actualizar el perfil. Inténtalo de nuevo.',
    'fr': 'Échec de la mise à jour. Veuillez réessayer.',
    'de': 'Aktualisierung fehlgeschlagen. Bitte erneut versuchen.',
    'it': 'Impossibile aggiornare il profilo. Riprova.',
    'pt': 'Falha ao atualizar o perfil. Tente novamente.',
    'ru': 'Не удалось обновить профиль. Попробуйте снова.',
    'ja': 'プロフィールの更新に失敗しました。もう一度お試しください。',
    'ko': '프로필 업데이트에 실패했습니다. 다시 시도하세요.',
    'hi': 'प्रोफ़ाइल अपडेट करने में विफल। कृपया पुनः प्रयास करें।',
  });

  // ─── App Language View ─────────────────────────────────────────────────────
  String get appLanguageViewTitle => _t({
    'en': 'App Language',
    'tr': 'Uygulama Dili',
    'es': 'Idioma de la App',
    'fr': 'Langue de l\'Application',
    'de': 'App-Sprache',
    'it': 'Lingua dell\'App',
    'pt': 'Idioma do Aplicativo',
    'ru': 'Язык Приложения',
    'ja': 'アプリの言語',
    'ko': '앱 언어',
    'hi': 'ऐप भाषा',
  });

  String get appLanguageViewSubtitle => _t({
    'en': 'Select the application\nlanguage',
    'tr': 'Uygulama dilini\nseçin',
    'es': 'Selecciona el idioma\nde la aplicación',
    'fr': 'Sélectionnez la langue\nde l\'application',
    'de': 'Wählen Sie die\nApp-Sprache aus',
    'it': 'Seleziona la lingua\ndell\'applicazione',
    'pt': 'Selecione o idioma\ndo aplicativo',
    'ru': 'Выберите язык\nприложения',
    'ja': 'アプリの言語を\n選択してください',
    'ko': '앱 언어를\n선택하세요',
    'hi': 'एप्लिकेशन भाषा\nचुनें',
  });

  // ─── Library ───────────────────────────────────────────────────────────────
  String get yourCollection => _t({
    'en': 'YOUR COLLECTION',
    'tr': 'KOLEKSİYONUNUZ',
    'es': 'TU COLECCIÓN',
    'fr': 'VOTRE COLLECTION',
    'de': 'IHRE SAMMLUNG',
    'it': 'LA TUA COLLEZIONE',
    'pt': 'SUA COLEÇÃO',
    'ru': 'ВАША КОЛЛЕКЦИЯ',
    'ja': 'あなたのコレクション',
    'ko': '나의 컬렉션',
    'hi': 'आपका संग्रह',
  });

  String get myLibrary => _t({
    'en': 'My Library',
    'tr': 'Kütüphanem',
    'es': 'Mi Biblioteca',
    'fr': 'Ma Bibliothèque',
    'de': 'Meine Bibliothek',
    'it': 'La Mia Libreria',
    'pt': 'Minha Biblioteca',
    'ru': 'Моя Библиотека',
    'ja': 'マイライブラリ',
    'ko': '내 라이브러리',
    'hi': 'मेरी लाइब्रेरी',
  });

  String get folders => _t({
    'en': 'Folders',
    'tr': 'Klasörler',
    'es': 'Carpetas',
    'fr': 'Dossiers',
    'de': 'Ordner',
    'it': 'Cartelle',
    'pt': 'Pastas',
    'ru': 'Папки',
    'ja': 'フォルダ',
    'ko': '폴더',
    'hi': 'फ़ोल्डर',
  });

  String get noFoldersYet => _t({
    'en': 'No folders yet',
    'tr': 'Henüz klasör yok',
    'es': 'Aún no hay carpetas',
    'fr': 'Aucun dossier pour l\'instant',
    'de': 'Noch keine Ordner',
    'it': 'Nessuna cartella ancora',
    'pt': 'Sem pastas ainda',
    'ru': 'Пока нет папок',
    'ja': 'まだフォルダがありません',
    'ko': '아직 폴더가 없습니다',
    'hi': 'अभी तक कोई फ़ोल्डर नहीं',
  });

  String get retry => _t({
    'en': 'Retry',
    'tr': 'Tekrar Dene',
    'es': 'Reintentar',
    'fr': 'Réessayer',
    'de': 'Erneut versuchen',
    'it': 'Riprova',
    'pt': 'Tentar novamente',
    'ru': 'Повторить',
    'ja': '再試行',
    'ko': '다시 시도',
    'hi': 'पुनः प्रयास करें',
  });

  String get items => _t({
    'en': 'items',
    'tr': 'öğe',
    'es': 'elementos',
    'fr': 'éléments',
    'de': 'Elemente',
    'it': 'elementi',
    'pt': 'itens',
    'ru': 'элементов',
    'ja': '項目',
    'ko': '항목',
    'hi': 'आइटम',
  });

  // ─── Travel Vocabulary ─────────────────────────────────────────────────────
  String get travelVocabulary => _t({
    'en': 'Travel Vocabulary',
    'tr': 'Seyahat Sözlüğü',
    'es': 'Vocabulario de Viaje',
    'fr': 'Vocabulaire de Voyage',
    'de': 'Reisevokabular',
    'it': 'Vocabolario di Viaggio',
    'pt': 'Vocabulário de Viagem',
    'ru': 'Словарь путешественника',
    'ja': '旅行ボキャブラリー',
    'ko': '여행 어휘',
    'hi': 'यात्रा शब्दावली',
  });

  String get words => _t({
    'en': 'Words',
    'tr': 'Kelimeler',
    'es': 'Palabras',
    'fr': 'Mots',
    'de': 'Wörter',
    'it': 'Parole',
    'pt': 'Palavras',
    'ru': 'Слова',
    'ja': '単語',
    'ko': '단어',
    'hi': 'शब्द',
  });

  String get phrases => _t({
    'en': 'Phrases',
    'tr': 'İfadeler',
    'es': 'Frases',
    'fr': 'Phrases',
    'de': 'Phrasen',
    'it': 'Frasi',
    'pt': 'Frases',
    'ru': 'Фразы',
    'ja': 'フレーズ',
    'ko': '문구',
    'hi': 'वाक्यांश',
  });

  String get allTopics => _t({
    'en': 'All Topics',
    'tr': 'Tüm Konular',
    'es': 'Todos los Temas',
    'fr': 'Tous les Sujets',
    'de': 'Alle Themen',
    'it': 'Tutti gli Argomenti',
    'pt': 'Todos os Tópicos',
    'ru': 'Все Темы',
    'ja': 'すべてのトピック',
    'ko': '모든 주제',
    'hi': 'सभी विषय',
  });

  String get searchWords => _t({
    'en': 'Search words...',
    'tr': 'Kelime ara...',
    'es': 'Buscar palabras...',
    'fr': 'Rechercher des mots...',
    'de': 'Wörter suchen...',
    'it': 'Cerca parole...',
    'pt': 'Pesquisar palavras...',
    'ru': 'Поиск слов...',
    'ja': '単語を検索...',
    'ko': '단어 검색...',
    'hi': 'शब्द खोजें...',
  });

  String get searchPhrases => _t({
    'en': 'Search phrases...',
    'tr': 'İfade ara...',
    'es': 'Buscar frases...',
    'fr': 'Rechercher des phrases...',
    'de': 'Phrasen suchen...',
    'it': 'Cerca frasi...',
    'pt': 'Pesquisar frases...',
    'ru': 'Поиск фраз...',
    'ja': 'フレーズを検索...',
    'ko': '문구 검색...',
    'hi': 'वाक्यांश खोजें...',
  });

  String get loadMore => _t({
    'en': '+ Load More',
    'tr': '+ Daha Fazla Yükle',
    'es': '+ Cargar Más',
    'fr': '+ Charger Plus',
    'de': '+ Mehr Laden',
    'it': '+ Carica di più',
    'pt': '+ Carregar Mais',
    'ru': '+ Загрузить ещё',
    'ja': '+ さらに読み込む',
    'ko': '+ 더 불러오기',
    'hi': '+ और लोड करें',
  });

  // ─── Home Features ─────────────────────────────────────────────────────────
  String get features => _t({
    'en': 'Features',
    'tr': 'Özellikler',
    'es': 'Características',
    'fr': 'Fonctionnalités',
    'de': 'Funktionen',
    'it': 'Funzionalità',
    'pt': 'Recursos',
    'ru': 'Возможности',
    'ja': '機能',
    'ko': '기능',
    'hi': 'सुविधाएं',
  });

  String get swipeToStart => _t({
    'en': 'SWIPE TO START',
    'tr': 'BAŞLAMAK İÇİN KAYDIRIN',
    'es': 'DESLIZA PARA COMENZAR',
    'fr': 'GLISSER POUR COMMENCER',
    'de': 'ZUM STARTEN WISCHEN',
    'it': 'SCORRI PER INIZIARE',
    'pt': 'DESLIZE PARA COMEÇAR',
    'ru': 'ПРОВЕДИТЕ ДЛЯ НАЧАЛА',
    'ja': 'スワイプして開始',
    'ko': '시작하려면 스와이프',
    'hi': 'शुरू करने के लिए स्वाइप करें',
  });

  String get featureLearnSentence => _t({
    'en': 'Learn New\nSentence',
    'tr': 'Yeni Cümle\nÖğren',
    'es': 'Aprende una\nNueva Frase',
    'fr': 'Apprendre une\nNouvelle Phrase',
    'de': 'Neuen Satz\nLernen',
    'it': 'Impara una\nNuova Frase',
    'pt': 'Aprender uma\nNova Frase',
    'ru': 'Новое\nПредложение',
    'ja': '新しい文を\n学ぶ',
    'ko': '새 문장\n배우기',
    'hi': 'नया वाक्य\nसीखें',
  });

  String get featureDailyConversation => _t({
    'en': 'Daily Conversation',
    'tr': 'Günlük Konuşma',
    'es': 'Conversación Diaria',
    'fr': 'Conversation Quotidienne',
    'de': 'Tägliches Gespräch',
    'it': 'Conversazione Quotidiana',
    'pt': 'Conversa Diária',
    'ru': 'Ежедневный Диалог',
    'ja': '日常会話',
    'ko': '일상 대화',
    'hi': 'दैनिक वार्तालाप',
  });

  String get featureLearnWords => _t({
    'en': 'Learn New\nWords',
    'tr': 'Yeni Kelime\nÖğren',
    'es': 'Aprende Nuevas\nPalabras',
    'fr': 'Apprendre de\nNouveaux Mots',
    'de': 'Neue Wörter\nLernen',
    'it': 'Impara Nuove\nParole',
    'pt': 'Aprender Novas\nPalavras',
    'ru': 'Новые\nСлова',
    'ja': '新しい単語を\n学ぶ',
    'ko': '새 단어\n배우기',
    'hi': 'नए शब्द\nसीखें',
  });

  String get featureQuickLearn => _t({
    'en': 'Quick Learn',
    'tr': 'Hızlı Öğren',
    'es': 'Aprendizaje Rápido',
    'fr': 'Apprentissage Rapide',
    'de': 'Schnell Lernen',
    'it': 'Apprendimento Rapido',
    'pt': 'Aprendizagem Rápida',
    'ru': 'Быстрое Обучение',
    'ja': 'クイック学習',
    'ko': '빠른 학습',
    'hi': 'त्वरित सीखना',
  });

  // ─── Quick Actions ──────────────────────────────────────────────────────────
  String get quickActionPractice => _t({
    'en': 'Practice',
    'tr': 'Pratik Yap',
    'es': 'Practicar',
    'fr': 'Pratiquer',
    'de': 'Üben',
    'it': 'Pratica',
    'pt': 'Praticar',
    'ru': 'Практика',
    'ja': '練習',
    'ko': '연습',
    'hi': 'अभ्यास',
  });

  String get quickActionVocabulary => _t({
    'en': 'Vocabulary',
    'tr': 'Kelime Hazinesi',
    'es': 'Vocabulario',
    'fr': 'Vocabulaire',
    'de': 'Vokabular',
    'it': 'Vocabolario',
    'pt': 'Vocabulário',
    'ru': 'Словарный запас',
    'ja': '語彙',
    'ko': '어휘',
    'hi': 'शब्द भंडार',
  });

  String get quickActionGrammar => _t({
    'en': 'Grammar',
    'tr': 'Dilbilgisi',
    'es': 'Gramática',
    'fr': 'Grammaire',
    'de': 'Grammatik',
    'it': 'Grammatica',
    'pt': 'Gramática',
    'ru': 'Грамматика',
    'ja': '文法',
    'ko': '문법',
    'hi': 'व्याकरण',
  });

  String get quickActionListening => _t({
    'en': 'Listening',
    'tr': 'Dinleme',
    'es': 'Escucha',
    'fr': 'Écoute',
    'de': 'Zuhören',
    'it': 'Ascolto',
    'pt': 'Escuta',
    'ru': 'Аудирование',
    'ja': 'リスニング',
    'ko': '듣기',
    'hi': 'सुनना',
  });

  // ─── Cancel ────────────────────────────────────────────────────────────────
  String get cancel => _t({
    'en': 'Cancel',
    'tr': 'İptal',
    'es': 'Cancelar',
    'fr': 'Annuler',
    'de': 'Abbrechen',
    'it': 'Annulla',
    'pt': 'Cancelar',
    'ru': 'Отмена',
    'ja': 'キャンセル',
    'ko': '취소',
    'hi': 'रद्द करें',
  });

  // ─── Visual Dictionary Category Names ──────────────────────────────────────
  String get catAirport => _t({
    'en': 'Airport',
    'tr': 'Havalimanı',
    'es': 'Aeropuerto',
    'fr': 'Aéroport',
    'de': 'Flughafen',
    'it': 'Aeroporto',
    'pt': 'Aeroporto',
    'ru': 'Аэропорт',
    'ja': '空港',
    'ko': '공항',
    'hi': 'हवाई अड्डा',
  });

  String get catAccommodation => _t({
    'en': 'Accommodation',
    'tr': 'Konaklama',
    'es': 'Alojamiento',
    'fr': 'Hébergement',
    'de': 'Unterkunft',
    'it': 'Alloggio',
    'pt': 'Alojamento',
    'ru': 'Проживание',
    'ja': '宿泊',
    'ko': '숙박',
    'hi': 'आवास',
  });

  String get catTransportation => _t({
    'en': 'Transportation',
    'tr': 'Ulaşım',
    'es': 'Transporte',
    'fr': 'Transport',
    'de': 'Transport',
    'it': 'Trasporti',
    'pt': 'Transporte',
    'ru': 'Транспорт',
    'ja': '交通',
    'ko': '교통',
    'hi': 'परिवहन',
  });

  String get catFoodAndDrink => _t({
    'en': 'Food & Drink',
    'tr': 'Yiyecek & İçecek',
    'es': 'Comida y Bebida',
    'fr': 'Nourriture et Boissons',
    'de': 'Essen & Trinken',
    'it': 'Cibo e Bevande',
    'pt': 'Comida e Bebida',
    'ru': 'Еда и Напитки',
    'ja': 'フード＆ドリンク',
    'ko': '음식 & 음료',
    'hi': 'खाना और पेय',
  });

  String get catShopping => _t({
    'en': 'Shopping',
    'tr': 'Alışveriş',
    'es': 'Compras',
    'fr': 'Shopping',
    'de': 'Einkaufen',
    'it': 'Shopping',
    'pt': 'Compras',
    'ru': 'Шопинг',
    'ja': 'ショッピング',
    'ko': '쇼핑',
    'hi': 'खरีदारी',
  });

  String get catCulture => _t({
    'en': 'Culture',
    'tr': 'Kültür',
    'es': 'Cultura',
    'fr': 'Culture',
    'de': 'Kultur',
    'it': 'Cultura',
    'pt': 'Cultura',
    'ru': 'Культура',
    'ja': '文化',
    'ko': '문화',
    'hi': 'संस्कृति',
  });

  String get catMeeting => _t({
    'en': 'Meeting',
    'tr': 'Toplantı',
    'es': 'Reunión',
    'fr': 'Réunion',
    'de': 'Treffen',
    'it': 'Riunione',
    'pt': 'Reunião',
    'ru': 'Встреча',
    'ja': 'ミーティング',
    'ko': '회의',
    'hi': 'बैठक',
  });

  String get catSport => _t({
    'en': 'Sport',
    'tr': 'Spor',
    'es': 'Deporte',
    'fr': 'Sport',
    'de': 'Sport',
    'it': 'Sport',
    'pt': 'Esporte',
    'ru': 'Спорт',
    'ja': 'スポーツ',
    'ko': '스포츠',
    'hi': 'खेल',
  });

  String get catHealth => _t({
    'en': 'Health',
    'tr': 'Sağlık',
    'es': 'Salud',
    'fr': 'Santé',
    'de': 'Gesundheit',
    'it': 'Salute',
    'pt': 'Saúde',
    'ru': 'Здоровье',
    'ja': '健康',
    'ko': '건강',
    'hi': 'स्वास्थ्य',
  });

  String get catBusiness => _t({
    'en': 'Business',
    'tr': 'İş Dünyası',
    'es': 'Negocios',
    'fr': 'Affaires',
    'de': 'Geschäft',
    'it': 'Affari',
    'pt': 'Negócios',
    'ru': 'Бизнес',
    'ja': 'ビジネス',
    'ko': '비즈니스',
    'hi': 'व्यापार',
  });

  String get catTrip => _t({
    'en': 'Trip',
    'tr': 'Gezi',
    'es': 'Viaje',
    'fr': 'Voyage',
    'de': 'Reise',
    'it': 'Viaggio',
    'pt': 'Viagem',
    'ru': 'Поездка',
    'ja': '旅行',
    'ko': '여행',
    'hi': 'यात्रा',
  });

  String get catShop => _t({
    'en': 'Shop',
    'tr': 'Alışveriş',
    'es': 'Tienda',
    'fr': 'Boutique',
    'de': 'Geschäft',
    'it': 'Negozio',
    'pt': 'Loja',
    'ru': 'Магазин',
    'ja': '店',
    'ko': '가게',
    'hi': 'दुकान',
  });

  String get catDirection => _t({
    'en': 'Direction & Navigation',
    'tr': 'Yön & Navigasyon',
    'es': 'Dirección y Navegación',
    'fr': 'Direction et Navigation',
    'de': 'Richtung & Navigation',
    'it': 'Direzione e Navigazione',
    'pt': 'Direção e Navegação',
    'ru': 'Направление и Навигация',
    'ja': '方向とナビゲーション',
    'ko': '방향 및 내비게이션',
    'hi': 'दिशा और नेविगेशन',
  });

  String get catEmergency => _t({
    'en': 'Emergency',
    'tr': 'Acil Durum',
    'es': 'Emergencia',
    'fr': 'Urgence',
    'de': 'Notfall',
    'it': 'Emergenza',
    'pt': 'Emergência',
    'ru': 'Чрезвычайная ситуация',
    'ja': '緊急',
    'ko': '긴급',
    'hi': 'आपातकालीन',
  });

  String get catGeneral => _t({
    'en': 'General',
    'tr': 'Genel',
    'es': 'General',
    'fr': 'Général',
    'de': 'Allgemein',
    'it': 'Generale',
    'pt': 'Geral',
    'ru': 'Общее',
    'ja': '一般',
    'ko': '일반',
    'hi': 'सामान्य',
  });

  // ─── Visual Dictionary ─────────────────────────────────────────────────────
  String get visualDictionary => _t({
    'en': 'Visual Dictionary',
    'tr': 'Görsel Sözlük',
    'es': 'Diccionario Visual',
    'fr': 'Dictionnaire Visuel',
    'de': 'Visuelles Wörterbuch',
    'it': 'Dizionario Visuale',
    'pt': 'Dicionário Visual',
    'ru': 'Визуальный Словарь',
    'ja': 'ビジュアル辞書',
    'ko': '시각적 사전',
    'hi': 'दृश्य शब्दकोश',
  });

  String get translatedItemsCount => _t({
    'en': '20,000+ Translated Items',
    'tr': '20.000+ Çevrilmiş Öğe',
    'es': '20.000+ Elementos Traducidos',
    'fr': '20 000+ Éléments Traduits',
    'de': '20.000+ Übersetzte Elemente',
    'it': '20.000+ Elementi Tradotti',
    'pt': '20.000+ Itens Traduzidos',
    'ru': '20 000+ Переведённых Элементов',
    'ja': '20,000以上の翻訳アイテム',
    'ko': '20,000개 이상 번역 항목',
    'hi': '20,000+ अनुवादित आइटम',
  });

  String get searchWordsOrPhrases => _t({
    'en': 'Search words or phrases...',
    'tr': 'Kelime veya ifade ara...',
    'es': 'Buscar palabras o frases...',
    'fr': 'Rechercher des mots ou des phrases...',
    'de': 'Wörter oder Phrasen suchen...',
    'it': 'Cerca parole o frasi...',
    'pt': 'Pesquisar palavras ou frases...',
    'ru': 'Поиск слов или фраз...',
    'ja': '単語やフレーズを検索...',
    'ko': '단어 또는 문구 검색...',
    'hi': 'शब्द या वाक्यांश खोजें...',
  });

  String get noCategoriesFound => _t({
    'en': 'No categories found',
    'tr': 'Kategori bulunamadı',
    'es': 'No se encontraron categorías',
    'fr': 'Aucune catégorie trouvée',
    'de': 'Keine Kategorien gefunden',
    'it': 'Nessuna categoria trovata',
    'pt': 'Nenhuma categoria encontrada',
    'ru': 'Категории не найдены',
    'ja': 'カテゴリーが見つかりません',
    'ko': '카테고리를 찾을 수 없습니다',
    'hi': 'कोई श्रेणी नहीं मिली',
  });

  String get tryDifferentKeywords => _t({
    'en': 'Try searching with different keywords',
    'tr': 'Farklı anahtar kelimelerle arayın',
    'es': 'Prueba a buscar con palabras clave diferentes',
    'fr': 'Essayez de rechercher avec des mots-clés différents',
    'de': 'Versuchen Sie, mit anderen Schlüsselwörtern zu suchen',
    'it': 'Prova a cercare con parole chiave diverse',
    'pt': 'Tente pesquisar com palavras-chave diferentes',
    'ru': 'Попробуйте поиск с другими ключевыми словами',
    'ja': '別のキーワードで検索してみてください',
    'ko': '다른 키워드로 검색해 보세요',
    'hi': 'अलग कीवर्ड से खोजने का प्रयास करें',
  });

  String get recentSearch => _t({
    'en': 'Recent Search',
    'tr': 'Son Aramalar',
    'es': 'Búsqueda Reciente',
    'fr': 'Recherche Récente',
    'de': 'Letzte Suche',
    'it': 'Ricerca Recente',
    'pt': 'Pesquisa Recente',
    'ru': 'Недавний Поиск',
    'ja': '最近の検索',
    'ko': '최근 검색',
    'hi': 'हाल की खोज',
  });

  String get clearText => _t({
    'en': 'Clear',
    'tr': 'Temizle',
    'es': 'Limpiar',
    'fr': 'Effacer',
    'de': 'Löschen',
    'it': 'Cancella',
    'pt': 'Limpar',
    'ru': 'Очистить',
    'ja': 'クリア',
    'ko': '지우기',
    'hi': 'साफ़ करें',
  });

  String itemsCount(int count) => _t({
    'en': '$count items',
    'tr': '$count öğe',
    'es': '$count elementos',
    'fr': '$count éléments',
    'de': '$count Elemente',
    'it': '$count elementi',
    'pt': '$count itens',
    'ru': '$count элементов',
    'ja': '$count アイテム',
    'ko': '$count 항목',
    'hi': '$count आइटम',
  });

  String get noWordsFound => _t({
    'en': 'No words found',
    'tr': 'Kelime bulunamadı',
    'es': 'No se encontraron palabras',
    'fr': 'Aucun mot trouvé',
    'de': 'Keine Wörter gefunden',
    'it': 'Nessuna parola trovata',
    'pt': 'Nenhuma palavra encontrada',
    'ru': 'Слова не найдены',
    'ja': '単語が見つかりません',
    'ko': '단어를 찾을 수 없습니다',
    'hi': 'कोई शब्द नहीं मिला',
  });

  String get recentItem => _t({
    'en': 'Recent item',
    'tr': 'Son öğe',
    'es': 'Elemento reciente',
    'fr': 'Élément récent',
    'de': 'Zuletzt gesehen',
    'it': 'Elemento recente',
    'pt': 'Item recente',
    'ru': 'Недавний элемент',
    'ja': '最近の項目',
    'ko': '최근 항목',
    'hi': 'हाल का आइटम',
  });

  String _t(Map<String, String> translations) {
    return translations[langCode] ?? translations['en'] ?? '';
  }
}
