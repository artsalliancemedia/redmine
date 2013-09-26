//need to wrap-up the document.ready call because redmine reloads the form at various points
function onLoad() {
	$(document).ready(function() {
		console.log("hello");
		moveDisplayBlock();

		var handleUpdate = function() {
			var url = dym_data.search_url;
			var parameters = {
				project_id: dym_data.project_id,
				issue_id: dym_data.issue_id
			};
			var device_id = $("#issue_device_id").val();
			var subject = $("#issue_subject").val();
			if(device_id) {
				parameters['device_id'] = device_id;
			}
			if(subject) {
				parameters['query'] = subject;
			}
			console.log(parameters);
			new $.ajax(url, {
				data: parameters,
				success: function(data, textStatus, jqXHR) {
					updateBlocks(data);
				}
			});
		};

		$('#issue_subject').bind(dym_data.event_type, handleUpdate);
		$("#issue_device_id").change(handleUpdate);
	});
}

function updateBlocks(data) {
	updateSimilarXBlock(data.articles, "articles", displayArticleItem);
	updateSimilarXBlock(data.issues, "issues", displayIssueItem);
}

function updateSimilarXBlock(data, x, x_maker) {
	var items = data.list;
	var count = items.length;
	var count_all = data.count;
	if (count === 0) {
		$('#similar_'+ x).hide();
	} else {
		var items_html = '';
		for (var i = 0; i < count; i++) {
			items_html += x_maker(items[i]);
		}

		if (count_all > count) {
			var more = count_all - count;
			var more_text = '<li>' + more + ' ' + dym_data.label_more + '</li>';
			items_html += more_text;
		}

		$('#similar_'+ x +'_list').html(items_html);
		$('#'+ x +'_count').html(count_all);
		$('#similar_'+ x).show();
	}
}

function displayArticleItem(item) {
	var message_url = sanitize('/boards/' + item.category_id + '/topics/' + item.id);
	var item_id = sanitize('#' + item.id);
	var item_subject = sanitize(item.subject);

	var item_html = '<li><a href="' + message_url + '">'
			+ item_id
			+ ' &ndash; '
			+ item_subject
			+ '</a> ('
			+ item.category
			+ ')</li>';

	return item_html;
}

function displayIssueItem(item) {
	var issue_url = sanitize(dym_data.issue_url + '/' + item.id);
	var item_id = sanitize('#' + item.id);
	var item_subject = sanitize(item.subject);
	var item_status = sanitize(item.status_name);

	var item_html = '<li><a href="' + issue_url + '">'
			+ ' ' + item_id
			+ ' &ndash; '
			+ item_subject
			+ '</a> ('
			+ item_status
			+ ')</li>';

	return item_html;
}

//Move the view hook to a more useful location
function moveDisplayBlock() {
	$('#issue_subject').parent().after($('#similar_articles_root'), $('#similar_issues_root'));
}

function sanitize(value) {
	var html_safe = value.replace(/[<]+/g, '&lt;')
			.replace(/[>]+/g, '&gt;')
			.replace(/["]+/g, '&quot;')
			.replace(/[']+/g, '&#039;');
	return html_safe;
}
