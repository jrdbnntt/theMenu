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
		
		########################################################################
		# View recipes
		@recipes = (req, res)->
			res.render 'public/recipes',
				title: 'Recipes'
		@singleRecipe = (req, res)->
			res.render 'public/singleRecipe',
				title: 'TODO'
		
		########################################################################
		# View ingredients (pages [1,total])
		@ingredients = (req, res)->
			title = 'Ingredients'
			view = 'public/ingredients'
			search = req.query.search
			pageNum = req.query.pageNum
			pageTotal = req.query.pageTotal
			
			if search?
				search = search.replace(/%20/g, ' ').replace(/['"]/g,'').trim()
				if search < 4 || search > 84
					search = undefined
			if pageNum? && !isNaN(pageNum)
				pageNum = parseInt pageNum
				if pageNum < 1
					pageNum = 1
			else 
				pageNum = 1
			if pageTotal? && !isNaN(pageTotal)
				pageTotal = parseInt pageTotal
				if pageTotal < 25 || pageTotal > 100
					pageTotal = 25
			else
				pageTotal = 25
			
			app.models.Ingredient.getSearchSimple pageTotal, pageNum, search
			.then (result)->
				res.render view,
					title: title
					isSearch: search?
					search: search
					pageNum: pageNum
					pageTotal: pageTotal
					ingredients: result.rows
					totalCount: result.totalCount
			, (err)->
				res.render view,
					title: title
					isSearch: search?
					search: search
					pageNum: pageNum
					pageTotal: pageTotal
					ingredients: []
					totalCount: 0
				
				
		@singleIngredient = (req, res)->
			view = 'public/singleIngredient'
			ingredientId = req.params.ingredientId
			
			if !isNaN ingredientId
				app.models.Ingredient.getSingle ingredientId
				.then (result)->
					res.render view,
						title: result.name
						ingredient: result
				, (err)->
					res.redirect '/ingredients'
			else
				res.redirect '/ingredients'
			