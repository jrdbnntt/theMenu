###
	Handles user login form submission
###



FORM_ID = '#loginForm'
FORM_RESULT_CLASS = '.formResult'
FORM_ERROR_CLASS = '.formError'
FORM_LABEL_ERROR_CLASS = 'hasInputError'
POST_URL = '/login'
DEBUG_MODE = false
RESULT_MESSAGES=
	successTitle: 'You have logged in successfully!'
	successSubtitle: 'Redirecting...'
	errorTitle: '<b>An unexpected error has occured:</b> '
	errorSubtitle: 'Refresh this page and try resubmitting.'

$(FORM_ID).submit (e) ->
	e.preventDefault()

	formData =
		email:			$("input[name='email']").val().trim()
		password:		$("input[name='password']").val()
	
	if validateForm formData
		$('#submit').text 'Submitting...'
		
		console.log 'DATA= ' + JSON.stringify formData, undefined, 2
		# submit via ajax
		$.ajax
			type: 'POST'
			url: POST_URL
			data: JSON.stringify formData
			contentType: 'application/json'
			success: (res) ->
				if res.success
					endInSuccess()
					window.location.replace '/user/profile'
				else
					endInError res.body.error
					return
			error: () ->
				endInError()
				return
	return

# Sets an error message display on the form
setFormError = (name, message)->
	$('label[for=' + name + ']').addClass FORM_LABEL_ERROR_CLASS
	$(FORM_ERROR_CLASS).text message
	$('[name='+ name + ']').change () ->
		$('label[for=' +$(this).attr('name')+']').removeClass FORM_LABEL_ERROR_CLASS
		$(FORM_ERROR_CLASS).text ""

#checks values for correct input, returns true or an error string
validateForm = (fd) ->
	regE = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
	
	#clear any prev errors
	$('.' + FORM_LABEL_ERROR_CLASS).removeClass FORM_LABEL_ERROR_CLASS
	
	#required
	if !fd.email?
		setFormError 'email', 'Missing Email!'
		return false
	else if !regE.test fd.email
		setFormError 'email', 'Invalid email format!'
		return false
	else if !fd.password?
		setFormError 'password', 'Missing Password!'
		return false

	#nothing wrong
	return true


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
			$(FORM_ID).empty()
			#create message
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
