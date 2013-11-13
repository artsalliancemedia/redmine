function handle_dynamic_resolution_tree_now(element_name, parent_element_block_type, no_blank_at_root) {
    var resolution_tree = $("#resolution-tree-dropdowns");

    function load_resolution_tree(resolution) {
        var params = {};
        if(no_blank_at_root) params['no_blank'] = 'y';

        resolution_tree.load("/resolution_trees/drop_downs/" + (resolution || 0) + "?" + $.param(params));
    }

    var resolution = $("#" + element_name);
    load_resolution_tree(resolution.val());

    resolution_tree.on("change", "select", function() {
        var new_val = $(this).val();
        if (new_val.length === 0) {
            //blank selected, get parent value
            new_val = $(this).prev('select').val();
        }
        resolution.val(new_val);

        load_resolution_tree(new_val);
    });
}

function handle_dynamic_resolution_tree(element) {
    $(document).ready(function() {
        handle_dynamic_resolution_tree_now(element);
    });
}
