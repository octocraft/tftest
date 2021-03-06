#!/usr/bin/env bats

function terraform () {
    printf "terraform $1\n\nOutputs:\n\nfoo = bar\n"
}

function wine () {
    printf "terraform $1\n\nOutputs:\n\nfoo = bar\n"
}

export -f terraform

@test "TFTEST_WINE unset / no wine" {

    rm -f verify.sh
    rm -f outputs.diff

    export PATH="/bin"

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "foo = bar" ]
}

@test "TFTEST_WINE true / no wine" {

    export PATH="/bin"
    export TFTEST_WINE=true

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "foo = bar" ]
}

@test "TFTEST_WINE unset / wine" {

    export -f wine
    export PATH="/bin"

    run ./tftest.sh
    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]

    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "foo = bar" ]
    [ "${lines[1]}" = "foo = bar" ]
}

@test "TFTEST_WINE set / wine" {

    export -f wine
    export PATH="/bin"
    export TFTEST_WINE=true

    run ./tftest.sh
    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]

    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "foo = bar" ]
    [ "${lines[1]}" = "foo = bar" ]
}

@test "TFTEST_WINE false / wine" {

    export -f wine
    export PATH="/bin"
    export TFTEST_WINE=false

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "foo = bar" ]
}

@test "TFTEST_DIFFOUTPUT false" {

    echo "foo = bar" > "outputs.diff"

    export TFTEST_DIFFOUTPUT=false
    export PATH="/bin"

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "foo = bar" ]

    rm -f "outputs.diff"
}

@test "outputs.diff ok / no wine" {

    echo "foo = bar" > "outputs.diff"

    export PATH="/bin"

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ "$output" = "foo = bar" ]

    rm -f "outputs.diff"
}

@test "outputs.diff fail / no wine" {

    echo "foo = lol" > "outputs.diff"

    export PATH="/bin"

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 1 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "output does not match with 'outputs.diff':" ]
    [ "${lines[1]}" = "foo = bar" ]

    rm -f "outputs.diff"
}

@test "outputs.diff ok / wine" {

    echo "foo = bar" > "outputs.diff"

    export -f wine
    export PATH="/bin"

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "foo = bar" ]
    [ "${lines[1]}" = "foo = bar" ]

    rm -f "outputs.diff"
}

@test "outputs.diff fail / wine" {

    echo "foo = lol" > "outputs.diff"

    export -f wine
    export PATH="/bin"

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 1 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "output does not match with 'outputs.diff':" ]
    [ "${lines[1]}" = "foo = bar" ]

    rm -f "outputs.diff"
}

@test "targets.diff ok" {

    export PATH="/bin"

    run ./tftest.sh targets.diff

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ "$output" = "foo = bar" ]
}

@test "targets.diff / wine.diff" {

    function wine () {
        printf "terraform $1\n\nOutputs:\n\nfoo = lol\n"
    }

    export PATH="/bin"
    export -f wine

    run ./tftest.sh targets.diff wine.diff

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "foo = bar" ]
    [ "${lines[1]}" = "foo = lol" ]
}

@test "null.diff" {

    export PATH="/bin"

    run ./tftest.sh null.diff

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 2 ]
    [ "$output" = "file 'null.diff' not found" ]
}

@test "verify.sh / fail" {

    ln -fs check.sh verify.sh
    rm -f test.dat

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 1 ]
}

@test "verify.sh / ok" {

    printf "test" > test.dat

    run ./tftest.sh

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]

     rm -f verify.sh
}

@test "check.sh / ok" {

    run ./tftest.sh "" "" "./check.sh"

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 0 ]

    rm -f test.dat
}

@test "check.sh / fail" {

    rm -f test.dat
    run ./tftest.sh "" "" "./check.sh"

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 1 ]
}

@test "null.sh" {

    export PATH="/bin"

    run ./tftest.sh "" "" "./null.sh"

    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 2 ]
    [ "$output" = "command './null.sh' not found" ]
}
