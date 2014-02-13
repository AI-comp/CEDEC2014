package net.aicomp

import java.util.Random

class Player {
	val random = new Random()

	def advance(Context ctx) {
		switch random.nextInt(3) {
			case 0:
				"Scissor"
			case 1:
				"Paper"
			case 2:
				"Stone"
		}
	}
}
