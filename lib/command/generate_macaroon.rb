require 'pathname'
require 'tmpdir'

class Tinderbox::Command::GenerateMacaroon
  include Tinderbox::Command

  command 'generate-macaroon'

  calling_convention(3) do
    self.banner = 'Usage: generate-macaroon [options] <account id | account alias> <role> <macaroon filepath>'

    self.on('--tmp-directory=DIRECTORY', 'Directory for storing temporary files') do |directory|
      options[:tmp_directory] = directory
    end
  end

  run do |options:, arguments:|
    id_or_alias = arguments[0]
    id = Tinderbox::AccountAlias.get_id(id_or_alias) || id_or_alias

    role = arguments[1]
    macaroon_filepath = arguments[2]

    macaroon_filepath = Pathname.new(macaroon_filepath)
    macaroon_filepath = Pathname.new(File.expand_path(macaroon_filepath)) unless macaroon_filepath.absolute?

    if macaroon_filepath.exist?
      raise 'path must be to a file, not a directory' if macaroon_filepath.directory?
      raise "#{macaroon_filepath} not writable" unless macaroon_filepath.writable?
    else
      raise "#{macaroon_filepath.dirname} not writable" unless macaroon_filepath.dirname.writable?
    end

    permissions = Tinderbox::Configuration::AccountRole.get_permissions(role)

    puts "#{'Account:'} #{id.cyan.underline}"
    puts "#{'Role:'} #{role.magenta.bold}"

    permissions.each do |permission|
      puts "  - #{permission.italic}"
    end

    Dir.mktmpdir(nil, options[:tmp_directory]) do |tmpdir|
      tmpfile = File.join(tmpdir, 'tmp.macaroon')

      Tinderbox::Calls.lncli_bakemacaroon(filepath: tmpfile, permissions: permissions)
      Tinderbox::Calls.lncli_constrainmacaroon(old_filepath: tmpfile, new_filepath: macaroon_filepath.to_s, account_id: id)
    end
  end
end
