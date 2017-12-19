//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require social-share-button
//= require showdown
//= require materialize
//= require_tree .

// Not Used With SimpleMDE
// function preview() {
//   var text = document.getElementById('content').value,
//     target = document.getElementById('preview_div'),
//     convert = new showdown.Converter(),
//     html = convert.makeHtml(text);

//   target.style.display = 'block';
//   target.innerHTML = html;
//   return false
// }

$(document).on("turbolinks:load", function() {
  $('.menu').click(function(e) {
    e.stopPropagation();
    $('#main_nav').toggleClass('active');
  });

  var simplemde = new SimpleMDE({ element: document.getElementById("content") });
});
