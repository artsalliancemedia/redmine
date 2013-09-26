function addRelatedIssue(issueId, issueName) {
	//Check for duplicate before adding
	if(!$("#related-issue-"+ issueId).length) {
		var issue =
			"<span id='related-issue-"+ issueId +"'>" +
				"<a href='/issues/" + issueId + "/'>" + issueName + "</a>" +
				"<span class='article-remove-issue'>Remove</span><br />" +
				"<input type='hidden' name='message[issue_ids][]' value='" + issueId + "'" +
			"</span>";
		//Add related issue
		$("#related-issues").append(issue);
	}
	//clear search box
	$("#message-related-issues-search").val("");
}

$(document).ready(function() {
	
	function reset_select(select) {
		//reset by clearing all then adding back an empty option
		select.find('option').remove().end()
			.append($("<option />").val("").text(""));
	}
	function repopulate_select(select, items) {
		reset_select(select);
		//add the new options
		$.each(items, function(i, item) {
			select.append($("<option />").val(item).text(item));
		});
	}
	
	//Listener for 'remove related issue' form
	$("#related-issues").on('click', '.article-remove-issue', function() {
		$(this).parent('span').remove();
	});
	
	//Listener for selecting device manufacturer
	$("#message_manufacturer").change(function() {
		$.get($(this).attr('data-url') + $(this).val(),
			function(data) {
				repopulate_select($("#message_model"), data);
				reset_select($("#message_firmware_version"));
				reset_select($("#message_software_version"));
			},
			"json"
		);
	});
	//Listener for selecting device model
	$("#message_model").change(function() {
		$.get($(this).attr('data-url') + $(this).val(),
			function(data) {
				repopulate_select($("#message_firmware_version"), data.firmware);
				repopulate_select($("#message_software_version"), data.software);
			},
			"json"
		);
	});

});