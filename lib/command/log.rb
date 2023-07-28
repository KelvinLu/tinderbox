require 'yaml'

class Tinderbox::Command::Log
  include Tinderbox::Command

  command 'log'

  calling_convention(1) do
    self.banner = 'Usage: log [options] <log filepath>'

    self.on('--force', 'Write a log file, even if it appears to not be necessary') do
      options[:force] = true
    end
  end

  run do |options:, arguments:|
    log_filepath = Pathname.new(arguments.first)
    log_filepath = Pathname.new(File.expand_path(log_filepath)) unless log_filepath.absolute?

    last_update_log =
      if log_filepath.exist?
        raise 'path must be to a file, not a directory' if log_filepath.directory?
        raise "#{log_filepath} not writable" unless log_filepath.writable?

        File.stat(log_filepath).mtime
      else
        raise "#{log_filepath.dirname} not writable" unless log_filepath.dirname.writable?

        nil
      end

    output = Tinderbox::Calls.litcli_accounts_list
    accounts = Tinderbox::Account.from_output_list_accounts(output)
    last_update_account = accounts.max(&:last_update).last_update

    if options[:force] || last_update_log.nil? || (last_update_log < last_update_account)
      File.write(log_filepath, YAML.dump(
        accounts.map do |account|
          {
            'id' =>  account.id,
            'account_alias' =>  account.account_alias,
            'initial_balance' => account.initial_balance,
            'current_balance' => account.current_balance,
            'last_update' => account.last_update,
            'expiration_date' => account.expiration_date,
            'invoices_count' => account.invoices.count,
            'payments_count' => account.payments.count,
            'payments_total' => account.payments.group_by { |i| i.fetch('state') }.map { |state, payments| [state.downcase, payments.sum { |i| i.fetch('full_amount').to_i }] },
          }
        end
      ))
      puts 'Log file written'.bold
    else
      puts 'Log file is current'.italic
    end
  end
end
