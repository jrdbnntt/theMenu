###
	For 'Account' table.
###

#table constants
COL = 
	accountId: 'accountId'
	ownerEaterId: 'ownerEaterId'
	currentRecipeId: 'currentRecipeId'
	username: 'username'
	email: 'email'
	password: 'password'
	isAdmin: 'isAdmin'
	
module.exports = (app) ->
	TNAME = 'Account'
	TREL = null		
	
	class app.models.Account
		constructor: ()->		
		
		# Creates a new user in the database.
		@createNew: (data) ->
			#email/username MUST be checked for existence prior to call
			def = app.Q.defer()
			
			#Encrypt password
			app.bcrypt.genSalt 10, (err,salt)->
				app.bcrypt.hash data.password, salt, (err, hash)->
					sql = app.vsprintf 'INSERT INTO %s (%s,%s,%s,%s) ' +
						' VALUES ("%s","%s","%s",%i)'
					, [
						TNAME
						
						COL.username
						COL.email
						COL.password
						COL.isAdmin
						
						data.username
						data.email
						hash
						0 #false
					]
					console.log sql
					con = app.db.newCon()
					con.query sql
					.on 'error', (err)->
						console.log "> DB: Error on old threadId " + this.tId + " = " + err
						def.reject()
					.on 'end', ()->
						def.resolve()
					con.end()
			
			return def.promise
		
		# Checks if this email belongs to a user. Returns true/false in promise
		@checkEmailUsed: (email) ->
			def = app.Q.defer()
			sql = app.vsprintf 'SELECT COUNT(*) AS c FROM %s WHERE %s = "%s"'
			, [
				TNAME
				COL.email
				email
			]
			console.log sql
			con = app.db.newCon()
			con.query sql
			.on 'result', (res)->
				res.on 'row', (row)->
					def.resolve row.c == '0'
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject()
				
			con.end()
			
			return def.promise
		
		@checkUsernameUsed: (username) ->
			def = app.Q.defer()
			sql = app.vsprintf 'SELECT COUNT(*) AS c FROM %s WHERE %s = "%s"'
			, [
				TNAME
				COL.username
				username
			]
			console.log sql
			con = app.db.newCon()
			con.query sql
			.on 'result', (res)->
				res.on 'row', (row)->
					def.resolve row.c == '0'
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject()
				
			con.end()
			
			return def.promise
		
		#checks if it is a valid login
		@checkLogin: (data) ->
			def = app.Q.defer()
			sql = app.vsprintf 'SELECT * FROM %s WHERE %s = "%s"'
			, [
				TNAME
				COL.email
				data.email
			]
			console.log sql
			accountData = {}
			passTemp = null
			con = app.db.newCon()
			con.query sql
			.on 'result', (res)->
				res.on 'row', (row)->
					#user found
					passTemp = row.password
					accountData =
						accountId: parseInt row.accountId
						username: row.username
						email: row.email
						isAdmin: (parseInt row.isAdmin) == 1

				res.on 'end', (info)->
					if info.numRows > 0
						# check password
						app.bcrypt.compare data.password, passTemp, (err, res)->
							if res #valid password
								def.resolve accountData
							else
								console.log 'LOGIN: Invalid password for "'+accountData.email+'"'
								def.reject 'Invalid login credentials'
							return
					else
						console.log 'LOGIN: Invalid email'
						def.reject 'Invalid login credentials'
			.on 'error', (err)->
				console.log "> DB: Error on old threadId " + this.tId + " = " + err
				def.reject 'A problem occured checking login credentials'
				
			con.end()
			return def.promise
		