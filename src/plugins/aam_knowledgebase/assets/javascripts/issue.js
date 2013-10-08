$(document).ready(function() {
	
	function set_kb_add_link() {
		var add = $("#make-kb-add-submit");
		add.attr('href', add.attr('data-url') + "/move_to_forum/" + $("#board_id").val());
	}
	
	//reveal form to make kb article from issue
	$("#make-kb").click(function() {
		$("#make-kb-add").show();
		set_kb_add_link();
	});
	
	$("#board_id").change(set_kb_add_link);
});