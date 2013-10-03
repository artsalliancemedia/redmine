function onLoadDoAamCleanupOfIssueShow() {
	$(document).ready(function() {
		 var subtasks = $("#issue_tree");
		 subtasks.prev('hr').hide();
		 subtasks.hide();
	});
}
