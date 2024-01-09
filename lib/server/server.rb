require 'webrick'
require 'webrick/https'

class Tinderbox::Server
end

SSL_CERT_NAME = [
  %w[CN localhost]
]

class Tinderbox::Server
  def initialize(
    listen_port:,
    node_host:,
    node_port:,
    macaroon_directory:,
    tmp_directory:,
    lndconnect_filepath:
  )
    @server = WEBrick::HTTPServer.new(
      :Port => listen_port,
      :SSLEnable => true,
      :SSLCertName => SSL_CERT_NAME
    )

    @@node_host = node_host
    @@node_port = node_port

    @@macaroon_directory = macaroon_directory
    @@tmp_directory = tmp_directory
    @@lndconnect_filepath = lndconnect_filepath
  end

  def self.node_host
    @@node_host
  end

  def self.node_port
    @@node_port
  end

  def self.macaroon_directory
    @@macaroon_directory
  end

  def self.tmp_directory
    @@tmp_directory
  end

  def self.lndconnect_filepath
    @@lndconnect_filepath
  end

  def start
    trap 'INT' do
      @server.shutdown
    end

    mount_servlets

    @server.start
  end

  def mount_servlets
    require_relative 'servlet/page_renderer'
    @server.mount '/', PageRenderer

    require_relative 'servlet/command'
    @server.mount '/command', Command
  end
end
