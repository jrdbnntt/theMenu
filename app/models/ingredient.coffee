###
	For 'Image' table.
	Actual images are stored on disk. Db has paths.
###

TNAME = 'Ingredient'
TREL = 
	image: 'Image'
COL = 
	ingredientId: 'ingredientId'
	submissionAccountId: 'submissionAccountId'
	imageId: 'imageId'
	name: 'name'
	description: 'description'
	byMass: 'byMass'
	
	fileName: 'fileName'

PLACHOLDER_IMAGE = 'missingIngredient.png'

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
		
		# Simply returns all of them
		@getAll: ()->
			
		
		# Gets basic info of those that match search criteria
		@getSearchSimple: (pageTotal, pageNum, search)->
			def = app.Q.defer()
			sql = app.vsprintf '
				SELECT DISTINCT i.%s,i.%s,img.%s
					FROM %s AS i
					LEFT JOIN %s AS img ON i.%s=img.%s ' +
					(if search? then '
						WHERE
							MATCH(i.name,i.description) AGAINST ("'+search+'" WITH QUERY EXPANSION) ' else '')
							
			, [
				COL.ingredientId
				COL.name
				COL.fileName
								
				TNAME, TREL.image
				
				COL.imageId, COL.imageId
			]
			console.log sql
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						ingredientId: row.ingredientId
						name: row.name
						fileName: if row.fileName? then row.fileName else PLACHOLDER_IMAGE
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					def.resolve 
						totalCount: result.length
						rows: result.slice (pageTotal*(pageNum-1)), (pageTotal*pageNum)
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject '' + err
			con.end()
			
			return def.promise
			
			