$(document).ready(function() {
  categoryChanged();
  $('#device_category').change(categoryChanged);
});

function categoryChanged() {
	cat = $('#device_category').val();
	parent_item_id = $('#device_deviceable_id').val();
	if(cat == 'lms' || cat == 'pos' || cat == 'watchfolder' || cat == 'ftp_folder') {
		$.ajax("/cinemas/get_cinemas", {
			success: function(data) {
				var options = '';
				for (var i = 0; i < data.length; i++) {
					options += '<option value="' + data[i].cinema.id + '">' + data[i].cinema.name + '</option>';
				}
				$('#device_deviceable_id').html(options);
				$('#device_deviceable_id').val(parent_item_id);
				$('#device_deviceable_type').val('Cinema');
			}
		});
	} else {
		$.ajax("/screens/get_screens", {
			success: function(data) {
				var options = '';
				for (var i = 0; i < data.length; i++) {
					options += '<option value="' + data[i].screen.id + '">' + data[i].screen.identifier + '</option>';
				}
				$('#device_deviceable_id').html(options);
				$('#device_deviceable_id').val(parent_item_id);
				$('#device_deviceable_type').val('Screen');
			}
		});
	}
}