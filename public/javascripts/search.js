$(document).ready(function() {
    $("#search-form").submit(function( event ) {
      var fieldforceid = $("#fieldforceid").val();
      if (fieldforceid.length > 0) {
        window.location = "/fieldforce/" + fieldforceid;
      }
      event.preventDefault();
    });

});

// var elems = document.getElementsByClassName("confirm-resend-v-email");
// var confirmIt = function (e) {
//     if (!confirm("This will send another verification email to this respondent")) e.preventDefault();
// };
// for (var i = 0, l = elems.length; i < l; i++) {
//     elems[i].addEventListener("click", confirmIt, false);
// }
