// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
// require turbolinks
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jstree
//= notify
//= require_tree .
//= require moment
//= require bootstrap-datetimepicker
//= require jquery_nested_form
//= require jquery.select2
//= require selectize

var image_via_mimetype = function(mimetype){

    if (mimetype.indexOf('pdf') > -1)
        return 'pdf.png';
    else if (mimetype.indexOf('doc') > -1)
        return 'doc.png';
    else if (mimetype.indexOf('docx') > -1)
        return 'docx.png';
    else if (mimetype.indexOf('wpd') > -1)
        return 'wpd.png';
    else if (mimetype.indexOf('xls') > -1)
        return 'xls.png';
    else if (mimetype.indexOf('ppt') > -1)
        return 'ppt.png';
    else if (mimetype.indexOf('image') > -1)
        return 'image-file.png';
    else
        return 'other.png';
};

var typewatch = (function () {
    var timer = 0;
    return function (callback, ms) {
        clearTimeout(timer);
        timer = setTimeout(callback, ms);
    }
})();

window.activate_image_lightbox = function(){
    $(document).find('a.image-light-box').magnificPopup({type:'image'});
};
window.activate_image_lightbox();


window.default_button_ui = function(){
    $('.tw-show').addClass('btn btn-default btn-xs btn-primary buttons-margin');
    $('.tw-edit').addClass('btn btn-default btn-xs btn-warning buttons-margin');
    $('.tw-delete').addClass('btn btn-default btn-xs btn-danger buttons-margin');
};
window.default_button_ui();

var enable_datetimepicker;
enable_datetimepicker = function() {
    $(document).find('.tw-datepicker').datetimepicker({
        showClose: true,
        showTodayButton: true,
        format: 'YYYY-MM-DD'
    });
};

$(function(){
  enable_datetimepicker();
  $('[data-toggle="tooltip"]').tooltip();
});

var manage_jsGrid_UI = function(){

    $(document).find('table#data_table').DataTable({
        "paging": false,
        "searching": false,
        "ordering":  false,
        "lengthChange": false,
        "paginate": false,
        "info": false

    });

    $(document).find('#data_table_length').hide();
    $(document).find('table#data_table2').DataTable({
        "paging": false,
        "searching": false,
        "ordering":  false,
        "lengthChange": false,
        "paginate": false,
        "info": false

    });
    $(document).find('#data_table2_info').hide();
};

var sort_select_options = function(self, is_person){
    var options  = "";
    var selected = $('option:selected', self).text();
    if(is_person){
        for(i = 0; i < usstates_person.length; i++){
            if(usstates_person[i] == selected) {
                options += "<option value='" + usstates_person[i] + "' selected='selected'>" + usstates_person[i] + "</option>";
            }else {
                options += "<option value='" + usstates_person[i] + "'>" + usstates_person[i] + "</option>";
            }
        }
    }else{
        for(i = 0; i < usstates_nonperson.length; i++){
            if(usstates_person[i] == selected) {
                options += "<option value='" + usstates_nonperson[i] + "' selected='selected'>" + usstates_nonperson[i] + "</option>";
            }else {
                options += "<option value='"+usstates_nonperson[i]+"'>"+usstates_nonperson[i]+"</option>";
            }
        }
    }
    $(self).html(options)
};

var usstates_person    = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"];
var usstates_nonperson = ["Delaware", "Nevada", "New York", "California", "Florida", "Alabama", "Alaska", "Arizona", "Arkansas", "Colorado", "Connecticut", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "New Hampshire", "New Jersey", "New Mexico", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"];

var titleReset = function(val){
    $(document).find("title").text(val)
};

var enable_datetimepicker_corporation = function() {
    // setTimeout(function(){
    //         $(document).find("input[id$=_date_of_formation], input.datepicker").datepicker({
    //             format: 'yyyy-mm-dd'
    //         })
    //     }, 500)
};

var sweet_alert_warning = function(text){
    swal({
        title: text,
        type: 'warning',
        showCancelButton: false,
    });
};

var sweet_alert_success = function(text){
    swal({
        title: text,
        type: 'success',
        showCancelButton: false,
    });
};

var sweet_alert_info = function(text){
    swal({
        title: text,
        type: 'info',
        showCancelButton: false,
    });
};

var sweet_alert_text_warning = function(text){
    swal({
        title: '',
        text: text,
        type: 'warning',
        showCancelButton: false,
        html: true,
    });
};

var sweet_alert_text_success = function(text){
    swal({
        title: '',
        text: text,
        type: 'success',
        showCancelButton: false,
        html: true,
    });
};

var sweet_alert_text_info = function(text){
    swal({
        title: '',
        text: text,
        type: 'info',
        showCancelButton: false,
        html: true,
    });
};


function getJsonFromUrl() {
    var query = location.search.substr(1);
    var result = {};
    query.split("&").forEach(function(part) {
        var item = part.split("=");
        result[item[0]] = decodeURIComponent(item[1]);
    });
    return result;
}




$( document ).ready(function() {
  $('#new-contacts-type').click(function () {
    return typewatch(function() {
      console.log("dgdfhs");
      return $(document).find("div#ContactsTypeList").show();
      }, 10);
  });

  $(document).on('click', function(e) {
    var container;
    container = $("div#ContactsTypeList");
    if (!container.is(e.target) && (container.has(e.target).length === 0)) {
      return container.hide();
    }
  });
});

$( document ).ready(function() {
  $('#new-property-type').click(function () {
    return typewatch(function() {
      console.log("dgdfhs");
      return $(document).find("div#PropertyTypeList").show();
      }, 10);
  });

  $(document).on('click', function(e) {
    var container;
    container = $("div#PropertyTypeList");
    if (!container.is(e.target) && (container.has(e.target).length === 0)) {
      return container.hide();
    }
  });
});

