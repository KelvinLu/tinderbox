class Tinderbox::Server::Command < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    query_params = request.query

    case request.path
    when '/command/create-account'
      create_account(response, query_params)
    when '/command/update-account'
      update_account(response, query_params)
    when '/command/remove-account'
      remove_account(response, query_params)
    else
      response.status = 404
    end
  end

  def redirect(response, url)
    response.status = 302
    response['Location'] = url
  end

  def create_account(response, query_params)
    account_alias = query_params['alias']

    initial_balance = query_params['initial-balance']

    raise 'must provide an initial balance' if initial_balance.nil? || initial_balance.empty?
    initial_balance = initial_balance.to_i

    expiration = query_params['expiration']
    expiration = Time.parse(expiration) unless expiration.nil? || expiration.empty?

    output = Tinderbox::Calls.litcli_accounts_create(
      balance: initial_balance,
      expiration_date: expiration
    )

    account = Tinderbox::Account.new(output.fetch('account'), account_alias: account_alias)

    Tinderbox::AccountAlias.add_alias(account.id, account.account_alias) unless account.account_alias.nil?

    redirect(response, "/account/#{account.id}")
  end

  def update_account(response, query_params)
    account_id = query_params['account-id']

    account_alias = query_params['add-alias']

    set_balance = query_params['set-balance']&.to_i

    expiration = query_params['set-expiration']

    if !expiration.nil?
      raise 'cannot both set and remove expiration' unless query_params['remove-expiration'].nil?
      expiration = Time.parse(expiration)
    elsif query_params.key?('remove-expiration')
      raise 'cannot both set and remove expiration' unless expiration.nil?
      expiration = 0
    end

    unless account_alias.nil?
      Tinderbox::AccountAlias.add_alias(account_id, account_alias)
    end

    Tinderbox::Calls.litcli_accounts_update(
      id: account_id,
      balance: set_balance || -1,
      expiration_date: (expiration || -1).to_i
    )

    redirect(response, "/account/#{account_id}")
  end

  def remove_account(response, query_params)
    account_id = query_params['account-id']

    Tinderbox::Calls.litcli_accounts_remove(id: account_id)

    redirect(response, '/')
  end
end
