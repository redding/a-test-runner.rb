require "assert"

require "a-test-runner"

class ATestRunner::Runner
  class UnitTests < Assert::Context
    desc "ATestRunner::Runner"
    setup do
      @class = ATestRunner::Runner
    end
    subject{ @class }
  end

  class InitSetupTests < UnitTests
    desc "when init"
    setup do
      Assert.stub(Dir, :pwd){ TEST_SUPPORT_PATH }
      @test_files = [
        "test/thing1_test.rb",
        "test/thing2_test.rb"
      ]

      @test_output = ""
      @config      = ATestRunner::Config.new(StringIO.new(@test_output))
      Assert.stub(ATestRunner, :config){ @config }

      @default_test_cmd  = Factory.string
      @verbose_test_cmd  = Factory.string
      @seed_env_var_name = Factory.string
      @env_vars          = "#{Factory.string.upcase}=#{Factory.string}"
      Assert.stub(@config, :default_test_cmd){ @default_test_cmd }
      Assert.stub(@config, :verbose_test_cmd){ @verbose_test_cmd }
      Assert.stub(@config, :seed_env_var_name){ @seed_env_var_name }
      Assert.stub(@config, :env_vars){ @env_vars }

      @test_paths   = [""]
    end
    subject{ @runner }
  end

  class InitTests < InitSetupTests
    setup do
      @runner = @class.new(@test_paths, config: @config)
    end

    should have_readers :config, :cmd_str

    should "know its config" do
      assert_same @config, subject.config
    end

    should "use the default test command by default" do
      assert_includes     @default_test_cmd, subject.cmd_str
      assert_not_includes @verbose_test_cmd, subject.cmd_str
    end

    should "include env vars in the test command" do
      exp = "#{@env_vars} #{@seed_env_var_name}=#{@config.seed_value}"
      assert_includes exp, subject.cmd_str
    end

    should "lookup and use the test files in the test dir in the test command" do
      assert_includes @test_files.join(" "), subject.cmd_str
    end
  end

  class DryRunTests < InitSetupTests
    desc "and configured to dry run"
    setup do
      Assert.stub(@config, :dry_run){ true }

      debug = Factory.boolean
      Assert.stub(@config, :debug){ debug }

      list = Factory.boolean
      Assert.stub(@config, :list){ list }

      @runner = @class.new(@test_paths, config: @config)
    end

    should "output the cmd str to stdout and but not execute it" do
      subject.run
      assert_includes subject.cmd_str, @test_output
    end
  end

  class ListTests < InitSetupTests
    desc "and configured to list"
    setup do
      Assert.stub(@config, :list){ true }

      debug = Factory.boolean
      Assert.stub(@config, :debug){ debug }

      dry_run = Factory.boolean
      Assert.stub(@config, :dry_run){ dry_run }

      @runner = @class.new(@test_paths, config: @config)
    end

    should "list out the test files to stdout and not execute the cmd str" do
      subject.run
      assert_includes @test_files.join("\n"), @test_output
    end
  end

  class VerboseTests < InitSetupTests
    desc "and configured in verbose mode"
    setup do
      Assert.stub(@config, :verbose){ true }

      @runner = @class.new(@test_paths, config: @config)
    end

    should "use the verbose test command" do
      assert_includes     @verbose_test_cmd, subject.cmd_str
      assert_not_includes @default_test_cmd, subject.cmd_str
    end
  end

  class ChangedOnlySetupTests < InitSetupTests
    setup do
      @changed_ref = Factory.string
      Assert.stub(@config, :changed_ref){ @changed_ref }
      Assert.stub(@config, :changed_only){ true }

      @changed_test_file = @test_files.sample
      @git_cmd_used      = nil
      Assert.stub(ATestRunner::GitChangedFiles, :new) do |*args|
        @git_cmd_used = ATestRunner::GitChangedFiles.cmd(*args)
        ATestRunner::ChangedResult.new(@git_cmd_used, [@changed_test_file])
      end

      @test_paths = @test_files
    end
  end

  class ChangedOnlyTests < ChangedOnlySetupTests
    desc "and configured in changed only mode"
    setup do
      @runner = @class.new(@test_paths, config: @config)
    end

    should "run a git cmd to determine which files to test" do
      exp = "git diff --no-ext-diff --name-only #{@changed_ref} "\
            "-- #{@test_paths.join(" ")} && "\
            "git ls-files --others --exclude-standard "\
            "-- #{@test_paths.join(" ")}"
      assert_equal exp, @git_cmd_used
    end

    should "only run the test files that have changed" do
      exp = "#{@default_test_cmd} #{@changed_test_file}"
      assert_includes exp, subject.cmd_str
    end
  end

  class DebugTests < ChangedOnlySetupTests
    desc "and configured in debug mode"
    setup do
      Assert.stub(@config, :debug){ true }

      @runner = @class.new(@test_paths, config: @config)
    end

    should "output detailed debug info" do
      changed_result      = ATestRunner::GitChangedFiles.new(@config, @test_paths)
      changed_cmd         = changed_result.cmd
      changed_files_count = changed_result.files.size
      changed_files_lines = changed_result.files.map{ |f| "[DEBUG]   #{f}" }

      assert_includes "[DEBUG] Lookup changed test files...", @test_output

      exp = "[DEBUG]   `#{changed_cmd}`\n"\
            "[DEBUG] #{changed_files_count} Test files:\n"\
            "#{changed_files_lines.join("\n")}\n"\
            "[DEBUG] Test command:\n"\
            "[DEBUG]   #{subject.cmd_str}\n"
      assert_includes exp, @test_output
    end
  end
end
