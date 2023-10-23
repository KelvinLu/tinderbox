class Tinderbox::Page::Account < OpenStruct
  def initialize(account_id:)
    Tinderbox::AccountAlias.reload

    accounts = Tinderbox::Account.from_output_list_accounts(
      Tinderbox::Calls.litcli_accounts_list
    )

    matching_accounts =
      accounts.select { |account| account.instance_variable_get(:@id) == account_id }

    account =
      case matching_accounts.count
      when 0
        nil
      when 1
        matching_accounts.first
      else
        nil
      end

    payments_total = account&.payments&.filter { |p| p.fetch('state') == 'SUCCEEDED' }&.sum { |p| p.fetch('full_amount').to_i }

    super(
      account_id_parameter: account_id,

      account: account,

      payments_total: payments_total,

      account_roles: Tinderbox::Configuration::AccountRole.account_roles
    )
  end
end
