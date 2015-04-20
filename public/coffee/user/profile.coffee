###
	For /user/profile
	
	Features
		- add eater form
		- toggle eater form
		- modify eater
			- delete
			- make owner (star)
		- load eaters
		

###

CLASS_GLYPH = 
	glyphicon: 'glyphicon'
	plus: 'glyphicon-plus'
	minus: 'glyphicon-minus'
	star: 'glyphicon-star'
	starEmpty: 'glyphicon-star-empty'
	remove: 'glyphicon-remove'

setLoading = (loading)->
	$('#loading').toggle loading
setLoading false


##############################################################################
# Eater list

refreshEaters = ()->
	console.log 'Refreshing eaters...'



##############################################################################
# Eater form

ID_FORM = '#addEaterForm'
ID_FORM_CONT = '#addEaterFormContainer'
CLASS_ADD_NEW = '.addNew'

setEaterFormEnabled = (enabled)->
	console.log ID_FORM_CONT + ' enabled=' + enabled
	$addNew = $('.addNew')
	
	if enabled
		$('.addNew').attr 'data-glyph', 'minus'
		.children '.' + CLASS_GLYPH.glyphicon
		.removeClass CLASS_GLYPH.plus
		.addClass CLASS_GLYPH.minus
		
		$(ID_FORM_CONT + ' input').removeAttr 'disabled'
		.val ''
		
		$(ID_FORM_CONT + ' select').removeAttr 'disabled'
		.val 0
		
		$(ID_FORM_CONT + ' button').removeAttr 'disabled'
		.text 'Save'
		
	else
		$('.addNew').attr 'data-glyph', 'plus'
		.children '.' + CLASS_GLYPH.glyphicon
		.removeClass CLASS_GLYPH.minus
		.addClass CLASS_GLYPH.plus
		
		$(ID_FORM_CONT + ' input').attr 'disabled', 'disabled'
		$(ID_FORM_CONT + ' select').attr 'disabled', 'disabled'
		$(ID_FORM_CONT + ' button').attr 'disabled', 'disabled'
		
	$(ID_FORM_CONT).toggle enabled

setEaterFormEnabled false

# Toggle button
$(CLASS_ADD_NEW).click ()->
	setEaterFormEnabled $(this).attr('data-glyph') == 'plus'

$(ID_FORM).submit (e) ->
	e.preventDefault()
	
	setLoading true
	$('#submit').attr 'disabled', 'disabled'
	
	formData =
		description:	$("input[name='description']").val().trim()
		chefLevel:		$("select[name='chefLevel']").val()
	
	if formData.description? && 
	0 <= formData.chefLevel &&
	formData.chefLevel <= 10
		$('#submit').text 'Saving...'
		
		console.log 'DATA= ' + JSON.stringify formData, undefined, 2
		# submit via ajax
		$.ajax
			type: 'POST'
			url: '/user/profile/addEater'
			data: JSON.stringify formData
			contentType: 'application/json'
			success: (res) ->
				if res.success
					$('#submit').text 'Saved!'
					setLoading false
					setEaterFormEnabled false
					refreshEaters()
				else
					console.log 'Error: ' + res.body.error
					$('#submit').text 'eError!'
					setEaterFormEnabled true
					setLoading false
					return
			error: () ->
				$('#submit').text 'sError!'
				setEaterFormEnabled true
				setLoading false
				return
	else
		$('#submit').text 'iError!'
		setEaterFormEnabled true
		setLoading false
