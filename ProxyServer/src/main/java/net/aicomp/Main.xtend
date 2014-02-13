package net.aicomp

import com.google.gson.Gson
import de.oehme.xtend.contrib.Synchronized
import fi.iki.elonen.NanoHTTPD
import fi.iki.elonen.ServerRunner
import java.util.HashMap
import java.util.List

class HelloServer extends NanoHTTPD {
	static var id = 0
	static var port = 8080
	static val players = new HashMap<String, Player>()
	static val gson = new Gson();

	new() {
		super(port)
	}

	@Synchronized def static nextId() {
		id = id + 1
		id.toString
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
				val id = nextId()
				players.put(id, new Player())
				data.put("id", id)
			}
			case "ping": {
			}
			case "advance": {
				val id = params.get("id")
				val ctx = gson.fromJson(params.get("context"), typeof(Context))
				System.out.println(id)
				data.put("cmd", players.get(id).advance(ctx))
			}
		}

		val json = gson.toJson(data)
		System.out.println(type + ": " + json)
		var jsonp = funcName + "(" + json + ");";
		new NanoHTTPD.Response(jsonp)
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
	List<List<String>> history
}
