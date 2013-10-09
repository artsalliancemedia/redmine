module CategoryTreesHelper
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
end