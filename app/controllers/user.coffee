module.exports = (app) ->
	class app.UserController
		@logout = (req, res)->
			req.session.user = undefined
			res.redirect '/'
			
		@profile = (req, res) ->
			res.render 'user/profile',
				title: 'Profile'