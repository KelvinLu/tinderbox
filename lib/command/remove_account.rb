class Tinderbox::Command::RemoveAccount
  include Tinderbox::Command

  command 'remove-account'

  calling_convention(1) do
    self.banner = 'Usage: remove-account [options] <account id | account alias>'
  end

  run do |options:, arguments:|
    id_or_alias = arguments.first
    id = Tinderbox::AccountAlias.get_id(id_or_alias) || id_or_alias

    Tinderbox::Calls.litcli_accounts_remove(id: id)

    puts "Removed account #{id_or_alias}".red.bold
  end
end
