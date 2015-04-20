module.exports = (app) ->
	class app.UserController
		@logout = (req, res)->
			req.session.user = undefined
			res.redirect '/'
		
		
		########################################################################
		# Profile
		
		@profile = (req, res) ->
			res.render 'user/profile',
				title: 'Profile'
				submissions: {}
				savedRecipes: {}
				
		@profile_getAllEaters = (req, res)->
			app.models.Eater.getAllByAccountId req.session.user.accountId
			.then (eaters)->
				res.send
					success: true
					body:
						eaters: eaters
			, (err)->
				res.send
					success: false
					body:
						error: err
						
		@profile_addEater = (req, res)->
			if req.body.name? && 
			req.body.description? &&
			req.body.chefLevel?
				app.models.Eater.createNew
					accountId: req.session.user.accountId
					name: req.body.name
					description: req.body.description
					chefLevel: req.body.chefLevel
				.then ()->
					res.send
						success: true
						body: {}
				, (err)->
					res.send
						success: false
						body:
							error: err
			else
				res.send
					success: false
					body:
						error: 'Invalid parameters'
		
		# Handles misc. 
		@profile_eaterAction = (req, res)->
			if req.body.eaterId? && 
			req.body.action?
				switch req.body.action
					when 'delete'
						app.models.Eater.delete req.body.eaterId, req.session.user.accountId
						.then ()->
							res.send
								success: true
								body: {}
						, (err)->
							res.send
								success: false
								body:
									error: err
			else
				res.send
					success: false
					body:
						error: 'Invalid parameters'