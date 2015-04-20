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

ID_EATERS = '#eaters'

refreshEaters = ()->
	console.log 'Refreshing eaters...'
	$eaters = $(ID_EATERS)
	$eaters.empty()
	setLoading true
	
	# Get them all
	$.ajax
		type: 'POST'
		url: '/user/profile/getAllEaters'
		data: JSON.stringify {}
		contentType: 'application/json'
		success: (res) ->
			setLoading false
			if res.success
				$('#submit').text 'Saved!'
				if res.body.eaters.length > 0
					for eater in res.body.eaters
						$eaters.append '
							<tr data-eaterid='+eater.eaterId+'>
								<td>'+eater.name+'</td>
								<td>'+eater.description+'</td>
								<td class="col-xs-1 text-center">'+eater.chefLevel+'</td>
								<td class="col-xs-2 text-right">
									<div class="btn owner"><span class="glyphicon glyphicon-star-empty"></span></div>
									<div class="btn delete"><span class="glyphicon glyphicon-remove"></span></div>
								</td>
							</tr>'
					refreshActionListeners()
				else
					$eaters.append '<tr><td colspan="4" class="text-center info"><i>You have no Eaters. Click the \'+\' below to add one!</i></td></tr>'
			else
				$eaters.append '<tr><td colspan="4" class="text-center danger">Error: ' +
					res.body.error + ' Try refreshing.</td></tr>'
				return
		error: () ->
			$eaters.append '<tr><td colspan="4" class="text-center danger">Error! Try refreshing.</td></tr>'
			setLoading false
			return
refreshEaters()


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
		name:				$("input[name='name']").val().trim()
		description:	$("input[name='description']").val().trim()
		chefLevel:		$("select[name='chefLevel']").val()
	
	if formData.name? &&
	formData.description? && 
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

##############################################################################
# Eater actions

preformEaterAction = (eaterId, action)->
	if eaterId? && action?
		console.log '[ACTION] eaterId=' + eaterId + ' action=' + action  
		$.ajax
			type: 'POST'
			url: '/user/profile/eaterAction'
			data: JSON.stringify 
				eaterId: eaterId
				action: action
			contentType: 'application/json'
			success: (res) ->
				if res.success
					setLoading false
					refreshEaters()
				else
					console.log 'Error: ' + res.body.error
					setLoading false
					return
			error: () ->
				console.log 'Client Error: Unable to send'
				setLoading false
				return
	else
		console.log 'Client Error: Invalid action parameters'

refreshActionListeners = ()->
	$('.delete').click ()->
		eaterId = $(this).closest('tr').attr 'data-eaterid'
		console.log 'EI=' + eaterId
		preformEaterAction eaterId, 'delete'

