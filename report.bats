#!/usr/bin/env bats
#
# To keep `make audit` runs short with `caulked.bats`, this file
# includes the rules for `allow`.  Also includes tests
# that only make sense during development on the 
# developers system

# Bug bounty folks: Any apparent keys or passwords are just test strings

# Running Tests:
#
#              bats development.bats

# v7 bugs: `[allowlist]...files` and `[[rules]].


BATS_TMPDIR=${BATS_TMPDIR:-/tmp}     # set default if sourcing from cli
REPO_PATH=$(mktemp -d "${BATS_TMPDIR}/gittest.XXXXXX")

setupGitRepo() {
    mkdir -p ${REPO_PATH}
    (cd $REPO_PATH && git init .)
}

cleanGitRepo() {
    rm -fr "${REPO_PATH}"
}

setup() {
    setupGitRepo
}

teardown() {
    cleanGitRepo
}

testCommit7() {
    ./gitleaks.7.2.0 --leaks-exit-code=1 --config-path=./report.toml --path=${REPO_PATH} --unstaged
}

testCommit6() {
    ./gitleaks.6.2.0 --config=./report.toml --repo-path=${REPO_PATH} --uncommitted
}

@test "detects an ipv4 pattern to show v7 generally works" {
    cat > $REPO_PATH/ipv4.txt <<END
"102.9.31.24"
END
    run testCommit7 $REPO_PATH
    [ ${status} -eq 1 ]
}

@test "version of 6.2.0" {
  run ./gitleaks.6.2.0 --version
  [  "${lines[0]}" = "v6.2.0" ]
}

@test "version of 7.2.0" {
  run ./gitleaks.7.2.0 --version
  [  "${lines[0]}" = "v7.2.0" ]
}


@test "ingore ipv4-ish in svg" {
    cat > $REPO_PATH/ok.svg <<END
"\u003csvg xmlns=\"http://www.w3.org/2000/svg\" d=\"M57.547 18.534a3.71 3.71 0 0 10.20.30.40 0-1.679-1.276 5.563 5.563 0 0 0-2.02...",
END
    run testCommit6 $REPO_PATH
    [ ${status} -eq 0 ]
}

@test "ingore ipv4-ish in svg 7" {
    cat > $REPO_PATH/ok.svg <<END
"\u003csvg xmlns=\"http://www.w3.org/2000/svg\" d=\"M57.547 18.534a3.71 3.71 0 0 10.20.30.40 0-1.679-1.276 5.563 5.563 0 0 0-2.02...",
END
    run testCommit7 $REPO_PATH
    [ ${status} -eq 0 ]
}

@test "it fails a suspect filename extension in 6" {
    touch $REPO_PATH/foo.pem 
    run testCommit6 $REPO_PATH
    [ ${status} -eq 1 ]
}

@test "it fails a suspect filename extension in 7" {
    touch $REPO_PATH/foo.pem 
    run testCommit7 $REPO_PATH
    [ ${status} -eq 1 ]
}

@test "it fails a suspect filename in 6" {
    touch $REPO_PATH/shadow
    run testCommit6 $REPO_PATH
    [ ${status} -eq 1 ]
}

@test "it fails a suspect filename in 7" {
    touch $REPO_PATH/shadow
    run testCommit7 $REPO_PATH
    [ ${status} -eq 1 ]
}
