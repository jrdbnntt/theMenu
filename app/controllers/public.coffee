module.exports = (app) ->
	class app.PublicController
		@index = (req, res) ->
			res.render 'index',
				title: 'Home'
				
		########################################################################
		# Sign up '/signup'
		@signup = (req, res)->
			res.render 'public/signup',
				title: 'Signup'
		
		@signup_submit = (req, res)->
			if req.body.username? &&
			req.body.email? &&
			req.body.password?
				app.models.Account.checkUsernameUnused req.body.username
				.then ()->
					app.models.Account.checkEmailUnused req.body.email
					.then ()->
						# Looks good, create it
						app.models.Account.createNew
							username: req.body.username
							email: req.body.email
							password: req.body.password
						.then ()->
							console.log 'ACCOUNT CREATED: ' + req.body.username
							res.send
								success: true
								body: {}
						, (err)->
							res.send
								success: false
								body: 
									error: err
					, (err)->
						res.send
							success: false
							body:
								error: err
				, (err)->
					res.send
						success: false
						body:
							error: err
			else
				res.send
					success: false
					body:
						error: 'Invalid Parameters ' + JSON.stringify req.body
		
		########################################################################
		# Log in '/login'
		@login = (req, res)->
			res.render 'public/login',
				title: 'Login'
		
		@login_submit = (req, res)->
			if req.body.email? &&
			req.body.password?
				app.models.Account.checkLogin 
					email: req.body.email
					password: req.body.password
				.then (result)->
					req.session.user = result
					res.send
						success: true
						body:
							username: result.username
				, (err)->
					res.send
						success: false
						body:
							error: err
			else
				res.send
					success: false
					body:
						error: 'Invalid Parameters ' + JSON.stringify req.body
		