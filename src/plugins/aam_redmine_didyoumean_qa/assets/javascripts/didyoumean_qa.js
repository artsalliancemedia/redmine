//need to wrap-up the document.ready call because redmine reloads the form at various points
function onLoad() {
  $(document).ready(function() {
    $('#issue_subject').parent().after($('#similar_articles_root'), $('#similar_issues_root'));

    function handle_update() {
      var params = {
        issue_id: dym_data.issue_id,
        subject: $("#issue_subject").val(),
        category_id: $("#issue_category_id").val()
      };

      $.get(dym_data.search_url, params, update_blocks);
    }

    $("#category-tree-dropdowns").on('reloaded', handle_update);

    handle_update();
  });
}

function update_blocks(data) {
  update_block(data.articles, "articles", display_item);
  update_block(data.issues, "issues", display_item);
}

function update_block(data, selector, cb) {
  var items = data.list,
    num_returned = items.length,
    total_found = data.count;

  if (num_returned === 0) {
    $('#similar_' + selector).hide();
  } else {
    var items_html = '';
    for (var i = 0; i < num_returned; i++) {
      items_html += cb(selector, items[i]);
    }

    $('#similar_'+ selector +'_list').html(items_html);
    $('#'+ selector +'_count').html(total_found);
    $('#similar_'+ selector).show();
  }
}

function display_item(selector, item) {
  var url;
  switch (selector) {
    case "articles":
        url = sanitize('/boards/' + item.category_id + '/topics/' + item.id);
      break;
    case "issues":
        url = sanitize(dym_data.issue_url + '/' + item.id);
      break;
    default:
      console.log('Unknown selector type! Please contact dev for a fix.');
  }

  var categorisation = item.category;
  if (item.status) categorisation += ', ' + item.status;

  return '<li>'
    + '<a href="' + url + '" target="_new">' + sanitize('#' + item.id) + ' &ndash; ' + sanitize(item.subject) + '</a> (' + sanitize(categorisation) + ')'
    + '</li>';
}

function sanitize(value) {
  return value.replace(/[<]+/g, '&lt;')
    .replace(/[>]+/g, '&gt;')
    .replace(/["]+/g, '&quot;')
    .replace(/[']+/g, '&#039;');
}
