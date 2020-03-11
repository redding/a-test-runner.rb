require "assert"

require "a-test-runner"

module ATestRunner
  class UnitTests < Assert::Context
    desc "ATestRunner"
    setup do
      @module = ATestRunner
    end
    subject{ @module }

    should have_imeths :config, :apply, :bench, :run

    should "know its default CONTANTS" do
      assert_equal "a-test-runner",   subject::BIN_NAME
      assert_equal "test",            subject::TEST_DIR
      assert_equal ["_test.rb"],      subject::TEST_FILE_SUFFIXES
      assert_equal "./bin/rake test", subject::DEFAULT_TEST_CMD
      assert_equal "./bin/rake test", subject::VERBOSE_TEST_CMD
      assert_equal "SEED",            subject::SEED_ENV_VAR_NAME
      assert_equal "",                subject::ENV_VARS
    end

    should "know its config singleton" do
      assert_instance_of Config, subject.config
      assert_same subject.config, subject.config
    end
  end
end
