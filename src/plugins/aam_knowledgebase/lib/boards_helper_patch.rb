require_dependency 'boards_helper'

module BoardsHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      
      alias_method_chain :board_breadcrumb, :articles
    end

  end
  
  module InstanceMethods
    # All this just the change the language string to "Knowledge Base", stupid plugin load order.
    def board_breadcrumb_with_articles(item)
      board = item.is_a?(Message) ? item.board : item
      links = [link_to(l(:label_questions), project_boards_path(item.project))]
      boards = board.ancestors.reverse
      if item.is_a?(Message)
        boards << board
      end
      links += boards.map {|ancestor| link_to(h(ancestor.name), project_board_path(ancestor.project, ancestor))}
      breadcrumb links
    end
  end
end