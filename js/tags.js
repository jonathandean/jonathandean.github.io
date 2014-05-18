function expandTag( name ) {
  $('li[data-tag-slug="' + name + '"]').addClass('expanded');
}

$(function(){
  $('a.tag-link').click(function(e){
    e.preventDefault();
    expandTag($(e.target).parent().attr('data-tag-slug'));
  });

  if(window.location.hash) {
    var name = window.location.hash.replace('#', '');
    expandTag(name);
  }
});