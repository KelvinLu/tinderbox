require 'pathname'

class Tinderbox::Command::Server
  DEFAULT_LISTEN_PORT = 8420
  DEFAULT_NODE_PORT = 10009

  include Tinderbox::Command

  command 'run-server'

  calling_convention(0) do
    self.banner = 'Usage: run-server [options]'

    self.on('--server-port=PORT', Integer, "Listen on port (default: #{DEFAULT_LISTEN_PORT})") do |port|
      options[:server_listen_port] = port
    end

    self.on('--node-host=ADDRESS', "LND node address") do |host|
      options[:node_host] = host
    end

    self.on('--node-port=PORT', Integer, "LND node port (default: #{DEFAULT_NODE_PORT})") do |port|
      options[:node_port] = port
    end

    self.on('--macaroon-directory=DIRECTORY', 'Directory for storing macaroons') do |directory|
      options[:macaroon_directory] = directory
    end

    self.on('--lndconnect=EXECUTABLE', 'Path to the lndconnect executable') do |filepath|
      options[:lndconnect_filepath] = filepath
    end
  end

  run do |options:, arguments:|
    require_relative '../server/server'

    macaroon_directory = options[:macaroon_directory]

    raise 'Directory for storing macaroons must be specified' if macaroon_directory.nil?

    macaroon_directory = Pathname.new(macaroon_directory).realpath

    raise "#{macaroon_directory} is not a writable directory" unless File.directory?(macaroon_directory) && File.writable?(macaroon_directory)

    lndconnect_filepath = options.fetch(:lndconnect_filepath) do
      path = `which lndconnect`.strip

      raise 'lndconnect not found on $PATH, please specify its location explicitly' if (!($?.success?) || path.empty?)
      path
    end

    lndconnect_filepath = Pathname.new(lndconnect_filepath).realpath

    raise "#{lndconnect_filepath} is not executable" unless File.file?(lndconnect_filepath) && File.executable?(lndconnect_filepath)

    node_host = options.fetch(:node_host) { raise 'Node host must be given' }
    node_port = options.fetch(:node_port, DEFAULT_NODE_PORT)

    server =
      Tinderbox::Server.new(
        listen_port: options.fetch(:server_listen_port, DEFAULT_LISTEN_PORT),

        node_host: node_host,
        node_port: node_port,

        macaroon_directory: macaroon_directory,
        lndconnect_filepath: lndconnect_filepath,
      )

    server.start
  end
end
