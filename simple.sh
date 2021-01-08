#!/bin/bash 

echo === report.toml ===
cat report.toml
echo === ===

set -x
git init t1
touch t1/pgpass

git -C ./t1/ add pgpass
./gitleaks.7.2.0 --leaks-exit-code=1 --config-path=./report.toml --path=./t1/  --unstaged --verbose
echo $?


./gitleaks.6.2.0 --config=./report.toml --repo-path=./t1/ --uncommitted
echo $?

/bin/rm -rf ./t1/
set +x
