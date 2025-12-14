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

	Roy, Sivaraj, Paleri:\
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

	#show: later
	- Morel, Renvoise (1979):
		- vier Datenflussanalysen
		- nicht optimal
	#show: later
	- Knoop, Ruthing, Steffen (1992):
		- vier Datenflussanalysen
		- optimal
	#show: later
	- Roy, Paleri (2003):
		- drei Datenflussanalysen
		- nicht optimal
]

#slide[
	== Wie sieht unser Kontrollflussgraph aus?

	#show: later
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

	Wir suchen Redundanzpfade für ein Ausdruck $e$.

	\
	#show: later
	- $e$ ist am Punkt $p$ teilweise verfügbar, falls es mindestens einen Pfad
		von $"entry"$ zu $p$ gibt, der $e$ berechnet
	#show: later
	- $e$ ist am Punkt $p$ teilweise erwartet, falls es mindestens einen Pfad
		von $p$ zu $"exit"$ gibt, der $e$ berechnet
	#show: later
	- wir verbinden adjazente Punkte, die teilweise verfügbar und teilweise
		erwartet sind, zu einem Redundanzpfad
	#show: later
	*wir erkennen:* $e$ ist an Anfang und Ende aller seiner Redundanzpfade!
]

#slide[
	== Umsetzung

	Wir können Redundanz ohne Datenflussanalyse berechnen.

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
	=== Beispiel 1

	#align(center)[
		#image("example1_5.svg", height: 85%)
	]
]

#slide[
	=== Beispiel 1

	#align(center)[
		#image("example1_6.svg", height: 85%)
	]
]

#slide[
	== Das reicht noch nicht!

	Redundanz sagt uns nicht, wie wir das Programm transformieren können, ohne
	auf manchen Pfaden ungebrauchte Berechnungen einzufügen

	\
	#show: later
	- $e$ ist am Punkt $p$ verfügbar, falls $e$ in jedem Pfad von $"entry"$ zu
		$p$ berechnet wird
	#show: later
	- $e$ ist am Punkt $p$ erwartet, falls $e$ in jedem Pfad von $p$ zu $"exit"$
		berechnet wird
	#show: later
	- ein Punkt $p$ ist sicher bezüglich dem Einfügen von $e$, falls $e$ an $p$
		verfügbar oder erwartet ist
	#show: later
	- wir verbinden adjazente Punkte, die sicher, teilweise verfügbar und
		teilweise erwartet sind, zu einem sicheren Redundanzpfad
]

#slide[
	== Umsetzung

	Wir können Sicherheit mittels zwei klassischer Datenflussanalysen, der
	Verfügbare-Ausdrücke-Analyse und der Erwartete-Ausdrücke-Analyse,
	berechnen.

	#show: later
	Mithilfe der Informationen über Sicherheit können wir sichere teilweise
	Verfügbarkeit und sichere teilweise Erwartung berechnen.

	#show: later
	Der Pfad von $s$ zu $t$, entlang dem $e$ an jedem Punkt sowohl sicher
	teilweise verfügbar als auch sicher teilweise erwartet ist, bildet einen
	sicheren Redundanzpfad
]

#slide[
	== Wie könnte das nun in Code aussehen?

	#show: later
	- Schritte:
		- Verfügbare-Ausdrücke-Analyse
		- Erwartete-Ausdrücke-Analyse
		- Berechnung der sicher teilweise verfügbaren Pfade
		- Berechnung der sicher teilweise erwarteten Pfade
	#show: later
	- Wir betrachten hier nur die Berechnung für einen konkreten Ausdruck
		- funktioniert analog parallel für alle $n$ Ausdrücke eines
			Programms
]

#slide[
	=== Fixpunktalgorithmen (Datenflussanalyse)

	#show: later
	- Initialisierung:
		- initialisiere Start/Endknoten
	#show: later
	- Berechnung:
		- solange die Knoten sich verändern:
			- gehe durch alle Knoten und führe Berechnungen auf ihnen aus
	#show: later
	- Terminierung:
		- der Algorithmus terminiert, wenn sich in einem Schleifendurchlauf kein
			Knoten verändert
		- d.h. der Algorithmus konvergiert auf ein Fixpunkt
]

