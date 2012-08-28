"form.deleteaddress".onSubmit(function(event) {
   this.parent().fade();
   event.stop();
   this.send();
 });
 
 "form.addaddress".onSubmit(function(event) {
 event.stop();
 this.send({
   onSuccess: function(xhr) {
   $('addresses').insert(xhr.responseText);
  }
 });
});

"a.remove".onClick(function(event) {
  event.stop();
  this.parent().load( this.get('pathname'));
});