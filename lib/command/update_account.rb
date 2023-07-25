require 'optparse/time'

class Tinderbox::Command::UpdateAccount
  include Tinderbox::Command

  command 'update-account'

  calling_convention(1) do
    self.banner = 'Usage: update-account [options] <account id | account alias>'

    self.on('--balance=AMOUNT', Integer, 'Update the current balance for the account') do |amount|
      options[:balance] = amount
    end

    self.on('--expiration=TIME', Time, 'Set an expiration date, given by a parseable string') do |expiration_date|
      options[:expiration_date] = expiration_date
    end

    self.on('--no-expiration', 'Remove the expiration date (incompatible with --expiration)') do
      options[:no_expiration] = true
    end
  end

  run do |options:, arguments:|
    raise 'command may not be instructed to both set and remove an expiration date' if !options[:expiration_date].nil? && options[:no_expiration]
    raise 'command has nothing to do' if [options[:balance], options[:expiration_date], options[:no_expiration]].all?(&:nil?)

    id_or_alias = arguments.first
    id = Tinderbox::AccountAlias.get_id(id_or_alias) || id_or_alias

    expiration_date =
      if options[:no_expiration]
        0
      else
        options.fetch(:expiration_date, -1)
      end

    output = Tinderbox::Calls.litcli_accounts_update(id: id, balance: options.fetch(:balance, -1), expiration_date: expiration_date)

    account = Tinderbox::Account.new(output, account_alias: id_or_alias == id ? nil : id_or_alias)

    account.display(show_details: true)
  end
end
