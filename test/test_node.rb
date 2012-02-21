require File.expand_path('../helper', __FILE__)

class TestNode < MiniTest::Unit::TestCase
  def setup
    @node = Node.new
  end

  def test_pick_a_random_port
    port = @node.send(:pick_a_port)
    assert port < 10000, "Port number #{port} too high."
    assert port < 9000, "Port number #{port} too low."
  end

  def test_pick_nine_unique_ports
    ports = @node.pick_unique_ports 9
    assert ports.length == 9, "Not enough ports chosen."
  end
end
