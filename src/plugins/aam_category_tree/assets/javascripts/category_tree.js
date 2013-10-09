function handle_dynamic_category_tree(category_element_name) {
	$(document).ready(function() {
		var category_tree = $("#category-tree-dropdowns");

		function load_category_tree(category) {
			category_tree.load("/category_trees/drop_downs/" + (category || 0));
		}

		var parent_category = $("#" + category_element_name);
		//Hide the old category drop-down
		//	but DO NOT remove/disable it as we use it to send the category to the issue ontroller
		parent_category.parent('p').hide();

		load_category_tree(parent_category.val());

		category_tree.on("change", "select", function() {
			var new_val = $(this).val();
			if (new_val.length === 0) {
				//blank selected, get parent value
				new_val = $(this).prev('select').val();
			}
			parent_category.val(new_val);

			load_category_tree(new_val);
		});
	});
}