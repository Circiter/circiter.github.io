# Written by Circiter (mailto:xcirciter@gmail.com).

# TODO: Add support for other numeration styles (e.g., latin
# or alphabet instead of arabic).
# Possible styles: arabic-zero, arabic-one, latin, alpha, custom (?).

# TODO: Implement the html anchors generation.

module LabelsSingleton
    # TODO: Consider to use a hash map of
    # namespaces each containing an array
    # of labels.
    #@referenced_labels=Hash.new
    #@defined_labels=Hash.new
    @referenced_labels=Array.new
    @defined_labels=Array.new

    def self.register_referenced(namespace, label)
        @referenced_labels<<namespace+"::"+label if label!=""
        #@referenced_labels[namespace]=Array.new unless @referenced_labels.has_key?(namespace)
        #@referenced_labels[namespace]<<label if label!=""
    end

    def self.register_defined(namespace, label)
        @defined_labels<<namespace+"::"+label if label!=""
        # FIXME.
        #@defined_labels[namespace]=Array.new unless @defined_labels.has_key?(namespace)
        #@defined_labels[namespace]<<label if label!=""
    end

    def self.find_referenced(namespace, identifier)
        index=0
        @referenced_labels.each do |label|
            return index if label==namespace+"::"+identifier
            index=index+1 if label.start_with?(namespace+"::")
        end
        return nil
        #return @referenced_labels[namespace].find_index(identifier)
    end

    def self.find_defined(namespace, identifier)
        index=0
        @defined_labels.each do |label|
            return index if label==namespace+"::"+identifier
            index=index+1 if label.start_with?(namespace+"::")
        end
        return index
        #return @defined_labels[namespace].find_index(identifier)
    end

    def self.referenced_count(namespace)
        return @referenced_labels.count do |label|
            label.start_with?(namespace+"::")
        end
        #return #referenced_labels[namespace].length
    end

    def self.defined_count(namespace)
        return @defined_labels.count do |label|
            label.start_with?(namespace+"::")
        end
        #return @defined_labels[namespace].length
    end

    def self.cleanup()
        set1=@defined_labels.to_set
        set2=@referenced_labels.to_set
        diff=set1-set2 # FIXME.
        diff.each do |label|
            puts "numbered-labels.rb: undefined label "+label
        end
        @defined_labels.clear
        @referenced_labels.clear
    end
end

# FIXME: Is it possible to use
#        Jekyll::Hooks.register(:pages, :post_render, LabelsSingleton::cleanup)?
Jekyll::Hooks.register(:pages, :post_render) do |target, payload|
    if target.ext=="md"&&(target.basename=="about"||target.basename=="index")
        LabelsSingleton::cleanup
    end
end

Jekyll::Hooks.register(:blog_posts, :post_render) do |target, payload|
    if target.data["ext"]==".md"
        LabelsSingleton::cleanup
    end
end

#use_other_numeration_style=!config["numeration_style"].nil? && !config["numeration_style"].empty?
#numeration_style=config["numeration_style"]

module Jekyll
    class Label < Liquid::Tag
        def initialize(name, params, tokens)
            @tag_name=name
            parameters=params.gsub("  ", " ").split(" ")
            @namespace=parameters[0]
            @identifier=parameters[1]
           super
        end

        def render(context)
            id=context["page"]["id"]
            number=LabelsSingleton::find_defined(@namespace, @identifier)
            number_in_referenced=LabelsSingleton::find_referenced(@namespace, @identifier)

            to_register_in_referenced=""
            to_register_in_defined=""

            if @tag_name=="def"
                if number==nil
                    to_register_in_defined=@identifier
                else
                    puts "numbered-labels.rb: multiple definitions of "+@identifier
                end

                number=number_in_referenced

                number=LabelsSingleton::defined_count(@namespace) if number==nil
            else
                to_register_in_referenced=@identifier if number_in_referenced==nil

                if number==nil
                    if number_in_referenced==nil
                        number=LabelsSingleton::referenced_count(@namespace)
                    else
                        number=number_in_referenced
                    end
                end
            end

            LabelsSingleton::register_referenced(@namespace, to_register_in_referenced)
            LabelsSingleton::register_defined(@namespace, to_register_in_defined)

            number=number+1
            return "#{number}"
        end
    end
end

Liquid::Template.register_tag("ref", Jekyll::Label)
Liquid::Template.register_tag("def", Jekyll::Label)
