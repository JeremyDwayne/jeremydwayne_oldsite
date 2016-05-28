//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require social-share-button
//= require_tree .


$(document).on("turbolinks:load", function() {
  $('.menu').click(function(e) {
    e.stopPropagation();
    $('#main_nav').toggleClass('active');
  });
});
