class Director
  FRAME_PATH         = File.expand_path(File.join('..','frame'),File.dirname(__FILE__))
  MANIFEST_FILE      = File.expand_path(File.join('..','config','manifest.txt'),File.dirname(__FILE__))
  CURRENT_FRAME_FILE = File.expand_path(File.join('..','tmp','current_frame.txt'),File.dirname(__FILE__))

  def set_current_frame(token)
    File.open(CURRENT_FRAME_FILE, 'w'){|f| f.write token}
  end

  def get_current_frame
    File.read CURRENT_FRAME_FILE
  end

  def get_manifest
    File.readlines MANIFEST_FILE
  end

  def find_frame_in_manifest(frame)
    get_manifest.index(frame) || get_manifest.index("#{frame}\n")
  end

  def rewind!
    if File.exists? CURRENT_FRAME_FILE
      new_index = find_frame_in_manifest(get_current_frame)
    else
      new_index = 0
    end
    new_frame = get_manifest[new_index < 1 ? 0 : (new_index - 1)].strip
    puts Frame.new(File.join(FRAME_PATH, new_frame)).title
    set_current_frame new_frame
  end

  def run_next!
    if File.exists? CURRENT_FRAME_FILE
      new_frame = get_manifest[find_frame_in_manifest(get_current_frame) + 1].strip
    else
      new_frame = get_manifest[0].strip
    end
    set_current_frame new_frame
    rerun!
    File.open("#{MANIFEST_FILE}.last_used", 'w'){|f| f.write File.read(MANIFEST_FILE)}
  end

  def rerun!
    current_frame = get_manifest[find_frame_in_manifest(get_current_frame)].strip
    frame = Frame.new File.join(FRAME_PATH, current_frame)
    if ENVIRONMENT == :test
      frame.run!
    else
      frame.run_pretty!
    end
  end

  def restart!
    File.unlink CURRENT_FRAME_FILE
  end
end
