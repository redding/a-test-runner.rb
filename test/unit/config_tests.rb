require "assert"

require "a-test-runner"

class ATestRunner::Config
  class UnitTests < Assert::Context
    desc "ATestRunner::Config"
    setup do
      @class = ATestRunner::Config
    end
    subject{ @class }

    should have_imeths :settings
  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @config = @class.new
    end
    subject{ @config }

    should have_readers :stdout, :bin_name, :test_dir, :test_file_suffixes
    should have_readers :default_test_cmd, :verbose_test_cmd
    should have_readers :seed_env_var_name, :env_vars
    should have_imeths  :seed_value, :changed_only, :changed_ref
    should have_imeths  :verbose, :dry_run, :list, :debug
    should have_imeths  :apply

    should "know its stdout" do
      assert_same $stdout, subject.stdout

      io     = StringIO.new("")
      config = @class.new(io)
      assert_same io, config.stdout
    end

    should "know its CONTANT driven attrs" do
      assert_equal ATestRunner::BIN_NAME,           subject.bin_name
      assert_equal ATestRunner::TEST_DIR,           subject.test_dir
      assert_equal ATestRunner::TEST_FILE_SUFFIXES, subject.test_file_suffixes
      assert_equal ATestRunner::DEFAULT_TEST_CMD,   subject.default_test_cmd
      assert_equal ATestRunner::VERBOSE_TEST_CMD,   subject.verbose_test_cmd
      assert_equal ATestRunner::SEED_ENV_VAR_NAME,  subject.seed_env_var_name
      assert_equal ATestRunner::ENV_VARS,           subject.env_vars
    end

    should "default its settings attrs" do
      assert_not_nil subject.seed_value
      assert_false   subject.changed_only
      assert_empty   subject.changed_ref
      assert_false   subject.verbose
      assert_false   subject.dry_run
      assert_false   subject.list
      assert_false   subject.debug
    end

    should "allow apply custom settings attrs" do
      settings = {
        :seed_value   => Factory.integer,
        :changed_only => true,
        :changed_ref  => Factory.string,
        :verbose      => true,
        :dry_run      => true,
        :list         => true,
        :debug        => true
      }
      subject.apply(settings)

      assert_equal settings[:seed_value],   subject.seed_value
      assert_equal settings[:changed_only], subject.changed_only
      assert_equal settings[:changed_ref],  subject.changed_ref
      assert_equal settings[:verbose],      subject.verbose
      assert_equal settings[:dry_run],      subject.dry_run
      assert_equal settings[:list],         subject.list
      assert_equal settings[:debug],        subject.debug
    end
  end
end
