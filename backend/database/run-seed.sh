#!/bin/bash
# Seed Data Runner Script
# This script runs the seed SQL file against the MySQL database

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Lingola Travel - Seed Data Installer${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if MySQL is running
if ! pgrep -x "mysqld" > /dev/null; then
    echo -e "${RED}Error: MySQL is not running!${NC}"
    echo "Please start MySQL first."
    exit 1
fi

echo -e "${GREEN}✓ MySQL is running${NC}"
echo ""

# Prompt for MySQL password
echo "Enter your MySQL root password:"
read -s MYSQL_PASSWORD

# Database name
DB_NAME="lingola_travel"

# Run the seed file
echo ""
echo -e "${BLUE}Running seed file...${NC}"

mysql -u root -p"$MYSQL_PASSWORD" "$DB_NAME" < database/migrations/023_seed_all_sample_data.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Seed file executed successfully!${NC}"
    echo ""
    
    # Verification
    echo -e "${BLUE}Verifying data...${NC}"
    echo ""
    
    mysql -u root -p"$MYSQL_PASSWORD" "$DB_NAME" <<EOF
SELECT 
    '✓ Courses' as Table_Name, 
    COUNT(*) as Record_Count 
FROM courses
UNION ALL
SELECT 
    '✓ Lessons', 
    COUNT(*) 
FROM lessons
UNION ALL
SELECT 
    '✓ Lesson Vocabulary', 
    COUNT(*) 
FROM lesson_vocabulary
UNION ALL
SELECT 
    '✓ Dictionary Categories', 
    COUNT(*) 
FROM dictionary_categories
UNION ALL
SELECT 
    '✓ Dictionary Words', 
    COUNT(*) 
FROM dictionary_words
UNION ALL
SELECT 
    '✓ Travel Phrases', 
    COUNT(*) 
FROM travel_phrases
UNION ALL
SELECT 
    '✓ Library Folders', 
    COUNT(*) 
FROM library_folders
UNION ALL
SELECT 
    '✓ Demo Users', 
    COUNT(*) 
FROM users 
WHERE email = 'demo@lingola.com';
EOF
    
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  Seed Data Installation Complete!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "Sample data has been loaded:"
    echo "  • 11 Courses"
    echo "  • 36+ Lessons"
    echo "  • 4 Lesson Vocabulary items"
    echo "  • 10 Dictionary Categories"
    echo "  • 102 Dictionary Words"
    echo "  • 22 Travel Phrases"
    echo "  • 10 Library Folders"
    echo "  • 1 Demo User (demo@lingola.com)"
    echo ""
    echo "Next steps:"
    echo "  1. Start the backend server: npm start"
    echo "  2. Test API endpoints with curl or Postman"
    echo "  3. Check SEED_DATA_README.md for testing examples"
    echo ""
else
    echo -e "${RED}Error: Seed file execution failed!${NC}"
    echo "Please check the error messages above."
    exit 1
fi
