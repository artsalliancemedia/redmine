$(document).ready(function() {
	$("#article-add-issue").click(function() {
		var issueName = $("#message-related-issues-search").val();
		var issueId = $("#message-related-issues-search-value").val();
		var issue =
			"<span>" + 
				"<a href='/issues/"+ issueId +"/'>" +issueName + "</a>" +
				"<a class='article-remove-issue' no-follow>Remove</a><br />" +
				"<input type='hidden' name='message[issue_ids][]' value='"+ issueId +"'" +
			"</span>";
		$("#related-issues").append(issue);
	});
	$("#related-issues").on('click', '.article-remove-issue', function() {
		$(this).parent('span').remove();
	});
});