###
	For 'Instruction' table.
###

TNAME = 'Instruction'
TREL = 
	image: 'Image'
COL = 
	instructinId: 'instructinId'
	recipeId: 'recipeId'
	step: 'step'
	imageId: 'imageId'
	description: 'description'
	
	fileName: 'fileName'
	
	accountId: 'accountId'
	username: 'username'

PLACHOLDER_IMAGE = 'missingIngredient.png'

module.exports = (app) ->
	class app.models.Instruction
		constructor: ()->		
		
		@createNew: (data) ->
			# console.log app.util.inspect data
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s) ' +
				' VALUES (%i,%i,"%s")'
			, [
				TNAME
				COL.recipeId
				COL.step
				COL.description
				# TODO - image
				
				data.recipeId
				data.step
				data.description
				
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
			