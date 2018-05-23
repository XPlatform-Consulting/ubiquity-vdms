require 'base64'
require 'cgi'
require 'json'
require 'logger'
require 'openssl'
require 'uri'
require 'zlib'

require 'ubiquity/vdms/uplynk/api/client/http_client'

module Ubiquity

  module VDMS

    module Uplynk

      module API

        class Client

          attr_accessor :http_client, :request, :response, :logger

          attr_accessor :owner, :secret

          def initialize(args = { })
            @http_client = HTTPClient.new(args)

            @owner = args[:owner] || args[:username]
            @secret = args[:secret] || args[:password]

            @logger = http_client.logger
          end

          def message_encode(msg, _owner = owner)
            msg['_owner'] = _owner
            msg['_timestamp'] = Time.now.to_i
            msg = JSON.generate(msg)

            msg = Zlib::Deflate.deflate(msg, 9)
            msg = Base64.encode64(msg).strip

            msg
          end

          def signature_generate(encoded_msg, _secret = secret)
            OpenSSL::HMAC.hexdigest('sha256', _secret, encoded_msg)
          end

          def encode_body(body)
            msg = message_encode(body)
            sig = signature_generate(msg)
            _body = "msg=#{CGI.escape(msg)}&sig=#{CGI.escape(sig)}"
          end

          def post(path, body = { }, opts = { })
            _body = encode_body(body)
            http_client.post(path, _body, opts)
          end

          # Retrieves a specific asset from your library.
          # @see https://support.uplynk.com/doc_integration_apis_asset.html
          #
          # Request parameters
          # +--------------+--------+-------------------------------------------------------------------------------+
          # | id           | string | (optional*) the asset's ID                                                    |
          # | external_id  | string | (optional*) the asset's external ID                                           |
          # | ids          | list   | (optional*) a list of assets' IDs to be returned as a list of assets          |
          # | external_ids | list   | (optional*) a list of assets' external IDs to be returned as a list of assets |
          # +--------------+--------+-------------------------------------------------------------------------------+
          # * One of id, external_id, ids, external_ids must be specified.
          #
          # @param [Hash] args
          # @option args [String] id
          # @option args [String] external_id
          # @option args [<Array>String] ids
          # @option args [<Array>String] external_ids
          #
          # @param [Hash] opts
          #
          # @return [Hash]
          def asset_get(args = { }, opts = { })
            post('asset/get', args, opts)
          end

          # Returns a base64 representation of the specified frame from the highest bitrate variant of the specified asset.
          #
          # Request parameters
          # +----+------------+-------------------------------------------------------------------------------------------------------------------+
          # | id | int        | ID of the asset from which to grab a frame                                                                        |
          # | ts | int/string | Timestamp of the frame to grab. Specify in milliseconds as an integer, or as a string in the 'hh:mm:ss.ms' format |
          # +----+------------+-------------------------------------------------------------------------------------------------------------------+
          #
          # Response parameters
          #
          # @param [Hash] args
          # @param [Hash] opts
          # @return [Hash]
          def asset_getframe(args = { }, opts = { })

          end
          alias :asset_get_frame :asset_getframe

          # Lists or searches for assets.
          #
          # Request parameters
          # +--------+---------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
          # | search | string  | (optional) Text to search for in the asset's description, ID, or external ID.                                                                                                                                                                                          |
          # | limit  | integer | (optional) Cap the number of items returned, maximum of 100 items.                                                                                                                                                                                                     |
          # | skip   | integer | (optional) Skip the first N results. The skip and limit parameters can be used together for paginated results.                                                                                                                                                         |
          # | order  | string  | (optional) Sort the results by the given field. Supported fields include: desc, created, lastmod, duration, state, and external_id. Prefix the sort field with a minus sign for descending order (e.g. order='-desc' to retrieve values in reverse alphabetical order) |
          # +--------+---------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
          #
          # Response parameters
          # +--------+------+----------------------------------------------------------------------+
          # | assets | list | A list of assets, where each matches the form returned by asset/get. |
          # +--------+------+----------------------------------------------------------------------+
          #
          # @param [Hash] args
          # @param [Hash] opts
          # @return [Hash]
          def asset_list(args = { }, opts = { })
            post('asset/list', args, opts)
          end

          # Modifies an asset in your library.
          #
          # Request parameters
          # +------------------+--------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
          # | id               | string | (optional*) the ID of the asset to modify                                                                                                                                                                                                                                       |
          # | external_id      | string | (optional*) A new external_id for the asset. Note: if you retrieved the asset by external ID, you cannot also update the external ID at the same time.                                                                                                                          |
          # | desc             | string | (optional) A description for the asset                                                                                                                                                                                                                                          |
          # | test_player_url  | any    | (optional) Specifying any value for this parameter will cause a new test player URL to be generated. Note that this does not expire any existing test players; it adds a new test player to the list of test players. To expire a test player please use the CMS web interface. |
          # | embed_player_url | any    | (optional) Specifying any value for this parameter will cause a new embed player URL to be generated.                                                                                                                                                                           |
          # | require_drm      | int    | (optional) Specify a 1 to enable required tokens. Specify a 0 to disable required tokens.                                                                                                                                                                                       |
          # | meta             | string | (optional) The metadata to set on the asset. This must be a dictionary in JSON format. If the asset has existing meta, any new meta will be merged. To clear all metadata, set to '{}'.                                                                                         |
          # | poster_img       | string | (optional) The image to be used for this asset's poster image, as a base64-encoded string. Limited to images that are smaller than 3MB before base64 encoding. To reset the asset's poster image, set to the empty string ''.                                                   |
          # | autoexpire       | string | (optional) A timestamp in milliseconds after which the asset will be deleted automatically. Use a value of 0 to indicate that the asset should not auto-expire.                                                                                                                 |
          # +------------------+--------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
          # * Either id or external_id must be specified.
          #
          # @param [Hash] args
          # @param [Hash] opts
          # @return [Hash]
          def asset_update(args = { }, opts = { })
            post('asset/update')
          end



          # @see https://support.uplynk.com/doc_integration_apis_cloudslicer.html#jobscancel
          def cloudslicer_job_cancel(args = { }, opts = { })
            post('cloudslicer/jobs/cancel', args, opts)
          end

          # @see https://support.uplynk.com/doc_integration_apis_cloudslicer.html#jobscreate
          def cloudslicer_job_create(args = { }, opts = { })
            post('cloudslicer/jobs/create', args, opts)
          end

          # @see https://support.uplynk.com/doc_integration_apis_cloudslicer.html#jobsdelete
          def cloudslicer_job_delete(args, opts)
            post('cloudslicer/jobs/delete', args, opts)
          end

          # @see https://support.uplynk.com/doc_integration_apis_cloudslicer.html#jobscexport
          def cloudslicer_job_export_create(args = { }, opts = { })
            post('cloudslicer/jobs/create_export', args, opts)
          end

          # @see https://support.uplynk.com/doc_integration_apis_cloudslicer.html#jobsget
          def cloudslicer_job_get(args = { }, opts = { })
            post('cloudslicer/jobs/get', args, opts)
          end

          # @see https://support.uplynk.com/doc_integration_apis_cloudslicer.html#jobsqc
          def cloudslicer_job_quickclip_create(args = { }, opts = { })
            post('cloudslicer/jobs/quickclip', args, opts)
          end

          # @see https://support.uplynk.com/doc_integration_apis_cloudslicer.html#jobslist
          def cloudslicer_jobs_list(args = { }, opts = { })
            post('cloudslicer/jobs/list', args, opts)
          end

          # Client
        end

        # API
      end

      # Uplynk
    end


    # VDMS
  end

  # Ubiquity
end