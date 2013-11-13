module ResolutionTreesHelper
  #Get an array of drop-down objects representing each node in the resolution tree
  def drop_downs_for_resolution_tree(resolution, ignored_resolution=nil)
    #Prepare drop-down object for easier use by rails form_helper
    def prepare_drop_down(values, chosen, name, reject)
      return {
        options: values.reject{ |val| !reject.nil? && val.name == reject.name }
                        .collect{ |cat| [cat.name, cat.id] },
        selected: chosen,
        label: "resolution-" + name
      }
    end

    drop_downs = []
      
    if resolution.nil?
      drop_downs << prepare_drop_down(IssueResolution.roots, 0, "root", ignored_resolution)
    else #get child resolution options
      drop_downs << prepare_drop_down(resolution.children, 0, "level-end", ignored_resolution) if !resolution.leaf?
        
      level = 0
      #Traverse the tree to the root resolution
      while !resolution.nil?
        if(resolution.root?)
          values = IssueResolution.roots
          name = "root"
        else
          values = resolution.parent.children
          name = "level-" + level.to_s
        end

        drop_downs << prepare_drop_down(values, resolution.id, name, ignored_resolution)
        resolution = resolution.parent
        level += 1
      end
    end
    return drop_downs.reverse
  end
end