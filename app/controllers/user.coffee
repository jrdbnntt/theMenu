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
						
						
		########################################################################
		# Add recipe
		@addRecipe = (req, res)->
			res.render 'user/add/recipe',
				title: 'Add New Recipe'
		@addRecipe_submit = (req, res)->
			res.send
				success: true
				body: {}
		
		########################################################################
		# Add ingredient
		@addIngredient = (req, res)->
			res.render 'user/add/ingredient',
				title: 'Add New Ingredient'
		@addIngredient_submit = (req, res)->
			input = null
			form = new app.formidable.IncomingForm()
			form.parse req, (err, fields, files)->
				console.log app.util.inspect fields
				input = fields
				if err
					res.send 
						success: false
						body:
							error: err

			form.on 'end', (fields, files)->
				# Temporary location of our uploaded file
				srcPath = this.openedFiles[0].path
				
				# The file name of the uploaded file
				fileName = app.models.Image.genFileName this.openedFiles[0].name
				
				# Location where we want to copy the uploaded file
				dstLocation = app.models.Image.uploadDir

				app.fs.move srcPath, dstLocation + fileName
				, (err)->
					if !err
						console.log '[UPLOAD]' + fileName + ' moved to ' + dstLocation
						
						# Save image location
						if input.name? &&
						input.byMass? &&
						input.description?
							app.models.Image.createNew
								fileName: fileName
								accountId: req.session.user.accountId
							.then (imageId)->								
								# Save Ingredient
								app.models.Ingredient.createNew
									imageId: imageId
									name: input.name.charAt(0).toUpperCase() + input.name.slice(1)
									byMass: input.byMass
									description: input.description
									submissionAccountId: req.session.user.accountId
								.then ()->
									res.send 
										success: true
										body:
											href: '/public/ingredients/' + imageId
								, (err)->
									res.send 
										success: false
										body:
											error: 'Problem saving ingredient'
							, (err)->
								res.send 
									success: false
									body:
										error: 'Problem saving image'
						else
							res.send 
								success: false
								body:
									error: 'Missing parameters'
					else
						res.send 
							success: false
							body:
								error: 'Problem moving image'
			.on 'error', ()->
				res.send 
					success: false
					body:
						error: 'Problem retrieving image'
				
			
		########################################################################
		# Pantry
		@pantry = (req, res)->
			res.render 'user/pantry',
				title: 'Pantry'