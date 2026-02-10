// Quick Manual Seed Runner (if bash script doesn't work)
require('dotenv').config();
const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function runSeed() {
  console.log('\n==================================================');
  console.log('  Lingola Travel - Seed Data Installer (Node.js)');
  console.log('==================================================\n');

  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'lingola_travel',
    multipleStatements: true
  });

  try {
    console.log('✓ Connected to MySQL');

    // Read the seed file
    const seedFilePath = path.join(__dirname, 'migrations', '023_seed_all_sample_data.sql');
    const seedSQL = fs.readFileSync(seedFilePath, 'utf8');

    console.log('✓ Seed file loaded');
    console.log('\nExecuting seed data...\n');

    // Execute the seed file
    await connection.query(seedSQL);

    console.log('✓ Seed file executed successfully!\n');

    // Verification
    console.log('Verifying data...\n');

    const [courses] = await connection.query('SELECT COUNT(*) as count FROM courses');
    const [lessons] = await connection.query('SELECT COUNT(*) as count FROM lessons');
    const [lessonVocab] = await connection.query('SELECT COUNT(*) as count FROM lesson_vocabulary');
    const [dictCats] = await connection.query('SELECT COUNT(*) as count FROM dictionary_categories');
    const [dictWords] = await connection.query('SELECT COUNT(*) as count FROM dictionary_words');
    const [phrases] = await connection.query('SELECT COUNT(*) as count FROM travel_phrases');
    const [folders] = await connection.query('SELECT COUNT(*) as count FROM library_folders');
    const [users] = await connection.query('SELECT COUNT(*) as count FROM users WHERE email = "demo@lingola.com"');

    console.log('┌─────────────────────────┬────────┐');
    console.log('│ Table                   │ Count  │');
    console.log('├─────────────────────────┼────────┤');
    console.log(`│ ✓ Courses              │ ${courses[0].count.toString().padStart(6)} │`);
    console.log(`│ ✓ Lessons              │ ${lessons[0].count.toString().padStart(6)} │`);
    console.log(`│ ✓ Lesson Vocabulary    │ ${lessonVocab[0].count.toString().padStart(6)} │`);
    console.log(`│ ✓ Dictionary Categories│ ${dictCats[0].count.toString().padStart(6)} │`);
    console.log(`│ ✓ Dictionary Words     │ ${dictWords[0].count.toString().padStart(6)} │`);
    console.log(`│ ✓ Travel Phrases       │ ${phrases[0].count.toString().padStart(6)} │`);
    console.log(`│ ✓ Library Folders      │ ${folders[0].count.toString().padStart(6)} │`);
    console.log(`│ ✓ Demo Users           │ ${users[0].count.toString().padStart(6)} │`);
    console.log('└─────────────────────────┴────────┘');

    console.log('\n==================================================');
    console.log('  Seed Data Installation Complete!');
    console.log('==================================================\n');

    console.log('Sample data has been loaded:');
    console.log('  • 11 Courses');
    console.log('  • 36+ Lessons');
    console.log('  • 4 Lesson Vocabulary items');
    console.log('  • 10 Dictionary Categories');
    console.log('  • 102 Dictionary Words');
    console.log('  • 22 Travel Phrases');
    console.log('  • 10 Library Folders');
    console.log('  • 1 Demo User (demo@lingola.com)\n');

    console.log('Next steps:');
    console.log('  1. Start the backend server: npm start');
    console.log('  2. Test API endpoints with curl or Postman');
    console.log('  3. Check SEED_DATA_README.md for testing examples\n');

  } catch (error) {
    console.error('\n❌ Error executing seed file:');
    console.error(error.message);
    console.error('\nPlease check:');
    console.error('  1. MySQL is running');
    console.error('  2. Database "lingola_travel" exists');
    console.error('  3. All migration files (001-022) have been run');
    console.error('  4. .env file has correct DB credentials\n');
    process.exit(1);
  } finally {
    await connection.end();
  }
}

runSeed();
