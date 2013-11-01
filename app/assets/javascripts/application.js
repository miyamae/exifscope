//= require jquery
//= require jquery_ujs
/// require turbolinks
//= require jquery-ui-1.10.3.custom
//= require bootstrap
//= require jquery.grid-a-licious

function getUrlVars() {
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++) {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = decodeURIComponent(hash[1]);
    }
    return vars;
}

function hasUrl() {
  return $('#url').val().length > 0;
}

function initUrlInput() {
    $('#url').popover({
      trigger: 'manual',
      placement: 'bottom'
    });
    $('#url').focus(function() {
        if (!hasUrl()) $('#url').popover('show');
    });
    $('#url').blur(function() {
        $('#url').popover('hide');
    });
    $('#url').keypress(function() {
        $('#url').popover('hide');
    });
    if (!hasUrl()) $('#url').popover('show');
}

function loadContent() {
    var params = getUrlVars();
    var url = params['url'];
    if (url) {
        $('#loading').show();
        $("#content").empty();
        $.ajax({
            url: '/content?url=' + encodeURIComponent(url),
            success: function(html) {
                $('#loading').hide();
                $("#content").append(html);
                $('#container').gridalicious({
                    animate: true
                });
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                $('#loading').hide();
                $("#content").append('正常に取得できませんでした : ' + textStatus);
            }
        });
    }
}

$(function() {
    $('#url').click(function() {
        $(this).select();
    });
    initUrlInput();
    loadContent();
});
