require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class Upload < AuthorizedCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Uploads a web file to the wiki. Op-only. 2 args: $upload <url to upload> <filename to upload to>',
          plugin_name: 'upload')
      match(/upload (.*) (.*)/)

      # Uploads a file to the wiki.
      # @param msg [Cinch::Message]
      # @param url [String] The URL to upload.
      # @param filename [String] The file's name on the wiki.
      def execute(msg, url, filename)
        butt = LittleHelper.init_wiki
        upload = butt.upload(url, filename)
        if upload
          msg.reply('Uploaded the file to the wiki!'.freeze)
        else
          msg.reply('Possibly failed! Check my logs!')
        end
      end
    end
  end
end
