###
	Handles user ingredient form submission
###
###
	Form ingredient submission
###


FORM_ID = '#addIngredientForm'
FORM_RESULT_CLASS = '.formResult'
FORM_ERROR_CLASS = '.formError'
FORM_LABEL_ERROR_CLASS = 'hasInputError'
POST_URL = '/user/add/ingredient'
DEBUG_MODE = false
RESULT_MESSAGES=
	successTitle: 'Ingredient created!'
	successSubtitle: 'Go <a href="/">here</a> to view it!'
	errorTitle: '<b>An unexpected error has occured:</b> '
	errorSubtitle: 'Refresh this page and try resubmitting.'
	
$(FORM_ID).submit (e) ->
	e.preventDefault()
	
	jForm = new FormData()
	jForm.append 'name', 			$("input[name='name']").val().trim()
	jForm.append 'byMass',			$("input[name='byMass']").val() == 'true'
	jForm.append 'description',	$("textarea[name='description']").val().trim()
	jForm.append 'image', 			$("input[name='image']").get(0).files[0]
	
	$('#submit').text 'Submitting...'
	
	console.log 'DATA= ' + JSON.stringify jForm, undefined, 2
	# submit via ajax
	$.ajax
		type: 'POST'
		url: POST_URL
		data: jForm
		mimType: 'multipart/form-data'
		contentType: false
		cache: false
		processData: false
		success: (res) ->
			if res.success
				endInSuccess()
				window.location.replace res.body.href
			else
				endInError res.body.error
				return
		error: () ->
			endInError()
			return

# Sets an error message display on the form
setFormError = (name, message)->
	$('label[for=' + name + ']').addClass FORM_LABEL_ERROR_CLASS
	$(FORM_ERROR_CLASS).text message
	$('[name='+ name + ']').change () ->
		$('label[for=' +$(this).attr('name')+']').removeClass FORM_LABEL_ERROR_CLASS
		$(FORM_ERROR_CLASS).text ""

# Form end display
endInError = (msg) ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Error!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd  RESULT_MESSAGES.errorTitle + msg, RESULT_MESSAGES.errorSubtitle
	return
endInSuccess = () ->
	sub = $('#submit')
	sub.fadeOut 500, ()->
		sub.text 'Success!'
		sub.attr 'disabled', 'true'
		sub.fadeIn(500, ()->)
		displayEnd RESULT_MESSAGES.successTitle, RESULT_MESSAGES.successSubtitle
	return
displayEnd = (header, subtext) ->
	if !DEBUG_MODE
		$(FORM_ID+' input').attr('disabled','disabled');
		$(FORM_ID+' checkbox').attr('disabled','disabled');
		$(FORM_ID+' select').attr('disabled','disabled');
		$(FORM_ID).fadeTo 1000, 0, ()->
			#create message
			$(FORM_ID).empty()
			$newMsg = $("<div id='endDisplay'><h3>"+header+ "</h3><h4>"+subtext+"</h4>")
			$newMsg.appendTo($(FORM_RESULT_CLASS)).fadeIn 1000, ()->
				$("html, body").animate({ scrollTop: 0 }, 500)
			return
	else
		$newMsg = $("<div id='endDisplay'><h3>"+header+ "</h3><h4>"+subtext+"</h4>")
		$newMsg.appendTo($(FORM_RESULT_CLASS)).fadeIn 1000, ()->
			$("html, body").animate({ scrollTop: 0 }, 500)
		$('#submit').removeAttr 'disabled'
		.text 'Retry'
	
	return
