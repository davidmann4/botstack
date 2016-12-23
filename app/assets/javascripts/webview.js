
function send_answer(text) {
  $.post( "/submit", { 
      "user_id": get_query_variable("user_id"),
      "token": get_query_variable("token"),
      "text": text } ).done(function( data ) {
    console.log( "data loaded: " + data );
    MessengerExtensions.requestCloseBrowser(function success() {}, function error(err) {window.close();});
  });
}

function get_query_variable(variable) {
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    if (pair[0] == variable) {
      return pair[1];
    }
  }
  console.log('query variable ' + variable + ' not found');
}