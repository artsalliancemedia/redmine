function handle_dynamic_category_tree_now(category_element_name, parent_element_block_type, no_blank_at_root, reject_id) {
	var category_tree = $("#category-tree-dropdowns");

	function load_category_tree(category) {
		var params = {};
		if(no_blank_at_root) {
			params['no_blank'] = 'y';
		}
		if(reject_id) {
			params['id_ignore'] = reject_id; 
		}
		var q_str = "?" + $.param(params);
		category_tree.load("/category_trees/drop_downs/" + (category || 0) + q_str);
	}

	var parent_category = $("#" + category_element_name);
	//Hide the old category drop-down
	//	but DO NOT remove/disable it as we use it to send the category to the issue ontroller
	parent_category.parent(parent_element_block_type || 'p').hide();

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
}

function handle_dynamic_category_tree_with_reject(cat_el_name, reject_id) {
	$(document).ready(function() {
		handle_dynamic_category_tree_now(cat_el_name, 'p', false, reject_id);
	});
}

function handle_dynamic_category_tree(category_element_name) {
	$(document).ready(function() {
		handle_dynamic_category_tree_now(category_element_name);
	});
}

function handle_category_tree_visual() {
	$(document).ready(function() {
		$('tr.idnt').hide();

		function flip_status(elements, is_open) {
			var symbol = is_open ? '+' : '-';
			elements.filter("[data-isleaf='false']").find("td > span.tree-status").text(symbol);
		}

		$('tr.issue_category[data-isleaf="false"]').on("click", function() {
			var node = $(this);
			var direct_descendants = node.siblings('tr[data-parent="' + node.attr('data-id') + '"]');

			var status = "";
			if (direct_descendants.is(":visible")) {
				//Hide entire sub-tree and reset the open/closed status of any branches
				var sub_tree = node.nextUntil("tr[data-level='" + $(this).attr('data-level') + "']")
									.filter(function(i) {
									  //make sure to cast to int
									  return +$(this).attr("data-level") > +node.attr('data-level');
									});
				sub_tree.hide();
				flip_status(sub_tree, true);

				status = '+';
			} else {
				//Show direct descendants only
				direct_descendants.show();
				status = '-';
			}
			//Set the open/closed indicator for the sub-tree
			$(this).find("td > span.tree-status").text(status);
		});

		$("#all-show").click(function() {
			$("tr.idnt").show();
			flip_status($('tr.issue_category'), false);
		});
		$("#all-hide").click(function() {
			$("tr.idnt").hide();
			flip_status($('tr.issue_category'), true);
		});

	});
}