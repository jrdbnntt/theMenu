module.exports = (app) ->
	class app.AdminController
		@index = (req, res) ->
			res.redirect '/'