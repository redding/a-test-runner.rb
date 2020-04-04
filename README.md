# a-test-runner.rb

This is a CLI that generates and executes ruby test commands.  Copy/rename it into your $PATH and customize the CONSTANT values at the top of the script for your test setup.

## Features

* A common, friendly CLI for running tests, regardless of the testing tools/framework you use
* Run only the files that have been updated/changed (using Git)
* Switch between default and verbose output modes
* Specify test files/directories with absolute or relative paths
* Set custom seed values
* Debug and dry-run options to help debug your configuration/setup

## Usage

This assumes a `BIN_NAME` of `runtests` (see the Installation section below).

```
$ runtests -h
Usage: runtests [options] [TESTS]

Options:
    -s, --seed-value VALUE           use a given seed to run tests
    -c, --[no-]changed-only          only run test files with changes
    -r, --changed-ref VALUE          reference for changes, use with `-c` opt
    -p, --parallel-workers VALUE     number of parallel workers to use (if applicable)
    -v, --[no-]verbose               output verbose runtime test info
        --[no-]dry-run               output the test command to $stdout
    -l, --[no-]list                  list test files on $stdout
    -d, --[no-]debug                 run in debug mode
        --version
        --help
$ cd my/ruby/project
$ runtests
```

### Options

Given these CONSTANT values:

```ruby
BIN_NAME           = "runtests"
TEST_DIR           = "test"
TEST_FILE_SUFFIXES = ["_test.rb"]
DEFAULT_TEST_CMD   = "MINITEST_REPORTER=ProgressReporter ./bin/rake test"
VERBOSE_TEST_CMD   = "MINITEST_REPORTER=SpecReporter ./bin/rake test"
SEED_ENV_VAR_NAME  = "SEED"
ENV_VARS           = "USE_SIMPLE_COV=0"
```

#### Debug Mode

```
$ runtests -d
[DEBUG] CLI init and parse...          (6.686 ms)
[DEBUG] 2 Test files:
[DEBUG]   test/thing1_test.rb
[DEBUG]   test/thing2_test.rb
[DEBUG] Test command:
[DEBUG]   SEED=15991 MINITEST_REPORTER=ProgressReporter ./bin/rake test test/thing1_test.rb test/thing2_test.rb
```

This option, in addition to executing the test command, outputs a bunch of detailed debug information.

#### Changed Only

```
$ runtests -d -c
[DEBUG] CLI init and parse...          (7.138 ms)
[DEBUG] Lookup changed test files...   (24.889 ms)
[DEBUG]   `git diff --no-ext-diff --name-only  -- test && git ls-files --others --exclude-standard -- test`
[DEBUG] 1 Test files:
[DEBUG]   test/thing2_test.rb
[DEBUG] Test command:
[DEBUG]   SEED=36109 MINITEST_REPORTER=ProgressReporter ./bin/rake test test/thing2_test.rb
```

This runs a git command to determine which files have been updated (relative to `HEAD` by default) and only runs those tests.

You can specify a custom git ref to use instead:

```
$ runtests -d -c -r master
[DEBUG] CLI init and parse...          (6.933 ms)
[DEBUG] Lookup changed test files...   (162.297 ms)
[DEBUG]   `git diff --no-ext-diff --name-only master -- test && git ls-files --others --exclude-standard -- test`
[DEBUG] 2 Test files:
[DEBUG]   test/thing1_test.rb
[DEBUG]   test/thing2_test.rb
[DEBUG] Test command:
[DEBUG]   SEED=73412 MINITEST_REPORTER=ProgressReporter ./bin/rake test test/thing1_test.rb test/thing2_test.rb
```

#### Dry-Run

```
$ runtests --dry-run
SEED=23940 MINITEST_REPORTER=ProgressReporter ./bin/rake test test/thing1_test.rb test/thing2_test.rb
```

This option only outputs the test command it would have run.  It does not execute the test command.

#### Parallel Workers

```
$ runtests -p 2 --dry-run
SEED=23940 PARALLEL_WORKERS=2 MINITEST_REPORTER=ProgressReporter ./bin/rake test test/thing1_test.rb test/thing2_test.rb
```

Force a specific number of parallel workers to run the tests. This uses the configured `PARALLEL_ENV_VAR_NAME` constant to build the env var.

#### List

```
$ runtests -l
test/thing1_test.rb
test/thing2_test.rb
```

This option, similar to `--dry-run`, does not execute any tests.  It lists out each test file it would execute to `$stdout`.

#### Verbose

```
$ runtests -v --dry-run
SEED=50201 MINITEST_REPORTER=SpecReporter ./bin/rake test test/thing1_test.rb test/thing2_test.rb
```

This option switches to using the configured `VERBOSE_TEST_CMD` when executing the tests.

#### Seed

```
$ runtests -s 00000 --dry-run
SEED=00000 MINITEST_REPORTER=ProgressReporter ./bin/rake test test/thing1_test.rb test/thing2_test.rb
```

Force a specific seed value for the test run.

## Installation

**Tip**: repeat these steps to install multiple different test runners where the CONSTANT settings need to be different (be sure to use distinct `BIN_NAME`s).

1. Copy `a-test-runner.rb` to some folder in your `$PATH` (ie `$HOME/.bin`)
2. Rename it to something you like.  For example: `mv a-test-runner.rb runtests`.
3. Make it executable: `chmod 755 runtests`
4. Update the default CONSTANTS as needed for your test setup:

```ruby
# in the runner script file...

# ...

module ATestRunner
  VERSION = "x.x.x"

  # update these as needed for your test setup
  BIN_NAME              = "runtests" # should match what you name the executable
  TEST_DIR              = "test"
  TEST_FILE_SUFFIXES    = ["_test.rb"]
  TERSE_TEST_CMD        = "MINITEST_REPORTER=ProgressReporter ./bin/rails test"
  VERBOSE_TEST_CMD      = "MINITEST_REPORTER=SpecReporter ./bin/rails test"
  SEED_ENV_VAR_NAME     = "SEED"
  PARALLEL_ENV_VAR_NAME = "PARALLEL_WORKERS"
  ENV_VARS              = "USE_SIMPLE_COV=0"

# ...
```

### Test it out

```
$ runtests -h
Usage: runtests [options] [TESTS]

Options:
    -s, --seed-value VALUE           use a given seed to run tests
    -c, --[no-]changed-only          only run test files with changes
    -r, --changed-ref VALUE          reference for changes, use with `-c` opt
    -p, --parallel-workers VALUE     number of parallel workers to use (if applicable)
    -v, --[no-]verbose               output verbose runtime test info
        --[no-]dry-run               output the test command to $stdout
    -l, --[no-]list                  list test files on $stdout
    -d, --[no-]debug                 run in debug mode
        --version
        --help
$ runtests --debug --dry-run
$ runtests
```
