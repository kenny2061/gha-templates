#!/bin/bash

if [ -f /usr/local/lib/init/mountGCPFilestore.sh ]; then /usr/local/lib/init/mountGCPFilestore.sh; fi
if [ -f initCustomScript.sh ]; then ./initCustomScript.sh "$@"; rm initCustomScript.sh; fi
if [ -f unsetEnvVars.sh ]; then command $(cat unsetEnvVars.sh); fi
if [ -f /usr/local/lib/init/generateEnvVarsToStaticFile.sh ]; then /usr/local/lib/init/generateEnvVarsToStaticFile.sh; fi

# Start the application

echo "Start lanuch apache"

/usr/local/bin/apache2-foreground "$@"
