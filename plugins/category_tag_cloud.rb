# encoding: utf-8
# WP-Cumulus for Octopress, originally developed by weefselkweekje and LukeMorton for WordPress.
# Ported to Octopress by Joseph Z. Chang.
#
# Link to WP-Cumulus: http://wordpress.org/extend/plugins/wp-cumulus/
#
# =======================
# 
# Description:
# ------------
# Generate a flash based dynamic tag cloud.
# 
# Syntax:
# -------
#     {% category_cloud %} for default colors
#
#     OR
#
#     {% tag_cloud bgcolor:#ffffff tcolor1:#00aa00 tcolor2:#00dd00 hicolor:#ff3333 %}
# 
# Example:
# --------
# In some template files, you can add the following markups.
# 
# ### source/_includes/custom/asides/category_cloud.html ###
# 
#     <section>
#       <h1>Tag Cloud</h1>
#         <span id="tag-cloud">{% tag_cloud bgcolor:#ffffff tcolor1:#00aa00 tcolor2:#00dd00 hicolor:#ff3333%}</span>
#     </section>
# 
# 
# License:
# ---------
# WP-Cumulus is under GPLv3. However, original javascript and php code are not used, only tagcloud.swf
# is adapted. This ruby code is under MIT License.
#
# GPLv3: http://gplv3.fsf.org
# MIT License: http://opensource.org/licenses/MIT
#

require 'stringex'

module Jekyll

  class CategoryCumulusCloud < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @opts = {}
      @opts['bgcolor'] = '#ffffff'
      @opts['tcolor1'] = '#333333'
      @opts['tcolor2'] = '#333333'
      @opts['hicolor'] = '#000000'
      @tag_name = tag_name;
    
      opt_names = ['bgcolor', 'tcolor1', 'tcolor2', 'hicolor']

      opt_names.each do |opt_name|
          if markup.strip =~ /\s*#{opt_name}:(#[0-9a-fA-F]+)/iu
            @opts[opt_name] = $1
            markup = markup.strip.sub(/#{opt_name}:\w+/iu,'')
          end
      end

      opt_names = opt_names[1..3]
      opt_names.each do |opt_name|
          @opts[opt_name] = '0x' + @opts[opt_name][1..8]
      end

      super
    end

    def render(context)
      lists = {}
      max, min = 1, 1
      config = context.registers[:site].config
      
      if @tag_name == 'tag_cloud'
        #cloud_dir = config['tag_dir']
		cloud_dir = context.registers[:site].config['tag_dir']
		cloud = context.registers[:site].tags
      else
        #cloud_dir = config['category_dir']
		cloud_dir = context.registers[:site].config['category_dir']
        cloud = context.registers[:site].categories
      end
      
      cloud_dir = config['url'] + config['root'] + cloud_dir + '/'
      #categories = context.registers[:site].categories
      cloud.keys.sort_by{ |str| str.downcase }.each do |item|
        count = cloud[item].count
        lists[item] = count
        max = count if count > max
      end

      bgcolor = @opts['bgcolor']

      bgcolor = @opts['bgcolor']
      tcolor1 = @opts['tcolor1']
      tcolor2 = @opts['tcolor2']
      hicolor = @opts['hicolor']

      html = ''
      html << "<embed type='application/x-shockwave-flash' src='/javascripts/tagcloud.swf'"
      html << "width='100%' height='250' bgcolor='#{bgcolor}' id='tagcloudflash' name='tagcloudflash' quality='high' allowscriptaccess='always'"

      html << 'flashvars="'
      html << "tcolor=#{tcolor1}&amp;tcolor2=#{tcolor2}&amp;hicolor=#{hicolor}&amp;tspeed=100&amp;distr=true&amp;mode=tags&amp;"

      html << 'tagcloud='

      tagcloud = ''
      tagcloud << '<tags>'


      lists.each do | item, counter |
        url = cloud_dir + item.gsub(/_|\P{Word}/u, '-').gsub(/-{2,}/u, '-').downcase.to_url
        style = "font-size: #{10 + (30 * Float(counter)/max)}%"

        tagcloud << "<a href='#{url}' style='#{style}'>#{item}"
        tagcloud << "</a> "

      end

      tagcloud << '</tags>'

      # tagcloud urlencode
      tagcloud = CGI.escape(tagcloud)
      
      html << tagcloud
      html << '">'
      html
    end
  end
end

Liquid::Template.register_tag('category_cloud', Jekyll::CategoryCumulusCloud)
Liquid::Template.register_tag('tag_cloud', Jekyll::CategoryCumulusCloud)
