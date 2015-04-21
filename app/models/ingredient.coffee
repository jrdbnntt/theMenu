###
	For 'Image' table.
	Actual images are stored on disk. Db has paths.
###

TNAME = 'Ingredient'
COL = 
	ingredientId: 'ingredientId'
	submissionAccountId: 'submissionAccountId'
	imageId: 'imageId'
	name: 'name'
	description: 'description'
	byMass: 'byMass'

module.exports = (app) ->
	class app.models.Ingredient
		constructor: ()->		
		
		@createNew: (data) ->
			console.log app.util.inspect data
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s,%s) ' +
				' VALUES (%i,%i,"%s","%s",%i)'
			, [
				TNAME
				COL.submissionAccountId
				COL.imageId
				COL.name
				COL.description
				COL.byMass
				
				data.submissionAccountId
				data.imageId
				data.name
				data.description
				if data.byMass == 'true' then 1 else 0
			]
			console.log sql
			con = app.db.newCon()
			qcnt = 0
			imageId = null
			con.query sql
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject '' + err
			.on 'end', (info)->
				def.resolve()
			con.end()
			
			return def.promise