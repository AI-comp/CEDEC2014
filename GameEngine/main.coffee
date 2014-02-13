history = []

class EvalPlayer
	constructor: (code, @pid) ->
		eval(code)
		@command = program
		@id = null
		@cmd = null

	start: ->
		dfd = $.Deferred()
		dfd.resolve [ { 'id': 'code' } ]
		dfd.promise()

	advance: ->
		time = new Date().getTime()
		@cmd = @command(history).toLowerCase()
		time = new Date().getTime() - time
		$('#debug').append('advance: ' + time + ": " + @cmd + '<br>')

class Player
	constructor: (@url, @pid) ->
		@lags = []
		@id = null
		@cmd = null

	ajax: (data) ->
		console.log('ajax: ' + JSON.stringify(data, null, 2))
		$.ajax {
			type: 'GET',
			url: @url,
			data: data,
			dataType: 'jsonp',
			timeout: 10000,
			jsonpCallback: 'jsonpCallback' + @pid
		}

	start: ->
		console.log('start')
		@ajax { type: 'start' }

	advance: ->
		@cmd = null
		@ping()

	ping: ->
		time = new Date().getTime()
		@ajax { type: 'ping', id: @id }
			.done (json) => # => keeps @ as one out of this closure
				@lags.push(new Date().getTime() - time)
				if (@lags.length > 10)
					@lags.shift()
				$('#time').text(JSON.stringify(@lags, null, 2))
				setTimeout( =>
					@command()
				, 1000)

	command: ->
		time = new Date().getTime()
		@ajax { type: 'advance', id: @id, context: { history: history } }
			.done (json) => # => keeps @ as one out of this closure
				time = new Date().getTime() - time
				if @lags.length > 0
					time = time - @lags.reduce((a, b) -> a + b) / @lags.length
				@cmd = json.cmd.toLowerCase()
				switch @cmd
					when 'scissor' then console.log('Scissor')
					when 'paper' then console.log('Paper')
					when 'stone' then console.log('Stone')
					else console.log('Unknown')
				$('#debug').append('advance: ' + time + ": " + JSON.stringify(json, null, 2) + '<br>')

$ ->
	console.log('ready')
	$('#start').click ->
		console.log('start')
		p1 = createPlayer(1)
		p2 = createPlayer(2)
		$.when(p1.start(), p2.start())
			.then (json1, json2) -> # => keeps @ as one out of this closure
				console.log('started')
				p1.id = json1[0].id
				p2.id = json2[0].id
				p1.advance()
				p2.advance()
				process(p1, p2)

createPlayer = (index) ->
	if $('input[name="ai' + index + '"]:checked').val() == 'url'
		new Player($('#url' + index).val(), index)
	else
		new EvalPlayer($('#code' + index).val(), index)

process = (p1, p2) ->
	console.log('process')
	if p1.cmd && p2.cmd
		history.push [p1.cmd, p2.cmd]
		if (p1.cmd == 'scissor' && p2.cmd == 'paper') || (p1.cmd == 'paper' && p2.cmd == 'stone') || (p1.cmd == 'stone' && p2.cmd == 'scissor')
			$('#log').append('Player 1 wins !')
		else if (p1.cmd == 'scissor' && p2.cmd == 'stone') || (p1.cmd == 'paper' && p2.cmd == 'scissor') || (p1.cmd == 'stone' && p2.cmd == 'paper')
			$('#log').append('Player 2 wins !')
		else
			$('#log').append('Draw !')
		$('#log').append('<br>')
		p1.advance()
		p2.advance()
	setTimeout( ->
		process(p1, p2)
	, 1000)
