function onLoadDoAamCleanup() {
	$(document).ready(function() {
		 //console.log("Hiding unwanted UI");
		 $("#issue_tracker_id").parent('p').hide(); //always 'support'
		 $("#issue_due_date").parent('p').hide(); //auto-set by SLA-linked priority
		 $("#issue_is_private").parent('p').hide(); //Don't want to give this option
	});
}
