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
		- später verbessert von Dhamdhere, aber immer noch suboptimal
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
	=== Definitionen (1/4)

	- lokale Verfügbarkeit -- ein Ausdruck $e$ ist lokal verfügbar am Ausgang
		des Knotens $i$, falls $e$ in $i$ vorkommt und die Aussage in $i$ die
		Operanden von $e$ nicht verändert
	#show: later
	- lokale Erwartung -- ein Ausdruck $e$ ist lokal erwartet am Eingang des
		Knotens $i$, falls $e$ in $i$ vorkommt
	#show: later
	- Transparenz -- ein Ausdruck $e$ ist transparent im Knoten $i$, falls die
		Berechnung der Aussage in $i$ die Operanden von $e$ nicht verändert
]

#slide[
	=== Definitionen (2/4)

	- Verfügbarkeit -- ein Ausdruck $e$ ist verfügbar am Punkt $p$, falls $e$ in
		jedem Pfad von $"entry"$ zu $p$ berechnet wird, und danach die Operanden
		von $e$ unverändert bleiben
	#show: later
	- Erwartung -- ein Ausdruck $e$ ist erwartet am Punkt $p$, falls $e$ in
		jedem Pfad von $p$ zu $"exit"$ berechnet wird, und bis dahin alle
		Operanden von $e$ unverändert bleiben
	#show: later
	- Sicherheit -- ein Punkt $p$ ist sicher bezüglich dem Einfügen eines
		Ausdrucks $e$, falls $e$ am Punkt $p$ entweder verfügbar oder erwartet
		ist
]

#slide[
	=== Definitionen (3/4)

	- teilweise Verfügbarkeit -- ein Ausdruck $e$ ist teilweise verfügbar am
		Punkt $p$, falls es mindestens ein Pfad von $"entry"$ zu $p$ gibt, in
		dem $e$ berechnet wird, und danach die Operanden von $e$ unverändert
		bleiben
	#show: later
	- sichere teilweise Verfügbarkeit -- ein Ausdruck $e$ ist sicher teilweise
		verfügbar am Punkt $p$, falls er an $p$ teilweise verfügbar ist und
		der Pfad von dem Punkt $k$, ab dem $e$ an $p$ teilweise verfügbar ist,
		zu $p$, sicher ist
	#show: later
	- teilweise Redundanz -- ein Ausdruck $e$ ist teilweise redundant am Punkt
		$p$ falls $e$ teilweise verfügbar am Punkt $p$ ist
]

#slide[
	=== Definitionen (4/4)

	- teilweise Erwartung -- ein Ausdruck $e$ ist teilweise erwartet am Punkt
		$p$, falls es mindestens ein Pfad von $p$ zu $"exit"$ gibt, in dem $e$
		berechnet wird, und bis dahin alle Operanden von $e$ unverändert bleiben
	#show: later
	- sichere teilweise Erwartung  -- ein Ausdruck $e$ ist sicher teilweise
		erwartet am Punkt $p$, falls $e$ an $p$ teilweise erwartet ist und der
		Pfad von dem Punkt $k$, ab dem $e$ teilweise erwartet ist, zu $p$,
		sicher ist
]

#slide[
	=== Notation

	Für den Ausdruck $e$ gilt:
	- $"AvLoc"_i$ --  $e$ ist am Ausgang des Knotens $i$ lokal verfügbar
	- $"AntLoc"_i$ --  $e$ ist am Eingang des Knotens $i$ lokal erwartet
	- $"Transp"_i$ --  $e$ ist im Knoten $i$ transparent
	- $"AvIn"_i\/"AvOut"_i$ --  $e$ ist am Ein-/Ausgang des Knotens $i$
		verfügbar
	- $"AntIn"_i\/"AntOut"_i$ --  $e$ ist am Ein-/Ausgang des Knotens $i$
		erwartet
	- $"SpavPathIn"_i\/"SpavPathOut"_i$ --  Ein-/Ausgang des Knotens $i$ ist auf
		dem sicher teilweise verfügbaren Pfad von $e$
	- $"SredPathIn"_i\/"SredPathOut"_i$ --  Ein-/Ausgang des Knotens $i$ ist auf
		dem sicher teilweise erwarteten Pfad von $e$
]

#slide[
	== Grundidee

	- Erkennung
		- wir brauchen Informationen über teilweise verfügbare Ausdrücke
	- Eliminierung
		- wir brauchen Informationen über teilweise erwartete Ausdrücke
	#show: later
	- wir suchen Redundanzpfade für ein Ausdruck $e$
		- wir markieren alle Punkte, wo $e$ sowohl teilweise verfügbar als auch
			teilweise erwartet ist
		- wir verbinden adjazente markierte Punkte zu einem Redundanzpfad
]

#slide[
	=== Beispiel

	#align(center)[
		#image("example1.svg", height: 85%)
	]
]

#slide[
	=== Beispiel

	#align(center)[
		#image("example2.svg", height: 85%)
	]
]

#slide[
	=== Beispiel

	#align(center)[
		#image("example3.svg", height: 85%)
	]
]

#slide[
	=== Beispiel

	#align(center)[
		#image("example4.svg", height: 85%)
	]
]
