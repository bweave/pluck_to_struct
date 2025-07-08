require "test_helper"

class TestConsoleSetup < Minitest::Test
  def test_console_executable_exists
    # Test that the console script exists and is executable
    console_path = File.join(File.dirname(__FILE__), "..", "bin", "console")
    assert File.exist?(console_path), "Console script should exist"
    assert File.executable?(console_path), "Console script should be executable"
  end
end
