function onLoadDoAamCleanup(debugging) {
	//var production = !debugging;
	$(document).ready(function() {
		 $("#issue_tracker_id").parent('p').hide(); //always 'support'
		 $("#issue_due_date").parent('p').hide(); //auto-set by SLA-linked priority
		 $("#issue_is_private").parent('p').hide(); //Don't want to give this option
		 if(!debugging) {
			$("#issue_start_date").parent('p').hide(); //auto-set to current datetime
		 }
	});
}
