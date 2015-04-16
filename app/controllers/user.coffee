module.exports = (app) ->
	class app.UserController
		@index = (req, res) ->
			res.render 'index',
				title: 'Home'