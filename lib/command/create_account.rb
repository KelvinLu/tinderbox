require 'optparse/time'

class Tinderbox::Command::CreateAccount
  include Tinderbox::Command

  command 'create-account'

  calling_convention(0..1) do
    self.banner = 'Usage: create-account [options] [account alias]'

    self.on('--balance=AMOUNT', Integer, 'Set an initial amount of satoshi for the account') do |amount|
      options[:balance] = amount
    end

    self.on('--expiration=TIME', Time, 'Set an expiration date, given by a parseable string') do |expiration_date|
      options[:expiration_date] = expiration_date
    end
  end

  run do |options:, arguments:|
    raise 'balance must be provided' if options[:balance].nil?

    account_alias = arguments.first if arguments.count == 1

    output = Tinderbox::Calls.litcli_accounts_create(
      balance:          options[:balance],
      expiration_date:  options[:expiration_date]
    )

    account = Tinderbox::Account.new(output.fetch('account'), account_alias: account_alias)

    Tinderbox::AccountAlias.add_alias(account.id, account.account_alias) unless account.account_alias.nil?

    account.display(show_details: true)
  end
end
