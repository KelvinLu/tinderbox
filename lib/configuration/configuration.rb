require 'yaml'

module Tinderbox::Configuration
  def self.included(base)
    base.extend ConfigurationFile
  end

  module ConfigurationFile
    attr_reader :filepath, :configuration

    @filepath = nil
    @configuration = nil

    def file(filepath)
      filepath = File.join(File.dirname(__FILE__), '../../configuration', filepath)
      raise "file at #{filepath} not found" unless File.exist?(filepath)

      @filepath = filepath
      @configuration = YAML.safe_load(File.read(filepath))
    end
  end
end

require_relative './litcli'
require_relative './lncli'
require_relative './account_alias'
require_relative './account_role'
