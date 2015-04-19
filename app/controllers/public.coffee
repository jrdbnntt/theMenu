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
			res.send
				success: true
				body: {}
		
		########################################################################
		# Log in '/login'
		@login = (req, res)->
			res.render 'public/login',
				title: 'Login'
		
		@login_submit = (req, res)->
			res.send
				success: true
				body: {}
		
		@logout = (req, res)->
			req.session.user = undefined
			res.redirect '/'