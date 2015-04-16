###
	Handles ACL, run before each HTTP reqest.
	Blocks request if not allowed. Only checks for restriced paths
###

module.exports = acl = (req,res,next) ->	
	isAllowedAccess = true
	
	path = req.path.split '/'
	
	switch path[1]
		when 'user'
			if !res.locals.session.user?
				isAllowedAccess = false
				
	if isAllowedAccess
		next()
	else
		# Does not have access to this page
		res.redirect '/login'