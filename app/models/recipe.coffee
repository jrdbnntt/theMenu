###
	For Recipe
###

TNAME = 'Recipe'
TREL = 
	image: 'Image'
	account: 'Account'
	ingredient: 'ingredient'
	instruction: 'instruction'
	recipe_ingredient_requirement: 'Recipe_Ingredient_requirement'
COL = 
	ingredientId: 'ingredientId'
	submissionAccountId: 'submissionAccountId'
	exampleImageId: 'exampleImageId'
	title: 'title'
	description: 'description'
	rating: 'rating'
	prepTime: 'prepTime'
	difficulty: 'difficulty'
	eaterAmount: 'eaterAmount'
	recipeId: 'recipeId'
	
	fileName: 'fileName'
	imageId: 'imageId'
	
	accountId: 'accountId'
	
	amount: 'amount'

	
PLACHOLDER_IMAGE = 'missingExampleRecipe.png'

module.exports = (app) ->
	class app.models.Recipe
		constructor: ()->		
		
		@createNew: (data) ->
			console.log app.util.inspect data
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s,%s,%s,%s,%s) ' +
				' VALUES (%i,%i,"%s","%s",%i,%i,%i,%i); SELECT LAST_INSERT_ID() AS %s;'
			, [
				TNAME
				
				COL.submissionAccountId
				COL.exampleImageId
				COL.title
				COL.description
				COL.rating
				COL.prepTime
				COL.difficulty
				COL.eaterAmount
				
				data.submissionAccountId
				data.exampleImageId
				data.title
				data.description
				0
				data.prepTime
				data.difficulty
				data.eaterAmount
				
				COL.recipeId
			]
			console.log sql
			con = app.db.newMultiCon()
			qcnt = 0
			recipeId = null
			con.query sql
			.on 'result', (res)->
				++qcnt
				res.on 'row', (row)->
					if qcnt == 2
						recipeId = parseInt row.recipeId
				res
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject '' + err
			.on 'end', (info)->
				console.log 'Completed ' + qcnt + ' queries on ' + TNAME
				def.resolve recipeId
			con.end()
			
			return def.promise
		
		@createRequirement: (recipeId, ingredientId, amount)->
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s) ' +
				' VALUES (%i,%i,%i)'
			, [
				TREL.recipe_ingredient_requirement
				COL.recipeId
				COL.ingredientId
				COL.amount
				
				recipeId
				ingredientId
				amount
			]
			console.log sql
			con = app.db.newCon()
			con.query sql
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject '' + err
			.on 'end', (info)->
				def.resolve()
			con.end()
			
			return def.promise
					