#slide[
	=== Verfügbare-Ausdrücke-Analyse

	```py
	def AvExpr(CFG):
		for i in CFG.V:
			if i == CFG.entry:
				i.AvOut = False
			else:
				i.AvOut = TOP
		changes = True
		while changes:
			changes = False
			for i in CFG.V:
				if i != CFG.entry:
					i.AvIn = all([p.AvOut for p in i.pred])
					AvOut_i = i.AvLoc or i.AvIn and i.Transp
					if i.AvOut != AvOut_i:
						i.AvOut = AvOut_i
						changes = True
	```
]

#slide[
	=== Erwartete-Ausdrücke-Analyse

	```py
	def AntExpr(CFG):
		for i in CFG.V:
			if i == CFG.exit:
				i.AntIn = False
			else:
				i.AntIn = TOP
		changes = True
		while changes:
			changes = False
			for i in CFG.V:
				if i != CFG.exit:
					i.AntOut = all([p.AntIn for p in i.succ])
					AntIn_i = i.AntLoc or i.AntOut and i.Transp
					if i.AntIn != AntIn_i:
						i.AntIn = AntIn_i
						changes = True
	```
]

#slide[
	=== Arbeitslistenalgorithmen

	#show: later
	- Initialisierung:
		- füge jeden Knoten, der $e$ beinhaltet, in die Arbeitsliste
			ein
	#show: later
	- Berechnung:
		- nimm Knoten $n$ aus der Arbeitsliste
		- falls $n$ noch nicht besucht wurde:
			- führe Berechnung auf $n$ aus
			- füge Vorgänger/Nachfolger von $n$ in die Arbeitsliste ein
	#show: later
	- Terminierung:
		- der Algorithmus terminiert, wenn die Arbeitsliste leer ist
]

#slide[
	=== Berechnung der sicher teilweise verfügbaren Pfade

	#show raw: set text(size: 15pt)
	```py
	def SpavExpr(CFG):
		worklist = []
		for i in CFG.V:
			i.Visited = False
			i.SpavPathIn = False
			i.SpavPathOut = False
			if i.AntLoc:
				worklist.append(i)
		while len(worklist) != 0:
			i = worklist.pop()
			if not i.Visited:
				i.Visited = True
				i.SpavPathOut = i.AvLoc or i.SpavPathIn and i.Transp
				if i.SpavPathOut:
					for s in i.succ:
						if i.SafeIn:
							s.SpavPathIn = True
							worklist.append(s)
	```
]

#slide[
	=== Berechnung der sicher teilweise erwarteten Pfade

	#show raw: set text(size: 15pt)
	```py
	def SpanExpr(CFG):
		worklist = []
		for i in CFG.V:
			i.Visited = False
			i.SpanPathIn = False
			i.SpanPathOut = False
			if i.AntLoc:
				worklist.append(i)
		while len(worklist) != 0:
			i = worklist.pop()
			if not i.Visited:
				i.Visited = True
				i.SpanPathIn = i.AntLoc or i.SpavPathOut and i.Transp
				if i.SpanPathIn:
					for p in i.pred:
						if p.SafeOut:
							p.SpanPathOut = True
							worklist.append(p)
	```
]

#slide[
	=== Partial Redundancy Elimination

	```py
	def PRE(CFG):
		AvExpr(CFG)
		AntExpr(CFG)
		SpavExpr(CFG)
		SpanExpr(CFG)
		for i in CFG.V:
			i.SredPathIn = i.SpavPathIn and i.SpanPathIn
			i.SredPathOut = i.SpavPathOut and i.SpanPathOut
			i.Insert = not i.SredPathIn and i.SredPathOut
			i.Replace = i.AvLoc and i.SredPathOut or i.AntLoc and i.SredPathIn
		for i in CFG.E:
			i.Insert = not i.from.SredPathOut and i.to.SredPathIn
		Transform(CFG)
	```
]

#slide[
	#align(center)[
		#image("waschbär.png", height: 107%)
	]
]
