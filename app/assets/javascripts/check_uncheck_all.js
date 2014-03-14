function checkAll(docIDs, add_delete) {
	var jdocIDs = docIDs;
    var toggle_all_bookmarks = document.getElementsByClassName('toggle_all_bookmarks');
    var toggle_list = document.getElementsByClassName('toggle_list checkbox');
    var toggle_length = toggle_list.length;
    var title = toggle_list[0].title;
    var ischecked = toggle_all_bookmarks[1].checked;
     alert("hi " + jdocIDs[0].id + " " + add_delete + " " + ischecked + " toggle_list length  = " + toggle_length + " title = " + title);
     var len = jdocIDs.length;
for (var i=0; i<len; ++i) {
	 if (ischecked === true) {
       document.getElementById('toggle_list_' + jdocIDs[i].id).checked = '';
      }
     else {
       document.getElementById('toggle_list_' + jdocIDs[i].id).checked = 'checked';
      }
    }
     return false;
}

     
