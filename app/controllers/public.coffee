module.exports = (app) ->
	class app.PublicController
		@index = (req, res) ->
			res.render 'index',
				title: 'Home'