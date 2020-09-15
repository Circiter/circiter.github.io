# For each tag like "programming", you will have a page that lists all posts with that tag
# at /programming.

# Original code from jameshfisher.com
# Modified by Circiter.

require "fileutils"

module Jekyll
    class TagPageGenerator < Generator
        def generate(site)
            posts=site.collections["blog_posts"]
            tags=posts.docs.flat_map{|post| post.data["tags"]||[]}.to_set
            tags.each do |tag|
                site.pages << TagPage.new(site, site.source, tag)
            end
        end
    end

    class TagPage < Page
        def initialize(site, base, tag)
            @site=site
            @base=base
            @dir=File.join('tag', tag)
            @name='index.html'
            @tagdescriptor=TagDescriptor.new()

            self.process(@name)
            self.read_yaml(File.join(base, "_layouts"), "tag.html")
            self.data['tag']=tag
            description=@tagdescriptor.get_description(tag)
            self.data['description']=description if description!=""
            self.data['title']=self.data['title'].gsub(/@/, "#{tag}");
            self.data['permalink']=@dir
        end
    end

    class TagDescriptor
        def initialize()
            i=0
            @descriptions=Array.new()
            @ntags=Set.new()
            read_description=false
            #print "[debug] in tags.rb: reading tags and its synonyms..."
            IO.foreach("tags_synonyms.txt") do |line|
                #print "[debug] in tags.rb: current line: "+line
                if read_description
                    #print "[debug] in tags.rb: description readed: "+line
                    @descriptions[i]=line.downcase
                    i=i+1
                else
                    #printf "[debug] in tags.rb: tag line readed: "+line
                    @ntags<<line.downcase.split(" ");
                end
                read_description=!read_description
            end
            #print "raw view of @ntags:"
            #print @ntags
        end

        def get_description(tag)
            tag=tag.downcase
            i=0
            @ntags.each do |synonyms|
                return @descriptions[i] if synonyms.include?(tag)
                i=i+1
            end
            print "[debug] description for the tag "+tag+" not found"
            return ""
        end
    end
end
