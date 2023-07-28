class Tinderbox::Command::ShowAccount
  include Tinderbox::Command

  command 'show-account'

  calling_convention(1..) do
    self.banner = 'Usage: show-account [options] <account id | account alias> ...'

    self.on('--invoices', 'Show list of invoices') do
      options[:display_list_invoices] = true
    end

    self.on('--payments', 'Show list of payments') do
      options[:display_list_payments] = true
    end
  end

  run do |options:, arguments:|
    accounts =
      Tinderbox::Account.from_output_list_accounts(
        Tinderbox::Calls.litcli_accounts_list
      )

    arguments.each do |id_or_alias|
      id = Tinderbox::AccountAlias.get_id(id_or_alias) || id_or_alias

      matching_accounts =
        accounts.select { |account| account.instance_variable_get(:@id) == id }

      case matching_accounts.count
      when 0
        Tinderbox.log.error("No account found for #{id_or_alias}")
        next
      when 1
        account = matching_accounts.first

        if options[:display_list_invoices] && options[:display_list_payments]
          puts 'Invoices'.cyan.bold
          puts '----------------'
          account.display_list_invoices(account.invoices)
          puts
          puts 'Payments'.magenta.bold
          puts '----------------'
          account.display_list_payments(account.payments)
        elsif options[:display_list_invoices]
          account.display_list_invoices(account.invoices)
        elsif options[:display_list_payments]
          account.display_list_payments(account.payments)
        else
          account.display(show_details: true)
        end
      else
        Tinderbox.log.error("Multiple account matches for #{id_or_alias}")
        raise 'encountered unexpected output'
      end
    end
  end
end
