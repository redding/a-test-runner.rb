require "assert"

require "a-test-runner"

module ATestRunner
  class UnitTests < Assert::Context
    desc "ATestRunner"
    setup do
      @module = ATestRunner
    end
    subject{ @module }

    should have_imeths :config
    should have_imeths :debug?, :debug_msg, :debug_start_msg, :debug_finish_msg
    should have_imeths :bench

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

    should "know if the given ARGV means we are in debug mode or not" do
      assert_false subject.debug?(Factory.integer(3).times.map{ Factory.string })
      assert_false subject.debug?([Factory.string, "--dry-run"])
      assert_true subject.debug?([Factory.string, "--debug"])
      assert_true subject.debug?([Factory.string, "-d"])
      assert_true subject.debug?([Factory.string, "--#{Factory.string(3)}d"])
    end

    should "know how to build debug messages" do
      msg = Factory.string
      exp = "[DEBUG] #{msg}"
      assert_equal exp, subject.debug_msg(msg)
    end

    should "know how to build debug start messages" do
      msg = Factory.string
      exp = subject.debug_msg("#{msg}...".ljust(30))
      assert_equal exp, subject.debug_start_msg(msg)

      msg = Factory.string(35)
      exp = subject.debug_msg("#{msg}...".ljust(30))
      assert_equal exp, subject.debug_start_msg(msg)
    end

    should "know how to build debug finish messages" do
      time_in_ms = Factory.float
      exp = " (#{time_in_ms} ms)"
      assert_equal exp, subject.debug_finish_msg(time_in_ms)
    end

  end

  class BenchTests < UnitTests
    desc "`bench`"
    setup do
      @test_output = ""
      test_stdout  = StringIO.new(@test_output)
      Assert.stub(@module.config, :stdout){ test_stdout }

      @start_msg = Factory.string
      @proc      = proc{}
    end

    should "not output any stdout info if not in debug mode" do
      Assert.stub(subject.config, :debug){ false }

      subject.bench(@start_msg, &@proc)

      assert_empty @test_output
    end

    should "output any stdout info if in debug mode" do
      Assert.stub(subject.config, :debug){ true }

      time_in_ms = subject.bench(@start_msg, &@proc)

      exp = "#{subject.debug_start_msg(@start_msg)}"\
            "#{subject.debug_finish_msg(time_in_ms)}\n"
      assert_equal exp, @test_output
    end
  end
end
