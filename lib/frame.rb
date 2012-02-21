class Frame
  attr_reader :script, :title

  TEMP_DIR = File.expand_path(File.join('..','tmp'),File.dirname(__FILE__))
  DOWNLOAD_FILE = 'http://downloads.basho.com/riak/riak-1.0.2/riak-1.0.2-osx-x86_64.tar.gz'
  ZIP_FILE = 'riak-1.0.2-osx-x86_64.tar.gz'
  # duplicated in Node class
  NODE_DIR = File.expand_path(File.join('..','node'),File.dirname(__FILE__))
  RIAK_URL = "http://127.0.0.1:#{File.read File.join(NODE_DIR,'0','port.txt')}"

  def initialize(file=nil)
    if file
      @title  = File.basename(file).sub('.txt','').gsub('_',' ').upcase
      @script = File.read file
    end
  end

  def run!
    substitute_template
    `#{@script}`
  end

  def run_pretty!
    substitute_template
    puts @title
    puts @script
    4.times do
      puts
    end
    puts '========================='
    4.times do
      puts
    end
    puts `#{@script}`
  end
private
  def substitute_template
    self.class.constants.each do |constant|
      @script.gsub! "{{#{constant}}}", self.class.const_get(constant)
    end
  end
end
