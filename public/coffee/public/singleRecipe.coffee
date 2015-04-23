
##############################################################################
# Ingredients

ingredientData = []
$ingredients = $('#ingredients')

refreshIngredients = ()->
	$ingredients.empty()
	for ingredient in ingredientData
		$ingredients.append '
			<tr data-ingredientId='+(ingredient.ingredientId)+'>
				<td>
					<div class="thumb-img thumb-small style="background-image: url('+('/img/uploads/'+ingredient.fileName)+');"></div>
				</td>
				<td>'+ingredient.name+'</td>
			</tr>
		'

loadIngredients = ()->
	$.ajax
		type: 'POST'
		url: '/api/getIngSimpleByRecipeId'
		data: JSON.stringify 
			recipeId: recipeId
		contentType: 'application/json'
		success: (res) ->
			if res.success
				console.log 'Got path ' + res.body.path
				ingredientData = res.body.ingredients
				refreshIngredients()
			else
				console.log 'unable to load ing res'
				return
		error: () ->
			console.log 'unable to load ing sen'
			return

loadIngredients()

##############################################################################
# Instructions

instructionData = []
$instructions = $('#instructions')


refreshInstructions = ()->
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
loadInstructions = ()->
	$.ajax
		type: 'POST'
		url: '/api/getInstructionsByRecipeId'
		data: JSON.stringify 
			recipeId: recipeId
		contentType: 'application/json'
		success: (res) ->
			if res.success
				console.log 'Got path ' + res.body.path
				instructionData = res.body.instructions
				refreshInstructions()
			else
				console.log 'unable to load inst res'
				return
		error: (err) ->
			console.log 'unable to load inst send ' + err
			return

loadInstructions()



