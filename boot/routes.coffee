###

All routes go here

See README for a simplified list.

###
acl = require '../lib/acl'
bodyParser = require 'body-parser'

module.exports = (app) ->
	#Body parsers
	jsonParser = bodyParser.json()
	urlencodedParser = bodyParser.urlencoded {extended: false}
	
	# Enforce ACL
	app.use acl
	
	###########################################################################
	# PUBLIC PAGES
	# Site Home
	app.get '/', app.PublicController.index
	app.get '/home', app.PublicController.index
	app.get '/index', app.PublicController.index
	
	# Sign up
	app.get '/signup', app.PublicController.signup
	app.post '/signup', jsonParser, app.PublicController.signup_submit
	
	# Log in/out
	app.get '/login', app.PublicController.login
	app.post '/login', jsonParser, app.PublicController.login_submit
	
	# Recipes (browse/search)
	app.get '/recipes', app.PublicController.recipes
	app.get '/recipes/:recipeId', app.PublicController.singleRecipe
	
	# Ingredients (browse/search)
	app.get '/ingredients', app.PublicController.ingredients
	app.get '/ingredients/:ingredientId', app.PublicController.singleIngredient
	
	###########################################################################
	# USER PAGES 
	# Profile
	app.get '/user/', app.UserController.profile
	app.get '/user/profile', app.UserController.profile
	app.post '/user/profile/getAllEaters', jsonParser, app.UserController.profile_getAllEaters
	app.post '/user/profile/addEater', jsonParser, app.UserController.profile_addEater
	app.post '/user/profile/eaterAction', jsonParser, app.UserController.profile_eaterAction
	
	# Logout
	app.get '/user/logout', app.UserController.logout
	
	# Submit Recipe
	app.get '/user/add/recipe', app.UserController.addRecipe
	app.post '/user/add/recipe', jsonParser, app.UserController.addRecipe_submit
	
	# Submit Ingredient
	app.get '/user/add/ingredient', app.UserController.addIngredient
	app.post '/user/add/ingredient', jsonParser, app.UserController.addIngredient_submit
	
	# Pantry
	app.get '/user/pantry', app.UserController.pantry
	
	###########################################################################
	# ADMIN PAGES
	
	
	# Page not found (404) ####################################################
	# This should always be the LAST route specified
	app.get '*', (req, res) ->
		res.render 'public/404', title: 'Error 404'
