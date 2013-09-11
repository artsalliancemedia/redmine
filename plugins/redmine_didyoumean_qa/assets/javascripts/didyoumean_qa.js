function observeIssueSubjectField2(project_id, event_type) {
  
  if (window.jQuery) {
    $(document).ready(moveSimilarMessagesRoot)
  } else {
    document.observe("dom:loaded", moveSimilarMessagesRoot)
  }

  var handleUpdate = function(event) {
    var url = dym_qa.search_url;
    var parameters = {
      project_id: project_id,
      query: (window.jQuery ? $(this).val() : Event.element(event).value)
    };

    if (window.jQuery) {
      new $.ajax(url, {
        data: parameters,
        success: function(data, textStatus, jqXHR) {
          updateSimilarMessagesBlock(data);
        }});
    } else {
      new Ajax.Request(url, {
        parameters: parameters,
        onSuccess: function(transport) {
          updateSimilarMessagesBlock(transport.responseJSON);
        },
        evalJSON: true
      });
    }
  }
  
  if (window.jQuery) {
    getElem('issue_subject').bind(event_type, handleUpdate);
  } else {
    getElem('issue_subject').observe(event_type, handleUpdate);
  }
}

function updateSimilarMessagesBlock(data) {
  var items = data.messages;
  if(items.length == 0) {
    getElem('similar_messages').hide();
  } else {
    var items_html = '';
    for (var i = 0; i < items.length; i++) {
      items_html += displayMessageItem(items[i]);
    }

    if (data.total > data.messages.length) {
      var more = data.total - data.messages.length;
      var more_text = '<li>' + more + ' ' + dym_qa.label_more + '</li>'
      items_html += more_text
    }

    setHtml(getElem('similar_messages_list'), items_html);
    setHtml(getElem('messages_count'), data.total);
    getElem('similar_messages').show();
  }
}

function displayMessageItem(item) {
  var message_url = sanitize('/boards/' + item.board_id + '/topics/' + item.id);
  var item_id = sanitize('#' + item.id);
  var item_subject = sanitize(item.subject);
  var project_name = sanitize(item.project_name);

  var item_html = '<li><a href="' + message_url + '">' 
                  + item_id
                  + ' &ndash; ' 
                  + item_subject
                  + '</a> ('
                  + item.board_name
                  + ')</li>';

  return item_html;
}

function moveSimilarMessagesRoot() {
  var block_to_move = getElem('similar_messages_root');
  if (window.jQuery) {
    getElem('issue_subject').parent().after(block_to_move);
  } else {
    getElem('issue_subject').up().insert({after: block_to_move});
  }
}

function sanitize(value) {
  var html_safe = value.replace(/[<]+/g, '&lt;')
                       .replace(/[>]+/g, '&gt;')
                       .replace(/["]+/g, '&quot;')
                       .replace(/[']+/g, '&#039;');
  return html_safe;
}

function getElem(element_id) {
  var the_id = element_id;
  if (window.jQuery) {
    the_id = '#' + the_id;
  }
  return $(the_id);
}

function setHtml(elem, value) {
  if (elem.text) {
    elem.html(value);
  } else {
    elem.innerHTML = value;
  }
}
