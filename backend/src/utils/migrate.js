// Database Migration Utility
const fs = require('fs');
const path = require('path');
const { pool } = require('../config/database');

const MIGRATIONS_DIR = path.join(__dirname, '../../database/migrations');

/**
 * Run all migrations in order
 */
async function runMigrations() {
  try {
    console.log('🔄 Starting database migrations...\n');
    
    // Get all SQL files
    const files = fs.readdirSync(MIGRATIONS_DIR)
      .filter(file => file.endsWith('.sql'))
      .sort(); // Alphabetical order (001, 002, 003...)
    
    if (files.length === 0) {
      console.log('⚠️  No migration files found');
      return;
    }
    
    console.log(`Found ${files.length} migration files\n`);
    
    // Execute each migration
    for (const file of files) {
      console.log(`Executing: ${file}`);
      
      const filePath = path.join(MIGRATIONS_DIR, file);
      const sql = fs.readFileSync(filePath, 'utf8');
      
      // Split by semicolons (multiple statements)
      const statements = sql
        .split(';')
        .map(s => s.trim())
        .filter(s => s.length > 0 && !s.startsWith('--'));
      
      const connection = await pool.getConnection();
      
      try {
        for (const statement of statements) {
          if (statement) {
            await connection.query(statement);
          }
        }
        console.log(`✅ ${file} - Success\n`);
      } catch (error) {
        console.error(`❌ ${file} - Failed:`, error.message, '\n');
        throw error;
      } finally {
        connection.release();
      }
    }
    
    console.log('✅ All migrations completed successfully!\n');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run if called directly
if (require.main === module) {
  runMigrations();
}

module.exports = { runMigrations };
