#import "@preview/polylux:0.4.0": *

#set page(
	paper: "presentation-16-9",
	footer: align(right, text(size: .8em, toolbox.slide-number)),
	margin: (bottom: 2em, rest: 1em),
)
#set text(font: "New Computer Modern", size: 23pt, lang: "de")
#set par(justify: true)
#show raw: set text(font: "New Computer Modern Mono")
#show math.equation: set text(font: "New Computer Modern Math")
#show heading: set block(below: 2em)

#slide[
	#set page(footer: none)
	#set align(horizon)

	Reshma, Sreekala, Vineeth:\
	#text(1.5em)[Partial Redundancy Elimination in Two Iterative Data Flow Analyses]

	\
	Edwin Löffler, 15.12.2025
]

#slide[
	== Was war das nochmal?

	eine Programmoptimierung, die Common Subexpression Elimination (CSE) und Loop Invariant Code Motion (LICM) zu einer Optimierung kombiniert
]

#slide[
	=== Und konkret? — CSE

	eine Programmoptimierung, die mittels einer Datenflussanalyse gemeinsame Teilausdrücke sucht und in Zwischenvariablen rauszieht

	#show: later
	#toolbox.side-by-side[
		aus
			```py
			a = b * c + g
			d = b * c * e
			```
	][
		wird
		```py
		tmp = b * c
		a = tmp + g
		d = tmp * e
		```
	]
]

#slide[
	=== Und konkret? — LICM

	eine Programmoptimierung, die mittels einer Datenflussanalyse zur Laufzeit konstante Ausdrücke aus dem Schleifenrumpf in den Schleifenkopf bewegt

	#show: later
	#toolbox.side-by-side[
		aus
		```py
		while i < n:
			x = y + z
			a[i] = 6 * i + x * x
			i = i + 1
		```
	][
		wird
		```py
		if i < n:
			x = y + z
			tmp = x * x
			while True:
				a[i] = 6 * i + tmp
				i = i + 1
				if not i < n:
					break
		```
	]
]

#slide[
	== Geschichte

	- Morel, Renvoise:
		- vier beidseitige Datenflussanalysen
		- nicht optimal
		- später verbessert von Dhamdhere, aber immer noch suboptimal
	- Knoop, Ruthing, Steffen:
		- vier einseitige Datenflussanalysen
		- optimal
		- später abgewandelt von Drechsler und Stadel
	- Roy:
		- drei einfache Datenflussanalysen
		- optimal
]
