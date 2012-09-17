"form.deleteaddress".onSubmit (event) ->
  @parent().fade()
  event.stop()
  @send()

"form.addaddress".onSubmit (event) ->
  event.stop()
  @send onSuccess: (xhr) ->
    $("addresses").insert xhr.responseText


"a.remove".onClick (event) ->
  event.stop()
  @parent().load @get("pathname")