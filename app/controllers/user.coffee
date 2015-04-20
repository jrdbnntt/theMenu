module.exports = (app) ->
	class app.UserController
		@logout = (req, res)->
			req.session.user = undefined
			res.redirect '/'
			
		@profile = (req, res) ->
			res.render 'user/profile',
				title: 'Profile'
				submissions: {}
				savedRecipes: {}
				
		@profile_getAllEaters = (req, res)->
			res.send
				success: false
				body:
					error: 'Invalid parameters'
					
		@profile_addEater = (req, res)->
			if req.body.description? &&
			req.body.chefLevel?
				res.send
					success: true
					body: {}
			else
				res.send
					success: false
					body:
						error: 'Invalid parameters'