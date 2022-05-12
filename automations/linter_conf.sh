#!bin/bash
# Program that creates a complete environment for eslint and prettier.
# Arguments are not required.

yarn init -y
yarn add -D eslint prettier eslint-config-prettier eslint-plugin-prettier
npx install-peerdeps --dev eslint-config-airbnb-base
touch .prettierrc
echo "{
  \"trailingComma\": \"es5\",
  \"tabWidth\": 2,
  \"semi\": true,
  \"singleQuote\": true
}" > .prettierrc
yarn run eslint --init
echo "-------"
echo "add => \"extends\": [\"airbnb-base\", \"plugin:prettier/recommended\"],"
echo "-------"
