class Node
  SOURCE_RIAK = File.expand_path(File.join('..','tmp','riak-1.0.2'),File.dirname(__FILE__))
  NODE_DIR    = File.expand_path(File.join('..','node'),File.dirname(__FILE__))

  def create_cluster!
    `mkdir #{NODE_DIR}` unless File.exists? NODE_DIR

    ports = pick_unique_ports 9
    3.times do |i|
      puts "Copying Node #{i} from #{SOURCE_RIAK}:"
      c = "cp -R #{SOURCE_RIAK} #{NODE_DIR}/#{i}"
      puts c
      `#{c}`

      port = ports.pop
      File.open(File.join("#{NODE_DIR}/#{i}",'port.txt'),'w'){|f| f.write port}

      puts "Setting app.config for Node #{i} to Port Number #{port}:"
      config_file = File.read File.join("#{NODE_DIR}/#{i}",'etc','app.config')
      # grab the port number out of the config file
      config_file.sub!(/\{http[^\}]+\}/, "{http, [ {\"127.0.0.1\", #{port} }")
      config_file.sub!(/\{handoff_port[^\}]+\}/, "{handoff_port, #{ports.pop} }")
      config_file.sub!(/\{pb_port[^\}]+\}/, "{pb_port, #{ports.pop} }")

      puts "Allowing strfun for Node #{i}:"
      config_file.sub!(/\{riak_kv, \[/, "{riak_kv, [\n              {allow_strfun, true},")

      puts "Switching to leveldb for Node #{i}:"
      config_file.sub!(/riak_kv_bitcask_backend/, 'riak_kv_eleveldb_backend')

      File.open(File.join("#{NODE_DIR}/#{i}",'etc','app.config'), 'w'){|f| f.write config_file}

      puts "Setting vm.args for Node #{i}:"
      config_file = File.read File.join("#{NODE_DIR}/#{i}",'etc','vm.args')
      config_file.sub!(/name riak@127.0.0.1/, "name node_#{i}_#{port}@127.0.0.1")
      config_file.sub!(/setcookie riak/, "setcookie juggleriak")
      File.open(File.join("#{NODE_DIR}/#{i}",'etc','vm.args'), 'w'){|f| f.write config_file}
    end
  end

  def destroy_all_cluster!
    `rm -Rf #{NODE_DIR}` if NODE_DIR.length > 4
  end

  def start_cluster!
    3.times do |i|
      puts "Starting Node #{i}:"
      c = "cd #{File.join("#{NODE_DIR}/#{i}")}"
      puts c
      c = "#{File.join(NODE_DIR,i.to_s,'bin','riak')} start"
      puts c
      puts `#{c}`
    end
  end

  def restart_cluster!
    3.times do |i|
      puts "Restarting Node #{i}:"
      c = "cd #{File.join("#{NODE_DIR}/#{i}")}"
      puts c
      c = "#{File.join(NODE_DIR,i.to_s,'bin','riak')} restart"
      puts c
      puts `#{c}`
    end
  end

  def stop_cluster!
    3.times do |i|
      puts "Stopping Node #{i}:"
      c = "cd #{File.join("#{NODE_DIR}/#{i}")}"
      puts c
      c = "#{File.join(NODE_DIR,i.to_s,'bin','riak')} stop"
      puts c
      puts `#{c}`
    end
  end

  def join_cluster!
    puts "Joining All Nodes:"
    port      = File.read File.join(NODE_DIR,'0','port.txt')
    node_name = "node_0_#{port}@127.0.0.1"
    2.times do |i|
      c = "cd #{File.join(NODE_DIR,(i + 1).to_s)}"
      puts c
      c = "#{File.join(NODE_DIR,(i + 1).to_s,'bin','riak-admin')} join #{node_name}"
      puts c
      puts `#{c}`
    end
  end

  def status_cluster!
    puts "Status According to Node 0:"
    c = "cd #{File.join(NODE_DIR,'0')}"
    puts c
    c = "#{File.join(NODE_DIR,'0','bin','riak-admin')} status"
    puts c
    puts `#{c}`
  end

  def pick_unique_ports(count)
    ports = []
    while(ports.length < count)
      ports << pick_a_port
    end
    ports
  end

private
  def pick_a_port
    "13#{rand(1000)}".to_i
  end
end
