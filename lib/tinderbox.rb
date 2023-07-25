require 'logger'

class Tinderbox
  @logger = Logger.new(STDERR).tap do |logger|
    logger.level =
      if ENV['DEBUG'] == 'true'
        Logger::DEBUG
      else
        Logger::WARN
      end
  end

  def self.log
    @logger
  end
end

require_relative 'calls/command'
require_relative 'configuration/configuration'
require_relative 'model/account'
require_relative 'model/account_alias'
require_relative 'model/account_role'
require_relative 'cli/cli'
