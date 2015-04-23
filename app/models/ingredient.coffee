###
	For 'Image' table.
	Actual images are stored on disk. Db has paths.
###

TNAME = 'Ingredient'
TREL = 
	image: 'Image'
	account: 'Account'
COL = 
	ingredientId: 'ingredientId'
	submissionAccountId: 'submissionAccountId'
	imageId: 'imageId'
	name: 'name'
	description: 'description'
	byMass: 'byMass'
	
	fileName: 'fileName'
	
	accountId: 'accountId'
	username: 'username'

PLACHOLDER_IMAGE = 'missingIngredient.png'

module.exports = (app) ->
	class app.models.Ingredient
		constructor: ()->		
		
		@createNew: (data) ->
			console.log app.util.inspect data
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s,%s) ' +
				' VALUES (%i,%i,"%s","%s",%i); SELECT LAST_INSERT_ID() AS %s;'
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
				
				COL.ingredientId
			]
			# console.log sql
			con = app.db.newMultiCon()
			qcnt = 0
			ingredientId = null
			con.query sql
			.on 'result', (res)->
				++qcnt
				res.on 'row', (row)->
					if qcnt == 2
						ingredientId = parseInt row.ingredientId
				res
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject '' + err
			.on 'end', (info)->
				console.log 'Completed ' + qcnt + ' queries on ' + TNAME
				def.resolve ingredientId
			con.end()
			
			return def.promise
			
		
		# Gets basic info of those that match search criteria
		@getSearchSimple: (pageTotal, pageNum, search)->
			def = app.Q.defer()
			sql = app.vsprintf '
				SELECT DISTINCT i.%s,i.%s,img.%s
					FROM %s AS i
					LEFT JOIN %s AS img ON i.%s=img.%s ' +
					(if search? then '
						WHERE
							MATCH(i.name,i.description) AGAINST ("'+search+'" WITH QUERY EXPANSION) ' else 'ORDER BY UPPER(i.name) ASC')
							
			, [
				COL.ingredientId
				COL.name
				COL.fileName
								
				TNAME, TREL.image
				
				COL.imageId, COL.imageId
			]
			# console.log sql
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						ingredientId: parseInt row.ingredientId
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
		
		@getSingle: (ingredientId)->
			def = app.Q.defer()
			sql = app.vsprintf '
				SELECT i.%s,i.%s,i.%s,i.%s,i.%s, img.%s,a.%s
					FROM %s AS i
					LEFT JOIN %s AS img ON i.%s=img.%s
					INNER JOIN %s AS a ON i.%s=a.%s
					WHERE i.%s = %i
				'
			, [
				COL.ingredientId
				COL.name
				COL.description
				COL.byMass
				COL.submissionAccountId
				
				COL.fileName
				
				COL.username
								
				TNAME, 
				
				TREL.image, COL.imageId, COL.imageId
				TREL.account, COL.submissionAccountId, COL.accountId
				
				COL.ingredientId, ingredientId
			]
			# console.log sql
			result = {}
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result =
						ingredientId: parseInt row.ingredientId
						name: row.name
						fileName: if row.fileName? then row.fileName else PLACHOLDER_IMAGE
						description: row.description
						byMass: row.byMass == '1'
						username: row.username
						submissionAccountId: row.submissionAccountId
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					def.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject '' + err
			con.end()
			
			return def.promise
			
			
		
		@getByNameSearch: (search)->
			def = app.Q.defer()
			sql = app.vsprintf '
				SELECT %s,%s,%s
					FROM %s
					WHERE LOWER(%s) LIKE "%%%s%%"
				'
			, [
				COL.ingredientId
				COL.name
				COL.imageId
				TNAME
				COL.name
				search.toLowerCase()
			]
			# console.log sql
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push
						data: parseInt row.ingredientId
						value: row.name
						imageId: parseInt row.imageId
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					def.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject '' + err
			con.end()
			
			return def.promise
		
