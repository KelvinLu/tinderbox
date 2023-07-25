require_relative 'colors'
require_relative '../command/command'

class Tinderbox::CLI
  def self.start
    Tinderbox::Command.start_command
  end
end

