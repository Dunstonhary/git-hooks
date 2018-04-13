#!/bin/sh
FORBIDDEN='\console.\(log\|warn\)';
FILES_PATTERN=".*\(js\|jsx\)$";
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR war/source/v2.0 | grep $FILES_PATTERN)
ESLINT="$(git rev-parse --show-toplevel)/node_modules/.bin/eslint"

if [[ "$STAGED_FILES" = "" ]]; then
  exit 0
fi

PASS=true
echo "" 
echo "------Start->Validating for Console Statement------------"
   
echo $STAGED_FILES | GREP_COLOR='4;5;37;41' xargs grep --color --with-filename -n '\console.\(log\|warn\)'  && echo 'COMMIT REJECTED Found "$FORBIDDEN" references. Please remove them before commiting' && exit 1

echo "------Ends->Validating for Console Statement------------"
echo "" 
echo "------------------ESLint-Validation-Starts------------------------"
echo "\nValidating Javascript:\n"



# Check for eslint
if [[ ! -x "$ESLINT" ]]; then
  echo "\t\033[41mPlease install ESlint\033[0m (npm i --save-dev eslint)"
  exit 1
fi

for FILE in $STAGED_FILES
do
  
  "$ESLINT" "$FILE"
  if [[ "$?" == 0 ]]; then
    echo "\t\033[32mESLint Passed: $FILE\033[0m"
  else
    echo "\t\033[41mESLint Failed: $FILE\033[0m"
    PASS=false
  fi
done
echo ""

echo "---------------\nJavascript validation completed!\n---------------"
echo ""

if ! $PASS; then
  echo "\033[41mCOMMIT FAILED:\033[0m Your commit contains files that should pass ESLint but do not. Please fix the ESLint errors and try again.\n"
  exit 1
else
  echo "\033[42mCOMMIT SUCCEEDED\033[0m\n"
fi

exit $?
echo "------------------ESLint-Validation-Stops------------------------"
#exit
