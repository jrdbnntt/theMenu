module.exports = (app) ->
	class app.APIController
		@searchIngredientNames = (req, res) ->
			if req.body.query?
				app.models.Ingredient.getByNameSearch req.body.query
				.then (suggestions)->
					res.send 
						suggestions: suggestions
				, (err)->
					console.log 'Bad Search - input'
					res.send 
						suggestions: []
			else
				console.log 'Bad Search - input'
				res.send 
					suggestions: []
		
		@getImagePathById = (req, res)->
			imageId = req.body.imageId
			if imageId?
				app.models.Image.getPathByImageId imageId
				.then (result)->
					res.send
						success: true
						body:
							path: result.path
				, (err)->
					res.send
						success: false
						body:
							error: err
			else
				res.send
					success: false
					body:
						error: 'Invalid parameters'
						
		@getIngSimpleByRecipeId = (req, res)->
			recipeId = req.body.recipeId
			if recipeId?
				app.models.Recipe.getIngSimpleByRecipeId recipeId
				.then (ingredients)->
					res.send
						success: true
						body:
							ingredients: ingredients
				, (err)->
					res.send
						success: false
						body:
							error: err
			else
				res.send
					success: false
					body:
						error: 'Invalid parameters'
		
		@getInstructionsByRecipeId = (req, res)->
			recipeId = req.body.recipeId
			if recipeId?
				app.models.Instruction.getAllByRecipeId(recipeId)
				.then (instructions)->
					res.send
						success: true
						body:
							instructions: instructions
				, (err)->
					res.send
						success: false
						body:
							error: err
			else
				res.send
					success: false
					body:
						error: 'Invalid parameters'