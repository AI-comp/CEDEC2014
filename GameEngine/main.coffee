MAX_AI_TIME = 10 * 1000
MAX_AJAX_TIME = MAX_AI_TIME + 1000 * 2
MAX_WAIT_TIME = MAX_AI_TIME + 1000
context = {}
commands = []
players = []
time = null
isStarting = false
isLiving = false

# TODO: Use inheritance to reduce code clones
class CodePlayer
	constructor: (@code, @pid) ->
		@worker = new Worker('worker.js')
		@result = null
		@worker.addEventListener 'message', (e) =>
			switch e.data.type
				when 'initialized'
					console.log("engine received initialized: " + JSON.stringify(e.data, null, 2))
				when 'advanced'
					console.log("engine received advanced: " + JSON.stringify(e.data, null, 2))
			@result = e.data
		, false

	start: ->
		@result = null
		@worker.postMessage { type: 'initialize', code: @code }

	advance: (context) ->
		@result = null
		@worker.postMessage { type: 'advance', context: context }

	terminate: () ->
		@worker.terminate()

class WebAppPlayer
	constructor: (@url, @pid) ->
		@lags = []
		@sessionId = null
		@result = null
		@time = null

	ajax: (data) ->
		console.log('ajax: ' + JSON.stringify(data, null, 2))
		$.ajax {
			type: 'GET',
			url: @url,
			data: data,
			dataType: 'jsonp',
			timeout: MAX_AJAX_TIME,
			jsonpCallback: 'jsonpCallback' + @pid
		}

	start: ->
		console.log('start')
		@result = null
		@ajax { type: 'start' }
			.then (json) =>
				@sessionId = json.sessionId
				@result = {}
			, (json) =>
				@result = {}

	advance: (context) ->
		@result = null
		@ping(context)

	ping: (context) ->
		@time = new Date().getTime()
		@ajax { type: 'ping', sessionId: @sessionId }
			.then (json) => # => keeps @ outer's this
				@lags.push(new Date().getTime() - @time)
				if (@lags.length > 10)
					@lags.shift()
				$('#time').text(JSON.stringify(@lags, null, 2))
				@advanceBody(context)
			, (json) =>
				@result = {}

	advanceBody: (context) ->
		@time = new Date().getTime()
		@ajax { type: 'advance', sessionId: @sessionId, context: context }
			.then (json) => # => keeps @ outer's this
				@time = new Date().getTime() - @time
				if @lags.length > 0
					@time = @time - @lags.reduce((a, b) -> a + b) / @lags.length
				console.log('advance: ' + @time + ": " + JSON.stringify(json, null, 2))
				@result = { command: json.command, time: @time }
			, (json) =>
				@result = {}

	terminate: () ->

$ ->
	console.log('ready')
	$('#start').click ->
		if not isStarting
			isStarting = true
			for player in players
				player.terminate()
			start()

createPlayer = (index) ->
	if $('input[name="ai' + index + '"]:checked').val() == 'url'
		new WebAppPlayer($('#url' + index).val(), index)
	else
		new CodePlayer($('#code' + index).val(), index)		

isFinished = () ->
	for player in players
		if player.result == null
			return false
	true

currentPlayer = () ->
	players[context.playerIndex]

advanceTurn = () ->
	context.playerIndex = context.playerIndex + 1
	if context.playerIndex == players.length
		context.playerIndex = 0
		context.turn = context.turn + 1
	time = new Date().getTime()
	currentPlayer().advance(context)

start = () ->
	if not isLiving
		console.log('start')
		$('#log').text('')
		$('#debug').text('')

		context = { turn: 1, playerIndex: -1, history: [] }
		commands = []
		players = []
		for i in [0 ... 2]
			players.push(createPlayer(i))
			players[i].start()

		isLiving = true
		isStarting = false
		initialize()
	else
		setTimeout( ->
			start()
		, 1000)

initialize = () ->
	console.log('initialize')
	if isFinished()
		advanceTurn()
		advance()
	else if not isStarting
		setTimeout( ->
			initialize()
		, 1000)
	else
		isLiving = false
		console.log('terminate')

normalize = (command) ->
	switch command.toLowerCase()
		when 'scissor' then 'sc'
		when 'paper' then 'pa'
		when 'stone' then 'st'
		else 'un'

advance = () ->
	currentTime = new Date().getTime()
	console.log('advance: ' + currentTime + ', ' + time + ', ' + (currentTime - time))
	timeOver = currentTime - time > MAX_WAIT_TIME
	if currentPlayer().result != null || timeOver
		$('#debug').append('advance: ' + JSON.stringify(currentPlayer().result, null, 2) + '<br />')
		ret = currentPlayer().result
		cmd = if not timeOver && ret.time <= MAX_AI_TIME then ret.command else ''
		commands.push normalize(cmd)
		if commands.length == players.length
			$('#debug').append('advance: ' + JSON.stringify(commands, null, 2) + '<br />')
			c1 = commands[0]
			c2 = commands[1]
			if (c1 == 'sc' && c2 == 'pa') || (c1 == 'pa' && c2 == 'st') || (c1 == 'st' && c2 == 'sc') || (c1 != 'un' && c2 == 'un')
				$('#log').append('Player 1 wins !')
			else if (c1 == 'sc' && c2 == 'st') || (c1 == 'pa' && c2 == 'sc') || (c1 == 'st' && c2 == 'pa') || (c1 == 'un' && c2 != 'un')
				$('#log').append('Player 2 wins !')
			else
				$('#log').append('Draw !')
			$('#log').append('<br>')
			context.history.push commands
			commands = []
		advanceTurn()
	if not isStarting && context.turn <= 5
		setTimeout( ->
			advance()
		, 1000)
	else
		isLiving = false
		console.log('terminate')
