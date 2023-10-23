require 'open3'
require 'base64'

class Tinderbox::Page::LNDConnect < OpenStruct
  def initialize(account_id:, account_role:)
    permissions = Tinderbox::Configuration::AccountRole.get_permissions(account_role)

    macaroon_filepath = File.join(Tinderbox::Server.macaroon_directory, "tinderbox-#{account_id}.#{account_role.gsub(/[^\w_-]/, '')}.macaroon")

    image_png_content =
      Dir.mktmpdir do |tmpdir|
        unless File.exist?(macaroon_filepath)
          tmpfile = File.join(tmpdir, 'tmp.macaroon')

          Tinderbox::Calls.lncli_bakemacaroon(filepath: tmpfile, permissions: permissions)
          Tinderbox::Calls.lncli_constrainmacaroon(old_filepath: tmpfile, new_filepath: macaroon_filepath, account_id: account_id)
        end

        lndconnect(
          '--host', Tinderbox::Server.node_host,
          '--port', Tinderbox::Server.node_port.to_s,
          '--image',
          macaroon_filepath: macaroon_filepath,
          chdir: tmpdir
        )

        image_filepath = File.join(tmpdir, 'lndconnect-qr.png')

        raise 'error generating QR code image' unless File.exist?(image_filepath)

        Base64.encode64(File.read(image_filepath))
      end

    lndconnect_url = lndconnect(
      '--host', Tinderbox::Server.node_host,
      '--port', Tinderbox::Server.node_port.to_s,
      '--url',
      macaroon_filepath: macaroon_filepath
    ).lines.last.strip.gsub("\t", '')

    super(
      account_id: account_id,
      account_role: account_role,

      host: Tinderbox::Server.node_host,
      port: Tinderbox::Server.node_port,

      lndconnect_url: lndconnect_url,
      image_png_content: image_png_content,
    )
  end

  def lndconnect(*args, macaroon_filepath:, chdir: nil)
    opts = {}
    opts[:chdir] = chdir unless chdir.nil?

    stdout, stderr, status =
      Open3.capture3(
        Tinderbox::Server.lndconnect_filepath.to_s,
        '--readonlymacaroonpath',
        macaroon_filepath,
        '--readonly',
        *args,
        **opts
      )

    $stderr.print stderr unless stderr.strip.empty?
    raise 'error calling lndconnect' unless status.success?

    stdout
  end
end
