###
	Handles recipe submission
###

CLASS_GLYPH = 
	glyphicon: 'glyphicon'
	plus: 'glyphicon-plus'
	minus: 'glyphicon-minus'
	star: 'glyphicon-star'
	starEmpty: 'glyphicon-star-empty'
	remove: 'glyphicon-remove'

##############################################################################
# Adding ingredients
ingredientData = []
$ingredients = $('#ingredients')

ID_ADD_CONT_INGREDIENT = '#searchIngredients'
ID_MODIFY_INGREDIENT = '#modifyIngredient'

setAddIngredientEnabled = (enabled)->
	console.log ID_ADD_CONT_INGREDIENT + ' enabled=' + enabled
	
	if enabled
		$(ID_MODIFY_INGREDIENT).attr 'data-glyph', 'minus'
		.children '.' + CLASS_GLYPH.glyphicon
		.removeClass CLASS_GLYPH.plus
		.addClass CLASS_GLYPH.minus
		
		$(ID_ADD_CONT_INGREDIENT + ' input').removeAttr 'disabled'
		.val ''
		
		$(ID_ADD_CONT_INGREDIENT + ' select').removeAttr 'disabled'
		.val 0
		
		$(ID_ADD_CONT_INGREDIENT + ' button').removeAttr 'disabled'
		.text 'Save'
		
	else
		$(ID_MODIFY_INGREDIENT).attr 'data-glyph', 'plus'
		.children '.' + CLASS_GLYPH.glyphicon
		.removeClass CLASS_GLYPH.minus
		.addClass CLASS_GLYPH.plus
		
		$(ID_ADD_CONT_INGREDIENT + ' input').attr 'disabled', 'disabled'
		$(ID_ADD_CONT_INGREDIENT + ' select').attr 'disabled', 'disabled'
		$(ID_ADD_CONT_INGREDIENT + ' button').attr 'disabled', 'disabled'
		
	$(ID_ADD_CONT_INGREDIENT).toggle enabled

setAddIngredientEnabled false

# Toggle button
$(ID_MODIFY_INGREDIENT).click ()->
	setAddIngredientEnabled $(this).attr('data-glyph') == 'plus'


loadIngredient = (ingredientId,imageId)->
	$.ajax
		type: 'POST'
		url: '/api/getImagePathById'
		data: JSON.stringify 
			imageId: imageId
		contentType: 'application/json'
		success: (res) ->
			if res.success
				console.log 'Got path ' + res.body.path
				
				$('#ingredients tr[data-ingredientId='+ingredientId+']')
				.find '.thumb-img'
				.css 'background-image', 'url('+res.body.path+')'
			else
				console.log 'unable to load image for ' + ingredientId + ': ' + res.body.error
				return
		error: () ->
			console.log 'unable to load image for ' + ingredientId
			return

refreshIngredients = ()->
	$ingredients.empty()
	for ingredient in ingredientData
		$ingredients.append '
			<tr data-ingredientId='+(ingredient.ingredientId)+'>
				<td>
					<div class="thumb-img thumb-small"></div>
				</td>
				<td>'+ingredient.name+'</td>
				<td class="col-xs-1 text-right">
					<div class="btn delete"><span class="glyphicon glyphicon-remove"></span></div>
				</td>
			</tr>
		'
		loadIngredient ingredient.ingredientId, ingredient.imageId
		
			
	$('#ingredients .delete').click ()->
		ingredientId = $(this).parents('tr').attr 'data-ingredientId'
		console.log 'Deleteing ' + ingredientId
		for i in [0..ingredientData.length]
			if ingredientData[i].ingredientId == ingredientId
				ingredientData.splice i, 1
				break
		refreshIngredients()


# autocomplete for ingredient names
$('#searchIngredients').autocomplete
	serviceUrl: '/api/searchIngredientNames'
	ajaxSettings:
		type: 'POST'
	onSelect: (suggesstion)->
		isValid = true
		for ingredient in ingredientData
			if ingredient.ingredientId == suggesstion.data
				isValid = false
				break
		if isValid
			ingredientData.push 
				name: suggesstion.value
				ingredientId: suggesstion.data
				imageId: suggesstion.imageId
				amount: 1 #TODO - make this work
		
			console.log suggesstion
			refreshIngredients()
			setAddIngredientEnabled false
			$('#searchIngredients').val ''
			
		$('#searchIngredients').autocomplete().clear()
		




