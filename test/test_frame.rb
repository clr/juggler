require File.expand_path('../helper', __FILE__)

class TestFrame < MiniTest::Unit::TestCase
  def setup
    @frame = Frame.new
  end

  def test_template_substitution
    Frame.const_set('WHAT', "stuff")
    @frame.instance_variable_set(:@script, "Here's a bunch of stuff and a bunch more {{WHAT}}")
    @frame.send(:substitute_template)
    assert_equal "Here's a bunch of stuff and a bunch more stuff", @frame.script
  end

  def test_loading_frame
    faux_frame_file = File.expand_path(File.join('..','frame','faux_test_frame.txt'),File.dirname(__FILE__))
    given_faux_frame do
      @frame = Frame.new faux_frame_file
      assert_equal 'ps aux | grep ruby', @frame.script, "Wrong script."
    end
  end

  def test_running_frame
    faux_frame_file = File.expand_path(File.join('..','frame','faux_test_frame.txt'),File.dirname(__FILE__))
    given_faux_frame do
      @frame = Frame.new faux_frame_file
      response = @frame.run!
      assert response.match(/ruby/), "Wrong response from script: #{response}"
    end
  end

private
  def given_faux_frame
    faux_frame_file = File.expand_path(File.join('..','frame','faux_test_frame.txt'),File.dirname(__FILE__))
    File.open(faux_frame_file, 'w'){|f| f.write 'ps aux | grep ruby'}
    yield
    File.unlink faux_frame_file if File.exists? faux_frame_file
  end
end
