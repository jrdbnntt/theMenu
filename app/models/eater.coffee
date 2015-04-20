###
	For 'Eater' table.
###

#table constants
COL = 
	eaterId: 'eaterId'
	accountId: 'accountId'
	name: 'name'
	description: 'description'
	chefLevel: 'chefLevel'
	
module.exports = (app) ->
	TNAME = 'Eater'
	TREL = null
	
	class app.models.Eater
		constructor: ()->		
		
		@createNew: (data) ->
			def = app.Q.defer()
			sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s) ' +
				' VALUES (%i,"%s","%s",%i)'
			, [
				TNAME
				
				COL.accountId
				COL.name
				COL.description
				COL.chefLevel
				
				data.accountId
				data.name
				data.description
				data.chefLevel
			]
			# console.log sql
			con = app.db.newCon()
			con.query sql
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject()
			.on 'end', ()->
				def.resolve()
			con.end()
			
			return def.promise
		
		@getAllByAccountId: (accountId)->
			def = app.Q.defer()
			sql = app.vsprintf 'SELECT * FROM %s WHERE %s = %i ORDER BY %s ASC'
			, [
				TNAME
				COL.accountId, accountId
				COL.eaterId
			]
			
			result = []
			con = app.db.newCon()
			con.query sql 
			.on 'result', (res)->
				res.on 'row', (row)->
					result.push 
						eaterId: parseInt row.eaterId
						accountId: parseInt row.accountId
						name: row.name
						description: row.description
						chefLevel: parseInt row.chefLevel
				res.on 'end', (info)->
					console.log 'Got ' + info.numRows + ' rows from ' + TNAME
					def.resolve result
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject err
			con.end()
			
			return def.promise
		
		@delete: (eaterId)->
			def = app.Q.defer()
			sql = app.vsprintf 'DELETE FROM %s WHERE %s = %i'
			, [
				TNAME
				COL.eaterId, eaterId
			]
			# console.log sql
			con = app.db.newCon()
			con.query sql
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject()
			.on 'end', ()->
				def.resolve()
			con.end()
			
			return def.promise
		