advanceBody = null

self.addEventListener 'message', (e) ->
	switch e.data.type
		when 'initialize'
			console.log("worker received initialize: " + JSON.stringify(e.data, null, 2))
			eval(e.data.code)
			advanceBody = advance
			self.postMessage { type: 'initialized' }
		when 'advance'
			console.log("worker received advance: " + JSON.stringify(e.data, null, 2))
			time = new Date().getTime()
			command = advanceBody(e.data.context)
			time = new Date().getTime() - time
			self.postMessage { type: 'advanced', command: command, time: time }
, false
