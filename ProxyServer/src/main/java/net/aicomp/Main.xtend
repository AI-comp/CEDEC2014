package net.aicomp

import com.google.gson.Gson
import de.oehme.xtend.contrib.Synchronized
import fi.iki.elonen.NanoHTTPD
import fi.iki.elonen.ServerRunner
import java.util.HashMap
import java.util.List

class HelloServer extends NanoHTTPD {
	static var sessionId = 0
	static var port = 8080
	static val players = new HashMap<String, Player>()
	static val gson = new Gson();

	new() {
		super(port)
	}

	@Synchronized def static nextId() {
		sessionId = sessionId + 1
		sessionId.toString
	}

	override serve(NanoHTTPD.IHTTPSession session) {
		val method = session.getMethod()
		val uri = session.getUri()
		val params = session.getParms()
		val funcName = params.get("callback")
		System.out.println(method + ", " + uri + ", " + params)

		val data = new HashMap<String, String>()
		val type = params.get("type")
		switch type {
			case "start": {
				val sessionId = nextId()
				players.put(sessionId, new Player())
				data.put("sessionId", sessionId)
			}
			case "ping": {
			}
			case "advance": {
				val sessionId = params.get("sessionId")
				val ctx = gson.fromJson(params.get("context"), typeof(Context))
				System.out.println(sessionId)
				data.put("command", players.get(sessionId).advance(ctx))
			}
		}

		val json = gson.toJson(data)
		var jsonp = funcName + "(" + json + ");";
		System.out.println(jsonp)
		new NanoHTTPD.Response(NanoHTTPD.Response.Status.OK, "application/javascript", jsonp)
	}

	def static main(String[] args) {
		if (args.length > 1) {
			try {
				port = Integer.parseInt(args.get(0));
			} catch (NumberFormatException e) {
			}
		}
		System.out.println("Starting server with " + port + " port.")
		ServerRunner.run(typeof(HelloServer))
	}
}

class Context {
	int turn
	int playerIndex
	List<List<String>> history
}
