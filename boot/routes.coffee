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
	
	
	# PUBLIC PAGES ############################################################
	# Site Home
	app.get '/', app.PublicController.index
	app.get '/home', app.PublicController.index
	app.get '/index', app.PublicController.index
	
	
	# USER PAGES ##############################################################
	
	
	# Page not found (404) ####################################################
	# This should always be the LAST route specified
	app.get '*', (req, res) ->
		res.render 'public/404', title: 'Error 404'
