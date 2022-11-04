# Check if NodeJS is installed
if ( command -v -- "node" > /dev/null; ) then
  echo "-----> NodeJS is already installed, awesome!"
else
  echo "-----> Missing NodeJS ☹️"
  exit 127 # command not found
fi

# Make sure we have ZX
if ( ! command -v -- "zx" > /dev/null; ) then
  echo "-----> Installing ZX"
  npm install -g --silent zx
fi

echo "-----> Executing setup.mjs"
zx ./setup.mjs