##############################################################################
# Adding instructions
instructions = []

instructionData = []
$instructions = $('#instructions')

ID_ADD_CONT_INSTRUCTION = '#addInstruction'
ID_MODIFY_INSTRUCTION = '#modifyInstruction'

setAddinstructionEnabled = (enabled)->
	console.log ID_ADD_CONT_INSTRUCTION + ' enabled=' + enabled
	
	if enabled
		$(ID_MODIFY_INSTRUCTION).attr 'data-glyph', 'minus'
		.children '.' + CLASS_GLYPH.glyphicon
		.removeClass CLASS_GLYPH.plus
		.addClass CLASS_GLYPH.minus
		
		$(ID_ADD_CONT_INSTRUCTION + ' input').removeAttr 'disabled'
		.val ''
		
		$(ID_ADD_CONT_INSTRUCTION + ' select').removeAttr 'disabled'
		.val 0
		
		$(ID_ADD_CONT_INSTRUCTION + ' button').removeAttr 'disabled'
		.text 'Save'
		
	else
		$(ID_MODIFY_INSTRUCTION).attr 'data-glyph', 'plus'
		.children '.' + CLASS_GLYPH.glyphicon
		.removeClass CLASS_GLYPH.minus
		.addClass CLASS_GLYPH.plus
		
		$(ID_ADD_CONT_INSTRUCTION + ' input').attr 'disabled', 'disabled'
		$(ID_ADD_CONT_INSTRUCTION + ' select').attr 'disabled', 'disabled'
		$(ID_ADD_CONT_INSTRUCTION + ' button').attr 'disabled', 'disabled'
		
	$(ID_ADD_CONT_INSTRUCTION).toggle enabled

setAddinstructionEnabled false

# Toggle button
$(ID_MODIFY_INSTRUCTION).click ()->
	setAddinstructionEnabled $(this).attr('data-glyph') == 'plus'

refreshinstructions = ()->
	$instructions.empty()
	i = 1
	for instruction in instructionData
		$instructions.append '
			<tr data-step='+i+'>
				<td>'+i+'</td>
				<td>'+instruction.description+'</td>
				<td class="col-xs-1 text-right">
					<div class="btn delete"><span class="glyphicon glyphicon-remove"></span></div>
				</td>
			</tr>
		'
		++i
		
			
	$('#instructions .delete').click ()->
		instructionId = $(this).parents('tr').attr 'data-step'
		console.log 'Deleteing ' + instructionId
		for i in [0..instructionData.length]
			if instructionData[i].instructionId == instructionId
				instructionData.splice i, 1
				break
		refreshinstructions()

$(ID_ADD_CONT_INSTRUCTION + ' .btn').click ()->
	instructionData.push
		description: $(ID_ADD_CONT_INSTRUCTION + ' textarea').val().trim()
	$(ID_ADD_CONT_INSTRUCTION + ' textarea').val ''
	refreshinstructions()
	

##############################################################################
# Final submission

FORM_ID = '#addRecipeForm'
FORM_RESULT_CLASS = '.formResult'
FORM_ERROR_CLASS = '.formError'
FORM_LABEL_ERROR_CLASS = 'hasInputError'
POST_URL = '/user/add/recipe'
DEBUG_MODE = false
RESULT_MESSAGES=
	successTitle: 'Recipe created!'
	successSubtitle: 'Go <a href="/recipes">here</a> to view it!'
	errorTitle: '<b>An unexpected error has occured:</b> '
	errorSubtitle: 'Refresh this page and try resubmitting.'
	
$(FORM_ID).submit (e) ->
	e.preventDefault()
	
	jForm = new FormData()
	jForm.append 'title', 				$("input[name='title']").val().trim()
	jForm.append 'description',		$("textarea[name='description']").val().trim()
	jForm.append 'image', 				$("input[name='image']").get(0).files[0]
	jForm.append 'difficulty',			$('select[name="difficulty"]').val()
	jForm.append 'prepTime',			$('input[name="prepTime"]').val().trim()
	jForm.append 'eaterAmount',		$('input[name="eaterAmount"]').val().trim()
	jForm.append 'ingredientData', 	JSON.stringify ingredientData
	jForm.append 'instructionData',	JSON.stringify instructionData
	
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
