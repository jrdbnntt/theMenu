###
# Loads module dependencies and configures app.
###

# Module dependencies
validator = require 'express-validator'
session = require 'express-session'
dotenv = require 'dotenv'
Q = require 'q'
Mariasql = require 'mariasql'
moment = require 'moment'

#JS utility libraries
util = require 'util'
vsprintf = require('sprintf-js').vsprintf
bcrypt = require 'bcrypt'

# Local lib
autoload = require '../lib/autoload'

# Configuration
module.exports = (app) ->
	# Load random utility libraries
	app.util = util
	app.vsprintf = vsprintf
	app.bcrypt = bcrypt
	app.moment = moment
	app.Q = Q
		
	# Autoload controllers
	autoload 'app/controllers', app
		
	# Load .env
	dotenv.load()
	app.env = process.env
	
	# Configure app settings
	env = app.env.NODE_ENV || 'development'
	app.set 'port', if app.env.DEV_MODE then app.env.PORT_DEV else app.env.PORT_LIVE
	app.set 'views', __dirname + '/../app/views'
	app.set 'view engine', 'jade'
	app.use require('express').static __dirname + '/../public'
	app.use validator()

	# Development settings
	if (env == 'development')
		app.locals.pretty = true
		
	#Session settings
	app.use session 
		name: 'connect.sid'
		secret: app.env.SECRET + ' '
		cookie:
			maxAge: 172800000		#2 days
		saveUninitialized: false
		resave: false
	app.use (req,res,next) ->
		res.locals.session = req.session;
		next();

	
	#setup database, including a global persistent connection
	app.db = 
		Client: Mariasql
		setup:
			host: app.env.DATABASE_HOSTNAME
			port: app.env.DATABASE_PORT
			user: app.env.DATABASE_USERNAME
			password: app.env.DATABASE_PASSWORD
			db: app.env.DATABASE_NAME
	app.db.newCon = ()->
			con = new app.db.Client()
			con.connect app.db.setup
			con.on 'connect', ()->
				this.tId = this.threadId #so it isnt deleted
				# console.log '> DB: New connection established with threadId ' + this.tId
			.on 'error', (err)->
				console.log '> DB: Error on threadId ' + this.tId + '= ' + err
			.on 'close', (hadError)->
				if hadError
					console.log '> DB: Connection closed with old threadId ' + this.tId + ' WITH ERROR!'
				else
					# console.log '> DB: Connection closed with old threadId ' + this.tId + ' without error'
			return con

	#setup models (must setup db first)
	app.models = {}
	autoload 'app/models', app
	
