# Check if NodeJS is installed
if ( ! command -v -- "node" > /dev/null; ) then
  echo "-----> Missing NodeJS :("
  exit 127 # command not found
fi

echo "-----> Installing dependencies"
npm i --silent

echo "-----> Executing setup.mjs"
npx zx ./setup.mjs
