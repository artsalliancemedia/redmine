//Converts the category filter from flat list to nested drop_down format.
//Some of Redmine's event handlers are replaced in order for this to work - see public/application.js
function flat_list_filter_to_nested() {
	var filter_name = "category_id";
	 
	var cat_tree_name = "category-tree-dropdowns";
	var cat_tree_id = "#" + cat_tree_name;
	
	var redmine_cat_list_name = "values_"+ filter_name +"_1";
	var redmine_cat_op_id = "#operators_"+ filter_name;
	  
	var cat_tree = add_dropdowns_template();
	if(cat_tree.length) {
	  fix_operator_change_event();
	}
	
	$('#add_filter_select').off('change').change(function() {
	  var filter = $(this).val();
	  addFilter(filter, '', []);
	  if (filter === filter_name) {
		add_dropdowns_template();
		get_category_tree_dropdowns();
		$(redmine_cat_op_id).change(fix_operator_change_event);
	  }
	});
  
	//Apparrently Redmine uses an old version of jQuery.
	//Therefore, we have to use die() not off() and live() not on()
	$('#cb_'+ filter_name).die().live("click", function() {
	  var field = $(this).val();
	  toggleFilter(field);
	  if($(this).is(':checked')) {
		$(cat_tree_id).show();
		fix_operator_change_event();
	  } else {
		$(cat_tree_id).hide();
	  }
	});
	
	$(redmine_cat_op_id).off().change(fix_operator_change_event);
	
	function add_dropdowns_template() {
	  return $("#tr_"+ filter_name +" > td.values").append('<span id="'+ cat_tree_name +'"></span>');
	}
	
	function get_category_tree_dropdowns() {
	  if(!$("#"+ redmine_cat_list_name +" option:selected").length) {
		//Force a category to be selected, otherwise Redmine complains
		$("#"+ redmine_cat_list_name).val(1);
	  }
	  handle_dynamic_category_tree_now(redmine_cat_list_name, 'span', true);
	}
	
	function fix_operator_change_event() {
	  toggleOperator(filter_name);
	  get_category_tree_dropdowns();
	  var op = $(redmine_cat_op_id).val();
	  if(op === "=" || op === "!") {
		$(cat_tree_id).show();
	  } else {
		$(cat_tree_id).hide();
	  }
	}
}
