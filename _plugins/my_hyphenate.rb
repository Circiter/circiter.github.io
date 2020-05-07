require "nokogiri"
require "text/hyphen"

# Based on jekyll-hyphenate_filter.

module Jekyll
    module MyHyphenateFilter
        class Hyphenator
            def initialize()
                @hyphenator=Text::Hyphen.new(language: "ru", left: 2, right: 2)
            end

            def hyphenate(content)
                fragment=Nokogiri::HTML::DocumentFragment.parse(content)
                fragment.css("p").each do |element|
                    element.traverse do |node|
                        node.content=hyphenate_text(node.to_s) if node.text?
                    end
                end
            end

            def hyphenate_text(text)
                word=text.split
                words.each do |word|
                    #regex=/#{Regexp.escape(word)}(?!\z)/
                    regex=/#{word}(?!\z)/
                    hyphenate_word=@hyphenator.visualize(word, "&shy;")
                    #text.gsub!(/#{word}/hyphenated_word)
                    text.gsub!(regex, hyphenated_word)
                end
            end
        end

        def my_hyphenate(content)
            hyphenator=Hyphenator.new()
            hyphenator.hyphenate(content)
        end
    end
end

Liquid::Template.register_filter(Jekyll::MyHyphenateFilter)
