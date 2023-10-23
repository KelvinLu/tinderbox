require 'erb'

require_relative '../page'

class Tinderbox::Server::PageRenderer < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    response['Content-Type'] = 'text/html'

    case request.path
    when '/'
      html_page('index.erb.html', response) do
        require_relative '../page/index'
        Tinderbox::Page::Index.new
      end
    when /^\/account\/([0-9a-f]{16})$/
      html_page('account.erb.html', response) do
        require_relative '../page/account'
        Tinderbox::Page::Account.new(account_id: $1)
      end
    when /^\/create-account$/
      html_page('create-account.erb.html', response)
    when /^\/remove-account\/([0-9a-f]{16})$/
      html_page('remove-account.erb.html', response) do
        require_relative '../page/remove_account'
        Tinderbox::Page::RemoveAccount.new(account_id: $1)
      end
    when /^\/lndconnect\/([0-9a-f]{16})\/([a-zA-Z_-]+)$/
      html_page('lndconnect.erb.html', response) do
        require_relative '../page/lndconnect'
        Tinderbox::Page::LNDConnect.new(account_id: $1, account_role: $2)
      end
    else
      response.status = 404
    end
  end

  def html_page(filename, response, &block)
    erb_template =
      page_cache(filename) {
        filepath = File.join(File.expand_path(File.dirname(__FILE__)), '../resources/html/', filename)

        raise "Could not read #{filepath}" unless File.exist?(filepath) && File.readable?(filepath)

        ERB.new(File.read(filepath))
      }

    response.body = erb_template.result_with_hash(block.nil? ? {} : block.call)
    response.status = 200
  end

  def page_cache(filename, &block)
    (@@page_cache ||= {}).fetch(filename) do
      @@page_cache[filename] = block.call
    end
  end
end
