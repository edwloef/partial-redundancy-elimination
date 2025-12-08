#import "@preview/polylux:0.4.0": *

#set page(
	paper: "presentation-16-9",
	footer: align(right, text(size: .8em, toolbox.slide-number)),
	margin: (bottom: 2em, rest: 1em),
)
#set text(font: "New Computer Modern", size: 22pt, lang: "de")
#set par(justify: true)
#show raw: set text(font: "New Computer Modern Mono")
#show math.equation: set text(font: "New Computer Modern Math")
#show heading: set block(below: 2em)

#slide[
	#set page(footer: none)
	#set align(horizon)

	Reshma, Sreekala, Vineeth:\
	#text(1.5em)[Partial Redundancy Elimination in Two Iterative Data Flow
		Analyses]

	\
	Edwin Löffler, 15.12.2025
]

#slide[
	== Was war das nochmal?

	eine Programmoptimierung, die Common Subexpression Elimination (CSE) und
	Loop Invariant Code Motion (LICM) zu einer Optimierung kombiniert
]

#slide[
	=== Konkret -- CSE

	eine Programmoptimierung, die mittels einer Datenflussanalyse gemeinsame
	Teilausdrücke sucht und in Zwischenvariablen rauszieht

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
	=== Konkret -- LICM

	eine Programmoptimierung, die mittels einer Datenflussanalyse zur Laufzeit
	konstante Ausdrücke aus dem Schleifenrumpf in den Schleifenkopf bewegt

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
		- später verbessert von Dhamdhere, aber immer noch nicht optimal
	#show: later
	- Knoop, Ruthing, Steffen:
		- vier einseitige Datenflussanalysen
		- optimal
		- später abgewandelt von Drechsler und Stadel
	#show: later
	- Roy:
		- drei einfache Datenflussanalysen
		- optimal
]

#slide[
	== Wie sieht unser Kontrollflussgraph aus?

	- ein gerichteter Graph $G=(V,E,"entry","exit")$
		- $V$ als Menge aller Knoten
			- $"entry"$ und $"exit"$ als leere Ein- und Ausgangsknoten
		- $E$ als Menge aller Kanten
			- die Kante von $i$ nach $j$ wird dargestellt als $(i, j)$
	#show: later
	- jeder Knoten enthält höchstens eine Aussage der Form
		$"Variable"="Ausdruck"$
	#show: later
	- jeder Knoten $n$ hat
		- direkte Vorgänger $"pred"(n)={m|(m,n)in E}$
		- direkte Nachfolger $"succ"(n)={m|(n,m)in E}$
]

#slide[
	== Grundidee

	Wir suchen sichere Redundanzpfade für ein Ausdruck $e$.

	\
	#show: later
	- jeder Punkt, wo $e$ teilweise verfügbar und teilweise erwartet ist, ist
		redundant
		- wir verbinden adjazente Punkte, die redundant sind, zu einem einfachen
			Redundanzpfad
	#show: later
	- jeder Punkt, wo $e$ verfügbar oder erwartet ist, ist sicher bezüglich dem
		Einfügen von $e$
	#show: later
	- wir verbinden adjazente Punkte, die sowohl sicher als auch redundant sind,
		zu einem sicheren Redundanzpfad
	#show: later
	- $e$ ist am Anfang und Ende von jedem seiner Redundanzpfade zu finden
]

#slide[
	== Ansatz

	Wir können einfache Redundanz ohne Datenflussanalyse berechnen.

	\
	#show: later
	- von einem Knoten $s$, der $e$ beinhaltet, aus in Datenflussrichtung laufen
		und Knoten als teilweise verfügbar markieren, bis $e$ nicht mehr
		existiert oder $"exit"$ erreicht wird
	#show: later
	- von einem Knoten $t$, der $e$ beinhaltet, aus gegen
		Datenflussrichtung laufen und Knoten als teilweise erwartet markieren,
		bis ein Operand von $e$ definiert oder verändert wird
	#show: later
	- der Pfad von $s$ zu $t$, entlang dem $e$ an jedem Punkt sowohl teilweise
		verfügbar als auch teilweise erwartet ist, bildet ein Redundanzpfad
]

#slide[
	== Ansatz

	Wir können Sicherheit mittels zwei klassischer Datenflussanalysen, der
		Verfügbare-Ausdrücke-Analyse und der Erwartete-Ausdrücke-Analyse,
		berechnen.

	\
	#show: later
	- jeder Punkt, an dem $e$ entweder verfügbar oder erwartet ist, ist sicher
		bezüglich dem Einfügen von $e$
	#show: later
	- sichere Redundanz wird dann wie einfache Redundanz berechnet, nur dass
		ein Knoten nur als sicher teilweise verfügbar/erwartet markiert wird,
		falls der jeweilige Punkt bezüglich dem Einfügen von $e$ auch sicher ist
]

#slide[
	=== Beispiel 1

	#align(center)[
		#image("example1_1.svg", height: 85%)
	]
]

#slide[
	=== Beispiel 1

	#align(center)[
		#image("example1_2.svg", height: 85%)
	]
]

#slide[
	=== Beispiel 1

	#align(center)[
		#image("example1_3.svg", height: 85%)
	]
]

#slide[
	=== Beispiel 1

	#align(center)[
		#image("example1_4.svg", height: 85%)
	]
]

#slide[
	=== Beispiel 2

	#align(center)[
		#image("example2_1.svg", height: 85%)
	]
]

#slide[
	=== Beispiel 2

	#align(center)[
		#image("example2_2.svg", height: 85%)
	]
]

#slide[
	=== Beispiel 2

	#align(center)[
		#image("example2_3.svg", height: 85%)
	]
]

#slide[
	=== Beispiel 2

	#align(center)[
		#image("example2_4.svg", height: 85%)
	]
]

#slide[
	=== Beispiel 2

	#align(center)[
		#image("example2_5.svg", height: 85%)
	]
]

#slide[
	=== Available Expression Analysis

	```py
	def AvExpr(CFG, e):
		for i in CFG.nodes:
			if i == CFG.entry:
				i.AvOut = False
			else:
				i.AvOut = T
		changes = True
		while changes:
			changes = False
			for i in CFG.nodes:
				if i != CFG.entry:
					i.AvIn = all([p.AvOut for p in i.pred])
					AvOut_i = i.AvLoc or i.AvIn and i.Transp
					if i.AvOut != AvOut_i:
						changes = True
						i.AvOut = AvOut_i
	```
]

#slide[
	=== Anticipated Expression Analysis

	```py
	def AntExpr(CFG, e):
		for i in CFG.nodes:
			if i == CFG.exit:
				i.AntIn = False
			else:
				i.AntIn = T
		changes = True
		while changes:
			changes = False
			for i in CFG.nodes:
				if i != CFG.exit:
					i.AntOut = all([p.AntIn for p in i.succ])
					AntIn_i = i.AntLoc or i.AntOut and i.Transp
					if i.AntIn != AntIn_i:
						changes = True
						i.AntIn = AntIn_i
	```
]
