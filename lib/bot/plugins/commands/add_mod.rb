require 'cinch'
require_relative 'base_command'

module Plugins
  module Commands
    class AddMod < AuthorizedCommand
      include Cinch::Plugin
      ignore_ignored_users

      set(help: 'Adds a mod to the list of mods on the main page. Op-only. 1 arg: $addmod <mod name>',
          plugin_name: 'addmod')
      set(help: 'Adds a mod to the list of minor mods on the main page. Op-only. 1 arg: $addminor <mod name>',
          plugin_name: 'addminor')
      match(/addmod (.+)/i, method: :execute_major)
      match(/addminor (.+)/i, method: :execute_minor)

      # Adds the mod to the list of mods on the main page of the FTB wiki.
      #   Unlike most other execute methods, this one is not actually called
      #   directly by match.
      # @param msg [Cinch::Message]
      # @param mod [String] The mod's name.
      # @param minor [Boolean] Whether the mod is considered minor or not.
      def execute(msg, mod, minor = false)
        butt = LittleHelper.init_wiki
        page = minor ? 'Template:Minor Mods'.freeze : 'Template:Mods'.freeze
        category = minor ? 'Category:Minor Mods'.freeze : 'Category:Mods'.freeze

        if butt.get_text(mod).nil?
          msg.reply('Sorry, that mod is not a valid page.'.freeze)
          return
        end

        if butt.get_categories_in_page(mod).include?(category)
          text = butt.get_text(page)
          text.gsub!('<noinclude>', '')
          text.gsub!('<translate>', '')
          text.gsub!('<!--T:1-->', '')
          text.gsub!('</noinclude>', '')
          text.gsub!('</translate>', '')
          text.gsub!(/^$\n/, '')
          text.gsub!(/\{\{L\|\w+\}\}\n/, "{{L|\\1}} {{*}}\n")
          text << "\n{{L|#{mod}}} {{*}}"
          lines = text.split(/\n/)
          lines = lines.sort
          text = lines.join("\n")
          text.gsub!("{{*}}\n<", "\n<")
          text.prepend("<noinclude><translate><!--T:1-->\n</noinclude>")
          text << '<noinclude></translate></noinclude>'
          edit = butt.edit(page, text, true, true, "Add #{mod}")
          if edit.is_a?(Fixnum)
            msg.reply("Successfully added #{mod} to #{page}")
          else
            msg.reply("Failed! Error code: #{edit}")
          end
        else
          msg.reply('Sorry, that page is not in its assumed category.'.freeze)
        end
      end

      # Adds a major (non-minor) mod to the main page list.
      # @param msg [Cinch::Message]
      # @param mod [String] The mod to add.
      def execute_major(msg, mod)
        execute(msg, mod)
      end

      # Adds a minor mod to the main page list.
      # @param msg [Cinch::Message]
      # @param mod [String] The mod to add.
      def execute_minor(msg, mod)
        execute(msg, mod, true)
      end
    end
  end
end
