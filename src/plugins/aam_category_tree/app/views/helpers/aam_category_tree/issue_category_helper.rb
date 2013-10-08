module AamCategoryTree
  module IssueCategoryHelper
    def issue_category_tree_options_for_select(issue_categories, options={})
      s = ''
      issue_category_tree(issue_categories) do |category, level|
        if category.nil? || category.id.nil?
          next
        end

        name_prefix = (level > 0 ? '|&nbsp;&nbsp;' * level + '&#8627; ' : '')
        if name_prefix.length > 0
          name_prefix = name_prefix.slice(1, name_prefix.length)
        end
        name_prefix = name_prefix.html_safe
        tag_options = { :value => category.id }
        if !options[:selected].nil? && category.id == options[:selected]
          tag_options[:selected] = 'selected'
        else
          tag_options[:selected] = nil
        end

        if !options[:current].nil? && options[:current].id == category.id
          tag_options[:disabled] = 'disabled'
        end

        tag_options.merge!(yield(category)) if block_given?
        s << content_tag('option', name_prefix + h(category), tag_options)
      end
      s.html_safe
    end
		
		#Prepare drop-down object for easier use by rails form_helper
		def prepare_drop_down(values, chosen, name)
			return {
				options: values.collect{ |cat| [cat.name, cat.id] },
				selected: chosen,
				label: "category-" + name
			}
		end
		
		#Get an array of drop-down objects representing each node in the category tree
		def drop_downs_for_category_tree(category)
			drop_downs = []
			
			if category.nil?
				drop_downs << prepare_drop_down(IssueCategory.roots, 0, "root")
			else #get child category options
				drop_downs << prepare_drop_down(category.children, 0, "level-end") if !category.leaf?
				
				level = 0
				#Traverse the tree to the root category
				while !category.nil?
					if(category.root?)
						values = IssueCategory.roots
						name = "root"
					else
						values = category.parent.children
						name = "level-" + level.to_s
					end

					drop_downs << prepare_drop_down(values, category.id, name)
					category = category.parent
					level += 1
				end
			end
			return drop_downs.reverse
		end
		
    def issue_category_tree(issue_categories, &block)
      IssueCategory.issue_category_tree(issue_categories, &block)
    end

    def render_issue_category_with_tree(category)
      s = ''
      if category.nil?
        return ''
      end
      ancestors = category.root? ? [] : category.ancestors.all
      if ancestors.any?
        s << '<ul id="issue_category_tree">'
        ancestors.each do |ancestor|
          s << '<li>' + content_tag('span', h(ancestor.name)) + '<ul>'
        end
        s << '<li>'
      end

      s << content_tag('span', h(category.name), :class => 'issue_category')

      if ancestors.any?
        s << '</li></ul>' * (ancestors.size + 1)
      end
      s.html_safe
    end
    
    def render_issue_category_with_tree_inline(category)
      s = ''
      if category.nil?
        return ''
      end
      ancestors = category.root? ? [] : category.ancestors.all
      if ancestors.any?
        ancestors.each do |ancestor|
          s << content_tag('span', h(ancestor.name), :class => 'parent')
        end
      end

      s << content_tag('span', h(category.name), :class => 'issue_category')
      
      if ancestors.any?
        s = content_tag('span', s, { :class => 'issue_category_tree' }, false)
      end
      s.html_safe
    end
    
    def move_category_path(category, direction)
      url_for({ :controller => 'issue_categories', :action => 'move_category', :id => category.id, :direction => direction })
    end
  end
end
