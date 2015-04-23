###
	For 'Image' table.
	Actual images are stored on disk. Db has paths.
###

#table constants
COL = 
	imageId: 'imageId'
	uploaderAccountId: 'uploaderAccountId'
	fileName: 'fileName'
	
module.exports = (app) ->
	TNAME = 'Image'
	TREL = null
	
	class app.models.Image
		constructor: ()->
		
		@uploadDir: 'public/img/uploads/'
		
		@genFileName: (original)->
			original = original.replace(/\s/g,'_').replace(/[\W[^.]]/ig,'-')
			if original.length > 15
				original = original.substr original.length - 15
			
			rand = '' + Math.random().toString(32).substr(2) + 
				Math.random().toString(32).substr(2) + 
				Math.random().toString(32).substr(2) + 
				original.split("").reverse().join("").substr(0,20).split("").reverse().join("")
				
			if rand.length > 100
				start = rand.length - 100
				rand = rand.substr start
			
			return rand
		
		
		@createNew: (data) ->
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s) ' +
				' VALUES (%i,"%s"); SELECT LAST_INSERT_ID() AS %s;'
			, [
				TNAME
				COL.uploaderAccountId
				COL.fileName
				data.accountId
				data.fileName
				
				COL.imageId
			]
			# console.log sql
			con = app.db.newMultiCon()
			qcnt = 0
			imageId = null
			con.query sql
			.on 'result', (res)->
				++qcnt
				res.on 'row', (row)->
					if qcnt == 2
						imageId = parseInt row.imageId
				res
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject '' + err
			.on 'end', (info)->
				console.log 'Completed ' + qcnt + ' queries on ' + TNAME
				def.resolve imageId
			con.end()
			
			return def.promise
		
		@getPathByImageId: (imageId)->
			def = app.Q.defer()
			sql = app.vsprintf 'SELECT %s FROM %s WHERE %s = %i'
			, [
				COL.fileName
				TNAME
				COL.imageId, imageId
			]
			
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						path: row.path
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					def.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject '' + err
			con.end()
			
			return def.promise
		
		# Be sure they own it
		# @delete: (eaterId, accountId)->
		# 	def = app.Q.defer()
		# 	sql = app.vsprintf 'DELETE FROM %s WHERE %s = %i AND %s = %i'
		# 	, [
		# 		TNAME
		# 		COL.eaterId, eaterId
		# 		COL.accountId, accountId
		# 	]
		# 	# console.log sql
		# 	con = app.db.newCon()
		# 	con.query sql
		# 	.on 'error', (err)->
		# 		console.log "> DB: Error on old threadId " + this.tId + " = " + err
		# 		def.reject()
		# 	.on 'end', ()->
		# 		def.resolve()
		# 	con.end()
			
		# 	return def.promise