# shellcheck shell=sh
ERROR_COUNT=0
# Install the ESLint node modules
if [ "$SETUP_FROM_PACKAGE_JSON" == 'true' ]; then
    # Due to issues about installing only devDependencies we install all the packages - https://github.com/npm/cli/issues/1669
    npm install
else
    npm install eslint@"$ESLINT_VERSION"
fi
# Now either run the full analysis or files changed based on the settings defined
if [ "$ANALYSE_ALL_CODE" == 'true' ]; then
    node_modules/.bin/eslint -c "$RULES_PATH" -f json "$FILE_PATH" > eslint-output.json
else
    # Generate a one line string with all the file names separated with a space
    FILES_CHANGED="$(git diff --name-only --diff-filter=d origin/"$TARGET_BRANCH"..origin/"${SOURCE_BRANCH#"refs/heads/"}" | grep -E ".js$|.jsx$|.ts$|.tsx$" | xargs)"
    # Run the analysis
    node_modules/.bin/eslint -c "$RULES_PATH" -f json $FILES_CHANGED > eslint-output.json
fi
# Loop through each file and then loop through each violation identified
 while read -r file; do
    FILENAME="$(echo "$file" | jq --raw-output '.filePath | ltrimstr("${{ github.workspace }}/")')"
    while read -r violation; do
        MESSAGE="$(echo "$violation" | jq --raw-output '" \(.ruleId) - \(.message) For more information on this rule visit https://eslint.org/docs/rules/\(.ruleId)"')"
        LINE="$(echo "$violation" | jq --raw-output '.line')"
        COLUMN="$(echo "$violation" | jq --raw-output '.column')"
        SEVERITY="$(echo "$violation" | jq --raw-output '.severity')"
        if [ "$SEVERITY" -eq 2 ]; then
            echo ::error file="$FILENAME",line="$LINE",col="$COLUMN"::"$MESSAGE"
            ERROR_COUNT=$((ERROR_COUNT + 1))
        else
            echo ::warning file="$FILENAME",line="$LINE",col="$COLUMN"::"$MESSAGE"
        fi
    done <<< "$(echo "$file" | jq --compact-output '.messages[]')"
done <<< "$(cat eslint-output.json | jq --compact-output '.[]')"
# If there are any errors logged we want this to fail (warnings don't count)
if [ "$ERROR_COUNT" -gt 0 ]; then
    exit 1
fi