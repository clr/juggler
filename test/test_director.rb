require File.expand_path('../helper', __FILE__)

class TestDirector < MiniTest::Unit::TestCase
  def setup
    @director = Director.new
  end

  def test_pick_a_random_port
    port = @director.send(:pick_a_port)
    assert port < 10000, "Port number #{port} too high."
    assert port < 9000, "Port number #{port} too low."
  end

  def test_pick_nine_unique_ports
    ports = @director.pick_unique_ports 9
    assert ports.length == 9, "Not enough ports chosen."
  end

  def test_store_current_frame
    current_frame_file = File.expand_path(File.join('..','tmp','current_frame.txt'),File.dirname(__FILE__))
    File.unlink current_frame_file if File.exists? current_frame_file
    @director.set_current_frame('0010_create_cluster.txt')
    assert File.exists?(current_frame_file), "Could not create file."
  end

  def test_read_current_frame
    @director.set_current_frame('0020_create_cluster.txt')
    current_frame = @director.get_current_frame
    assert_equal '0020_create_cluster.txt', current_frame
  end

  def test_read_manifest
    given_faux_manifest do
      manifest = @director.get_manifest
      assert_equal 3, manifest.length, "Manifest was too small."
    end
  end

  def test_find_current_frame_in_manifest
    given_faux_manifest do
      @director.set_current_frame('0020_create_cluster.txt')
      index = @director.find_frame_in_manifest('0020_create_cluster.txt')
      assert_equal 1, index, "Wrong index of frame."
    end
  end

  # this is class-oriented, not object-oriented
  def test_run_next
    faux_frame_file = File.expand_path(File.join('..','frame','0030_create_cluster.txt'),File.dirname(__FILE__))
    File.open(faux_frame_file, 'w'){|f| f.write 'ps aux | grep ruby'}

    given_faux_manifest do
      @director.set_current_frame('0020_create_cluster.txt')
      @director.run_next!
      current_frame = @director.get_current_frame
      assert_equal '0030_create_cluster.txt', current_frame, "Frame didn't move forward."
    end
    File.unlink faux_frame_file if File.exists? faux_frame_file
  end

  def test_rerun
    faux_frame_file = File.expand_path(File.join('..','frame','0020_create_cluster.txt'),File.dirname(__FILE__))
    File.open(faux_frame_file, 'w'){|f| f.write 'ps aux | grep ruby'}

    given_faux_manifest do
      @director.set_current_frame('0020_create_cluster.txt')
      @director.rerun!
      current_frame = @director.get_current_frame
      assert_equal '0020_create_cluster.txt', current_frame, "Frame should not have moved."
    end
    File.unlink faux_frame_file if File.exists? faux_frame_file
  end

  def test_restart
    given_faux_manifest do
      @director.set_current_frame('0020_create_cluster.txt')
      @director.restart!
      current_frame_file = File.expand_path(File.join('..','tmp','current_frame.txt'),File.dirname(__FILE__))
      assert !File.exists?(current_frame_file), "Current frame file shouldn't be here."
    end
  end

private
  def given_faux_manifest
    manifest_file = File.expand_path(File.join('..','config','manifest.txt'),File.dirname(__FILE__))
    # protect the real manifest
    File.rename(manifest_file, "#{manifest_file}.bak") if File.exists? manifest_file
    # create the faux one
    File.open(manifest_file, 'w') do |f|
      f.puts '0010_create_cluster.txt'
      f.puts '0020_create_cluster.txt'
      f.puts '0030_create_cluster.txt'
    end
    yield
    # return original manifest
    if File.exists? "#{manifest_file}.bak"
      File.unlink manifest_file
      File.rename("#{manifest_file}.bak", manifest_file)
    end
  end
end
