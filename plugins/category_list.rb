module Jekyll
	class CategoryListTag < Liquid::Tag
		def render(context)
			html = ""
			categories = context.registers[:site].categories.keys
			categories.sort.each do |category|
				posts_in_category = context.registers[:site].categories[category].size
				category_dir = context.registers[:site].config['category_dir']
				#category_url = File.join(category_dir, category.gsub(/_|\P{Word}/u, '-').gsub(/-{2,}/u, '-').downcase)
				#html << "<li class='category'><a href='/#{category_dir}/#{category.to_url}'>#{category} (#{posts_in_category})</a></li>\n"
				category_url = File.join(category_dir, category.to_url)
				html << "<li class='category'><a href='/#{category_url}/'>#{category} (#{posts_in_category})</a></li>\n"
			end
			html
		end
	end
end

Liquid::Template.register_tag('category_list', Jekyll::CategoryListTag)					
