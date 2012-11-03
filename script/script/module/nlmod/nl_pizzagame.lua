--[[
	script/module/nl_mod/nl_pizzagame.lua
	Hanack (Andreas Schaeffer)
	Created: 12-Jun-2011
	Last Modified: 12-Jun-2011
	License: GPL3

	The Dr.Pizzazz Game
	===================

	Im Dr.Pizzazz Game spielen Sauerbraten-Spieler auf dem Sauerbraten-Server eine
	kleine Wirtschaftssimulation um einen virtuellen Pizza-Markt.

	Die Spieler übernehmen dabei gibt zwei Rollen. Zum einen gibt es Spieler, die
	eine Firma gründen. Auf der anderen Seite sind sie auch Konsumenten, die gerne
	Pizza futtern.

	Erste wichtige Information ist, dass Spieler, die auf der NoobLounge 4 spielen,
	virtuelles Spielgeld verdienen. Da es sich um das Pizza-Game handelt und pisto aus
	Italien kommt, handelt es sich um Lire. Je länger man spielt, desto mehr Geld
	verdient man natürlich. Doch das ist nicht Ziel des Spiels.

	Ziel einer Firma ist es, den größtmöglichsten Umsatz zu machen. Die Konsumenten
	wiederum haben das Ziel, so günstig wie möglich an möglichst viele Pizzen
	zu gelangen.

	Und das läuft so: ein Konsument spielt eine Weile auf der NoobLounge. Mit dem
	gesammelten Geld kann er dann Pizzas ordern. Bei der Pizzabestellung kann er
	festlegen, welche Beläge auf die Pizza bekommen. Diese Pizza kann nun von
	einer Firma ausgeliefert werden. Dabei zählt natürlich welche Firma am
	schnellsten ist. Außerdem verdient man weniger, je länger es benötigt, die
	Bestellung auszuliefern. Schnell sein lohnt sich also doppelt. Weiterhin muss
	derjenige, der die Bestellung abgegeben hat, auf dem Server spielen, damit er
	seine Pizza erhalten kann.

	Nebenbei kann man als Teilhaber einer Firma sich nicht selbst Pizzen verkaufen. Das
	würde nämlich immer gleich fad schmecken und löst nur unnötige Interessenskonflikte
	aus. Konsequenterweise kann man auch nicht Teilhaber zweier Firmen sein.

	Um Pizzen herstellen zu können, müssen die Teilhaber der Firmen die Zutaten
	erwirtschaften. Dies tun sie - ja richtig - durch Sauerbraten spielen. Wenn ein
	Teilhaber einen Score macht, bekommt seine Firma 500g Mehl. Kann er dreimal die
	Flagge zurückbringen, bekommt er eine Stange Salami. Die weiteren Zutaten und wie
	man sie bekommt, wird weiter unten aufgelistet.

	Wie man gewiss erahnen kann, kann man Pizzas nur herstellen, wenn die Firma genügend
	von den Zutaten der Wunschpizza hat. Dabei wird es umso schwieriger eine Pizza
	herzustellen, je seltener eine Zutat zu bekommen ist. So muss für eine Artischocken-
	Pizza schon mal ein ulululi gemacht werden, um an die notwendigen Artischocken
	zu gelangen.

	Die Sauerbraten-Spieler werden ihrerseits wiederum versuchen, eine Pizza zu
	bestellen, die möglichst schwer zu produzieren ist. Denn dadurch brauchen die Firmen
	mehr Zeit um die benötigten Zutaten zu "besorgen" und damit wird die Pizza immer
	günstiger. Die Firmen schauen dabei in die Röhre, weil sie damit auch weniger
	verdienen.

	Als Firmeninhaber muss man zusätzlich darauf achten, dass die Zutaten auch
	verbraucht werden, denn sonst vergammeln sie. Das bedeutet, dass man nicht immer
	darauf warten kann, bis eine neue Bestellung eingeht, sondern auch Aufträge annehmen
	muss, bei denen man weniger verdient. Als Firma kann man somit mehrere Strategien
	nutzen. Entweder man geht höheres Risiko ein und wartet auf lukrative Bestellungen;
	geht aber gleichzeitig das Risiko ein, dass die Zutaten vergammeln. Oder man versucht
	so oft wie möglich Pizzen zu verkaufen, um mit der Masse der Verkäufe die geringere
	Marge auszugleichen.

	Letztendlich zählt, welche Firma am Ende der Runde das meiste Geld erwirtschaftet
	hat. Dazu muss die Firma regelmäßig spielen und dabei möglichst viele verschiedene
	Zutaten erarbeiten. Die Firma sollte dabei genau prüfen, welche Pizzen sie
	ausliefert.

	Aber auch als einzelner Spieler (ganz unabhängig von den Firmen) kann man sich
	Respekt verschaffen. Man muss versuchen, mit dem erspieltem und verfügbarem Geld
	möglichst effektiv Pizzen zu bestellen. Das bedeutet, dass die Zutaten dafür für
	die Firmen schwer zu beschaffen sind. Aber sie sollten auch darauf achten, dass
	die bestellten Pizzen nicht ZU kompliziert sind, denn wenn die Pizzas gar nicht
	geliefert werden können, zählt dies nicht ins Ergebnis hinein. Aber es zählt nicht
	nur wie effektiv das Geld genutzt wurde, sondern auch, wieviel Pizzen man letztlich
	bekommen hat. Wichtig ist auch, dass das nach einer getätigten Bestellung der
	Gegenwert der Bestellung (100%-Preis), nicht mehr verfügbar ist. Das heißt, man hat
	das Geld noch, kann sich aber nichts mehr davon kaufen. Erst bei der Lieferung
	wird der tatsächlicher Preis vom Konto abgebucht und das restliche Geld wieder
	entsperrt.
	 

	Commands:
	---------

	#pizza <ZUTAT 1> <ZUTAT 2> <ZUTAT 3> <ZUTAT ...> <ZUTAT n>
		Ein Spieler ordert eine Pizza mit den angegebenen Zutaten. 
	#deliver <CN> [<ID>]
		Liefert eine Bestellung für den Spieler mit der angegebenen CN aus.
		Voraussetzung: Deine Firma verfügt über genügend Zutaten, um die Pizza
		herzustellen.
	#orders
		Listet die Bestellungen der gerade online befindlichen Spieler, die
		nicht zu deiner Firma gehören, auf.
	#onstock
		Listet die Zutaten und deren Menge, welche im Lager der eigenen Firma vorhanden sind, auf.
	#prices
		Listet alle Zutaten und ihre Preise auf.


	Formeln:
	--------

	Gewinn, den eine Firma bei einer gelieferten Pizza macht:
		Gewinn = Basispreis (30 LIRE) + Preis der Zutaten - Lieferzeit

	Punkte, die ein Spieler bei einer gelieferten Pizza macht:
		Gewonnene Punkte = 100%-Preis der Pizza zum Bestellzeitpunkt - tatsächlicher Preis 


	Zutaten:
	--------

+--------------+------------+-------+-----------------+
| ingredientid | name       | price | decreasebyorder |
+--------------+------------+-------+-----------------+
|            2 | flour      |     3 |              40 |
|            4 | corn       |     5 |              10 |
|            3 | tomato     |     6 |              80 |
|            5 | onion      |     7 |              20 |
|           11 | garlic     |     7 |               2 |
|            9 | paprika    |     9 |               9 |
|            1 | cheese     |    10 |              42 |
|            6 | chilli     |    12 |               3 |
|           19 | mushroom   |    13 |              10 |
|           16 | salami     |    14 |              12 |
|           15 | ham        |    17 |              14 |
|            8 | pineapple  |    24 |               7 |
|           12 | olive      |    26 |              11 |
|            7 | artichoke  |    28 |               8 |
|           10 | aubergine  |    29 |              12 |
|           13 | zucchini   |    31 |              14 |
|           17 | gorgonzola |    41 |               8 |
|           14 | tuna       |    48 |              12 |
|           18 | parmesam   |    49 |               6 |
|           19 | mushroom   |    13 |              10 |
+--------------+------------+-------+-----------------+


	ID	| Menge	| Aktion				| Ergebnis									| DONE?
	----+-------+-----------------------+-------------------------------------------+----------
	 0	|	1	| Score					| 500g Käse									| x
	 1	|	1 s	| Flagge tragen			| 10g Käse									| x
	 2	|	10	| Frags					| 50g Mehl									| 
	 3	|	1	| Double Kill			| 250g Käse									| 
	 4	|	1	| Tripple Kill			| 250g Käse (zusätzlich zum Double Kill)	|
	 5	|	3	| Flag Reset			| 1 Stange Salami							| 
	 6	|	1	| ulululi				| 1 Artischocke								| 
	 7	|	1	| einfacher Rohrjump	| 250g Rucola								| 
	 8	|	1	| Killing Spree			| Mozarella									| 
	 9	|	1	| Unstoppable			| Parmesam									| 
	10	|	1	| Most Frags			| 250g Schinken								| 
	11	|	2	| Most Scores			| 100g frische Pilze						| 
	12	|	1	| Pisto ist online		| 1 Karotte									| 


	Webinterface:
	-------------

	Zutaten
		* Liste von Zutaten
		* Wie die Zutaten zu bekommen sind
		* Die aktuelle Gesamtmenge jeder Zutat aller Firmen

	Bestellungen
		* Liste von Bestellungen
		* Von welchem Spieler (wann zuletzt im Spiel)
		* Welche Zutaten

	Firmen
		* Anmeldung einer neuen Firma
		* Anheuern von Inhabern
		* Liste aller Firmen
		* Einzelansicht einer Firma
		** Geld
		** Zutaten und Menge
		** Bisher gelieferte Pizzen

	Ranking Firmen
		* Verdientes Geld <-- Hauptkriterium
		* Entgangenes Geld
		* Gegenwert der Zutaten

	Ranking Spieler
		* Ersparnis = 100%-Preis - tatsächlicher Preis <-- Hauptkriterium
		* 100%-Preis aller gelieferten Pizzen
		* Geld (noch nicht ausgegeben)


	Schema:
	-------

	nl_pizza_companies
		* companyid
		* name
		* money
	nl_pizza_players
		* playername
		* money
		* blockedmoney
	nl_pizza_ingredients
		* ingredientid
		* name
		* price
		* decreasebyorder
		* [weight] <-- Gewicht in Prozent über alle Zutaten
	nl_pizza_company_ingredients
		* companyid
		* ingredientid
		* amount
	nl_pizza_company_players
		* companyid
		* playername
	nl_pizza_orders
		* orderid
		* playername
		* timestamp
		* deliveredbycompanyid (null, wenn noch nicht geliefert)
	nl_pizza_order_ingredients
		* orderid
		* ingredientid

]]


pizza = {}
pizza.running = true
pizza.takeflag = {}
pizza.company_id = {}
pizza.playtime = {}
pizza.realprice = {}
pizza.realprice.min = 5*60 -- Nach fuenf minuten beginnt der preis zu sinken und ...
pizza.realprice.max = 1*24*60*60 -- nach einem tag ist der preis...
pizza.realprice.factor = 2 -- ... nur noch die haelfte so hoch; sinkt danach aber nicht weiter ab.
pizza.runsoutofseed = {} -- Zutaten vergammeln ...
pizza.runsoutofseed.time = 3600000 -- ... jede stunde ...
pizza.runsoutofseed.divisor = 20 -- ... verliert man 5%
pizza.earning = {}
pizza.earning.factor = 1.5
pizza.earning.max_unblocked = 250
pizza.earning.tomato = {}
pizza.earning.tomato.millis = 60000 -- 60 sec
pizza.earning.tomato.amount = 10 -- 15 einheiten tomaten pro zeitspanne (60 sec)
pizza.earning.tomato.teamkillamount = -50 -- bei einem Teamkill verliert man 50 einheiten tomaten (1/3 von dem was man in einem Spiel verdienen kann)
pizza.earning.cheese = {}
pizza.earning.cheese.millis = 15000 -- 15 sec
pizza.earning.cheese.amount = 4 -- 4 einheiten kaese pro zeitspanne (15 sec) = 60/min
pizza.earning.cheese.amountscore = 82 -- fuer score
pizza.earning.flour = {}
pizza.earning.flour.amount = 3
pizza.earning.flour.gotfraggedamount = -1
pizza.earning.flour.flagresetamount = 7
pizza.earning.lire = {}
pizza.earning.lire.millis = 30000 -- 30 sec
pizza.earning.lire.amount = 2 -- Nach Erreichen des Schwellwerts verdient man 1 Lire pro Zeitspanne
pizza.earning.lire.minplaytime = 10*60 -- Anzahl der Minuten, nach wievielen man Geld verdient
pizza.moves = {}
pizza.moves.done = {}



function pizza.is_game_running()
	local result = db.select("nl_pizza_settings", {"status"})
	if result == nil or #result == 0 then
		return false
	else
		if tonumber(result[1]["status"]) == 0 then
			return false
		else
			return true
		end
	end
end

function pizza.list_to_string(list, key)
	-- liefert einen formatierten string zurueck
	local the_string = ""
	for i,item in ipairs(list) do
		if key ~= nil then
			if i == 1 then
				the_string = item[key]
			else
				the_string = string.format("%s, %s", the_string, item[key])
			end
		else
			if i == 1 then
				the_string = item
			else
				the_string = string.format("%s, %s", the_string, item)
			end
		end
	end
	messages.debug(-1, players.admins(), "PIZZA", string.format("list_to_string: %s", the_string))
	return the_string
end

function pizza.get_company(cn)
	-- liefert die companyid der eigenen firma zurueck
	local playername = pizza.player_realname(cn)
	local result = db.select("nl_pizza_company_players", {"companyid"}, string.format("playername='%s'", db.escape(playername)))
	if result == nil or #result == 0 then
		-- messages.debug(-1, players.admins(), "PIZZA", string.format("get_company for %i: no company (-1)", cn))
		return -1
	else
		-- messages.debug(-1, players.admins(), "PIZZA", string.format("get_company for %i: %i", cn, result[1]["companyid"]))
		return tonumber(result[1]["companyid"])
	end
end

function pizza.get_other_companies(companyid)
	local result = db.select("nl_pizza_companies", {"companyid"}, string.format("companyid != %i", companyid))
	return result
end

function pizza.get_company_name(companyid)
	result = db.select("nl_pizza_companies", { "name" }, string.format("companyid=%i", companyid))
	if result == nil or #result == 0 then
		messages.debug(-1, players.admins(), "PIZZA", string.format("get_company_name: company %i does not exist (-1)", companyid))
		return -1
	else
		return result[1]["name"]
	end
end

function pizza.get_company_players(companyid)
	-- liefert die cns aller spieler zurueck, die zur eigenen Firma gehoeren
	local cns = {}
	for i,cn in ipairs(players.all()) do
		if pizza.get_company(cn) == companyid then
			table.insert(cns, cn)
		end
	end
	return cns
end

function pizza.get_other_players(companyid)
	-- liefert die cns aller spieler zurueck, die _nicht_ zur eigenen Firma gehoeren
	local cns = {}
	for i,cn in ipairs(players.all()) do
		if pizza.get_company(cn) ~= companyid then
			table.insert(cns, cn)
		end
	end
	return cns
end

function pizza.is_same_company(cn1, cn2)
	if pizza.get_company(cn1) == pizza.get_company(cn2) then
		return true
	else
		return false
	end
end

function pizza.get_last_created_order()
	local result = db.select("nl_pizza_orders", { "orderid", "playername", "timestamp", "deliveredbycompanyid" }, "orderid > 0", "timestamp desc") -- asc (aufsteigend = aeltester timestamp)
	if result == nil or #result == 0 then
		return nil
	else
		return result[1]
	end
end

function pizza.get_next_order(cn)
	-- liefert die älteste bestellung des spielers zurück.
	local playername = pizza.player_realname(cn)
	local result = db.select("nl_pizza_orders", { "orderid", "playername", "timestamp", "deliveredbycompanyid" }, string.format("playername='%s' and deliveredbycompanyid IS NULL", db.escape(playername)), "timestamp asc") -- asc (aufsteigend = aeltester timestamp)
	if result == nil or #result == 0 then
		messages.debug(-1, players.admins(), "PIZZA", string.format("get_next_order(%i): player %s does not have ordered a pizza", cn, server.player_name(cn)))
		return nil
	else
		return result[1]
	end
end

function pizza.get_all_orders()
	-- liefert alle bestellungen aller spieler, die online sind zurueck
	local orders = {}
	for i,cn in ipairs(players.all()) do
		local order = pizza.get_next_order(cn)
		if order ~= nil then
			table.insert(orders, order)
		end
	end
	return orders
end

function pizza.get_available_orders(companyid)
	-- liefert alle bestellungen zurueck, die _nicht_ von teilhabern der eigenen firma stammen
	local orders = {}
	for i,cn in ipairs(pizza.get_other_players(companyid)) do
		local order = pizza.get_next_order(cn)
		if order ~= nil then
			table.insert(orders, order)
		end
	end
	return orders
end

function pizza.set_order_delivered(orderid, companyid)
	-- den status der bestellung auf geliefert setzen, indem man die deliveredbycompanyid setzt
	-- und die zutaten der bestellung abziehen
	db.insert_or_update("nl_pizza_orders", { deliveredbycompanyid=companyid}, string.format("orderid=%i", orderid) )
	messages.debug(-1, players.admins(), "PIZZA", string.format("set_order_delivered(%i, %i): company %s has delivered the pizza %i.", orderid, companyid, pizza.get_company_name(companyid), orderid))
	local ingredients = pizza.get_order_ingredients(orderid)
	for i, ingredient in ipairs(ingredients) do
		local ingredientid = ingredient["ingredientid"]
		local amount_change = 0-pizza.get_ingredient_needed(ingredientid) -- minus-werte erzwingen
		pizza.add_company_ingredients_amount(companyid, ingredientid, amount_change)
		messages.debug(-1, players.admins(), "PIZZA", string.format("set_order_delivered(%i, %i): removed %i of ingredient %i.", orderid, companyid, amount_change, ingredientid))
	end
end

function pizza.get_order_ingredients(orderid)
	-- liefert die beläge einer pizza zurück
	return db.select("nl_pizza_order_ingredients", { "ingredientid" }, string.format("orderid=%i", orderid))
end

function pizza.get_order_price(orderid)
	local ingredients = pizza.get_order_ingredients(orderid)
	local totalprice = 0
	for i, ingredient in ipairs(ingredients) do
		local price = pizza.get_ingredient_price(ingredient["ingredientid"])
		totalprice = totalprice + price
	end
	messages.debug(-1, players.admins(), "PIZZA", string.format("get_order_price(%i): The total price for this order is %i", orderid, totalprice))
	return totalprice
end

function pizza.get_realprice(price100, age_in_seconds)
	-- gibt den reduzierten preis zurueck. die reduktion haengt davon ab, wie alt die bestellung ist
	-- hier wirds mathematisch :p
	local realprice = 0
	if age_in_seconds < pizza.realprice.min then
		-- innerhalb der ersten 5 minuten bleibt der preis gleich
		realprice = price100
	else
		if age_in_seconds > pizza.realprice.max then
			-- nach 5 tagen bleibt der preis stabil bei 50 prozent des urspruenglichen preises
			realprice = math.floor(price100 / pizza.realprice.factor)
		else
			-- lineare reduktion des preises zwischen den beiden grenzen um den angegebenen faktor
			realprice = price100 - math.floor( price100 * ( age_in_seconds / ( (pizza.realprice.max - pizza.realprice.min) * pizza.realprice.factor ) ) )
		end
	end
	messages.debug(-1, players.admins(), "PIZZA", string.format("get_realprice(%i, %i): The real price is %i", price100, age_in_seconds, realprice))
	return realprice
end

function pizza.get_order_age(orderid)
	-- liefert das alter einer bestellung in sekunden zurueck
	local orders = db.select("nl_pizza_orders", { "NOW()-timestamp as age" }, string.format("orderid=%i", orderid))
	if #orders == 0 then
		messages.debug(-1, players.admins(), "PIZZA", string.format("get_order_age(%i): Could not find order.", orderid))
		return -1
	else
		messages.debug(-1, players.admins(), "PIZZA", string.format("get_order_age(%i): The age of the order is %i", orderid, orders[1]["age"]))
		return tonumber(orders[1]["age"])
	end
end

function pizza.get_order_age_string(age_in_seconds)
	local the_string = ""
	if age_in_seconds > 86400 then
		the_string = string.format("%i days", math.floor(age_in_seconds / 86400))
	else
		if age_in_seconds > 3600 then
			the_string = string.format("%i hours", math.floor(age_in_seconds / 3600))
		else
			the_string = string.format("%i minutes", math.floor(age_in_seconds / 60))
		end
	end
	messages.debug(-1, players.admins(), "PIZZA", string.format("get_order_age_string(%i): The string representation is %s", age_in_seconds, the_string))
	return the_string
end

function pizza.get_company_ingredients(companyid)
	-- liefert die zutaten einer firma zurück
	return db.select("nl_pizza_company_ingredients", { "ingredientid", "amount" }, string.format("companyid=%i", companyid))
end

function pizza.get_company_ingredients_amount(companyid, ingredientid)
	result = db.select("nl_pizza_company_ingredients", { "amount" }, string.format("companyid=%i and ingredientid=%i", companyid, ingredientid))
	if result == nil or #result == 0 then
		return 0
	else
		local amount = result[1]["amount"]
		messages.debug(-1, players.admins(), "PIZZA", string.format("get_company_ingredients_amount(%i, %i): The amount is %i", companyid, ingredientid, amount))
		return amount
	end
end

function pizza.get_ingredients_string(orderid)
	-- liefert einen string mit den belägen einer pizza zurück
	local ingredients_string = ""
	local ingredients = pizza.get_order_ingredients(orderid)
	for i,ingredient in ipairs(ingredients) do
		if i == 1 then
			ingredients_string = pizza.get_ingredient_name(ingredient["ingredientid"])
		else
			ingredients_string = string.format("%s, %s", ingredients_string, pizza.get_ingredient_name(ingredient["ingredientid"]))
		end
	end
	messages.debug(-1, players.admins(), "PIZZA", string.format("get_ingredients_string(%i): The string representation of the order is %s", orderid, ingredients_string))
	return ingredients_string
end

function pizza.get_ingredient_id(name)
	result = db.select("nl_pizza_ingredients", { "ingredientid" }, string.format("name='%s'", db.escape(name)))
	if result == nil or #result == 0 then
		messages.debug(-1, players.admins(), "PIZZA", string.format("get_ingredient_id(%s): The ingedient could not be found.", name))
		return "ingredientidNotFound"
	else
		return result[1]["ingredientid"]
	end
end

function pizza.get_ingredient_name(ingredientid)
	result = db.select("nl_pizza_ingredients", { "name" }, string.format("ingredientid=%i", ingredientid))
	if result == nil or #result == 0 then
		messages.debug(-1, players.admins(), "PIZZA", string.format("get_ingredient_name(%i): The ingedient could not be found.", ingredientid))
		return "ingredientidNotFound"
	else
		return result[1]["name"]
	end
end

function pizza.get_ingredient_needed(ingredientid)
	result = db.select("nl_pizza_ingredients", { "decreasebyorder" }, string.format("ingredientid=%i", ingredientid))
	if result == nil or #result == 0 then
		messages.debug(-1, players.admins(), "PIZZA", string.format("get_ingredient_needed(%i): The ingedient could not be found.", ingredientid))
		return 0
	else
		return result[1]["decreasebyorder"]
	end
end

function pizza.get_ingredient_price(ingredientid)
	result = db.select("nl_pizza_ingredients", { "price" }, string.format("ingredientid=%i", ingredientid))
	if result == nil or #result == 0 then
		messages.debug(-1, players.admins(), "PIZZA", string.format("get_ingredient_price(%i): The ingedient could not be found.", ingredientid))
		return 0
	else
		return result[1]["price"]
	end
end

function pizza.check_ingredients_exists(cn, ingredients)
	for i,ingredient_name in ipairs(ingredients) do
		result = db.select("nl_pizza_ingredients", { "ingredientid" }, string.format("name='%s'", db.escape(ingredient_name)))
		if result == nil or #result == 0 then
			messages.warning(-1, {cn}, "PIZZA", string.format("%s is not a known ingredient. Order was aborted!", ingredient_name))
			return false
		end
	end
	return true
end

function pizza.get_all_ingredients()
	-- liefert alle zutaten zurück
	return db.select("nl_pizza_ingredients", { "ingredientid", "name", "price" })
end

function pizza.get_all_companies()
	-- liefert alle firmen zurück
	return db.select("nl_pizza_companies", { "companyid", "name" })
end

function pizza.company_change_money(companyid, money_change)
	if companyid > 0 then
		local result = db.select("nl_pizza_companies", { "money" }, string.format("companyid=%i", companyid) )
		local new_money = result[1]["money"] + money_change
		db.update("nl_pizza_companies", { money=new_money}, string.format("companyid=%i", companyid) )
	end
end

function pizza.player_realname(cn)
	return tostring(nl.getPlayer(cn, "statsname"))
end

function pizza.player_registered(cn)
	if server.access(cn) >= user_access then
		local playername = pizza.player_realname(cn)
		local result = db.select("nl_pizza_players", { "playername" }, string.format("playername='%s'", db.escape(playername)) )
		if result == nil or #result == 0 then
			db.insert("nl_pizza_players", { playername=db.escape(playername), money=0, blockedmoney=0 } )
		end
		return true
	else
		return false
	end
end

function pizza.get_player_money(playername)
	local result = db.select("nl_pizza_players", { "money" }, string.format("playername='%s'", db.escape(playername)) )
	if result == nil or #result == 0 then
		return 0
	else
		return result[1]["money"]
	end
end

function pizza.get_player_blockedmoney(playername)
	local result = db.select("nl_pizza_players", { "blockedmoney" }, string.format("playername='%s'", db.escape(playername)) )
	if result == nil or #result == 0 then
		return 0
	else
		return result[1]["blockedmoney"]
	end
end

function pizza.get_player_savings(playername)
	local result = db.select("nl_pizza_players", { "savings" }, string.format("playername='%s'", db.escape(playername)) )
	if result == nil or #result == 0 then
		return 0
	else
		return result[1]["savings"]
	end
end

function pizza.player_change_money(cn, money_change)
	if pizza.player_registered(cn) then
		local playername = pizza.player_realname(cn)
		local money = pizza.get_player_money(playername)
		local new_money = money + money_change
		db.update("nl_pizza_players", { money=new_money }, string.format("playername='%s'", db.escape(playername)) )
	end
end

function pizza.player_change_blockedmoney(cn, money_change)
	if pizza.player_registered(cn) then
		local playername = pizza.player_realname(cn)
		local blockedmoney = pizza.get_player_blockedmoney(playername)
		local new_money = blockedmoney + money_change
		db.update("nl_pizza_players", { blockedmoney=new_money }, string.format("playername='%s'", db.escape(playername)) )
	end
end

function pizza.player_change_savings(cn, savings_change)
	if pizza.player_registered(cn) then
		local playername = pizza.player_realname(cn)
		local savings = pizza.get_player_savings(playername)
		local new_savings = savings + savings_change
		db.update("nl_pizza_players", { savings=new_savings }, string.format("playername='%s'", db.escape(playername)) )
	end
end

function pizza.check_player_finances(cn, ingredients)
	local playername = pizza.player_realname(cn)
	local totalprice = 0
	for i, ingredient_name in ipairs(ingredients) do
		if ingredient_name ~= nil and ingredient_name ~= "" then
			--messages.debug(-1, players.admins(), "PIZZA", string.format("check_player_finances(%i, ...): %s", cn, ingredient_name))
			-- messages.debug(-1, players.admins(), "PIZZA", pizza.ingredientid[ingredient_name])
			local price = pizza.get_ingredient_price(pizza.get_ingredient_id(ingredient_name))
			totalprice = totalprice + price
		end
	end
	local available_money = pizza.get_player_money(playername) - pizza.get_player_blockedmoney(playername)
	if totalprice > available_money then
		messages.warning(-1, {cn}, "PIZZA", string.format("You don't have enough money to order this pizza (%i Lire needed / %i Lire available)", totalprice, available_money))
		return false
	else
		return true
	end
end

function pizza.set_company_ingredients_amount(companyid, ingredientid, amount)
	if companyid > 0 then
		db.insert_or_update("nl_pizza_company_ingredients", { companyid=companyid, ingredientid=ingredientid, amount=amount}, string.format("companyid=%i and ingredientid=%i", companyid, ingredientid) )
	end 
end

function pizza.add_company_ingredients_amount(companyid, ingredientid, amount_change)
	if companyid > 0 then
		messages.debug(-1, players.admins(), "PIZZA", string.format("pizza.add_company_ingredients_amount: company %s ingredientid %i addAmount %i", companyid, ingredientid, amount_change))
		local result = db.select("nl_pizza_company_ingredients", { "amount" }, string.format("companyid=%i and ingredientid=%i", companyid, ingredientid) )
		local new_amount = 0
		if #result > 0 then
			new_amount = result[1]["amount"] + amount_change
		else
			new_amount = amount_change
		end
		pizza.set_company_ingredients_amount(companyid, ingredientid, new_amount)
	end
end

function pizza.personal_status(cn)
	local playername = pizza.player_realname(cn)
	local money = pizza.get_player_money(playername)
	local blockedmoney = pizza.get_player_blockedmoney(playername)
	local availablemoney = money - blockedmoney
	messages.info(-1, {cn}, "PIZZA", string.format("You own orange<%i Lire> (green<%i Lire available>, red<%i Lire blocked>)", money, availablemoney, blockedmoney))
end

function pizza.list_onstock(cn)
	local ingredients_on_stock = pizza.get_company_ingredients(pizza.get_company(cn))
	messages.info(-1, {cn}, "PIZZA", "green<Your company's stock:>")
	for i, ingredient in ipairs(ingredients_on_stock) do
		messages.info(-1, {cn}, "PIZZA", string.format("orange<%s> (Amount: green<%i>)", pizza.get_ingredient_name(ingredient["ingredientid"]), ingredient["amount"]))
	end
end

function pizza.list_prices(cn)
	local ingredients = pizza.get_all_ingredients()
	messages.info(-1, {cn}, "PIZZA", "green<Market prices:>")
	for i, ingredient in ipairs(ingredients) do
		messages.info(-1, {cn}, "PIZZA", string.format("orange<%s> (green<%i> Lire)", ingredient["name"], ingredient["price"]))
	end
end

function pizza.list_orders(cn)
	local available_orders = pizza.get_available_orders(pizza.get_company(cn))
	messages.info(-1, {cn}, "PIZZA", "green<Orders from players that are currently online:>")
	for i, order in ipairs(available_orders) do
		messages.info(-1, {cn}, "ORDERS", string.format("Pizza for green<%s>: orange<%s>", order["playername"], pizza.get_ingredients_string(order["orderid"])))
	end
end

function pizza.create_order(cn, ingredients)
	-- Bestellung erzeugen
	local playername = pizza.player_realname(cn)
	db.insert("nl_pizza_orders", { playername=playername })
	local last_created_order = pizza.get_last_created_order()
	local orderid = last_created_order["orderid"]
	messages.debug(-1, {cn}, "PIZZA", string.format("create_order(%i, ...): Order %i created.", cn, orderid))
	for i,ingredient_name in ipairs(ingredients) do
		db.insert("nl_pizza_order_ingredients", { orderid=orderid, ingredientid=pizza.get_ingredient_id(ingredient_name) })
	end
	local price100 = pizza.get_order_price(orderid)
	pizza.player_change_blockedmoney(cn, price100)
	messages.info(-1, {cn}, "PIZZA", "green<Your pizza order has been accepted!>")
end

function pizza.ordering(cn, ingredients)
	-- Bestellung einleiten, Basiszutaten und Finanzen ueberpruefen, dann Bestellung erzeugen
	table.insert(ingredients, "flour")
	table.insert(ingredients, "tomato")
	table.insert(ingredients, "cheese")
	if pizza.check_ingredients_exists(cn, ingredients) and pizza.check_player_finances(cn, ingredients) then
		pizza.create_order(cn, ingredients)
	end
end

function pizza.is_order_deliverable(cn, companyid, orderid)
	-- prueft, ob eine firma eine pizza liefern kann (also genuegend zutaten hat)
	local ingredients = pizza.get_order_ingredients(orderid)
	for i, ingredient in ipairs(ingredients) do
		local needed_amount = pizza.get_ingredient_needed(ingredient["ingredientid"])
		local available_amount = pizza.get_company_ingredients_amount(companyid, ingredient["ingredientid"])
		if tonumber(available_amount) < tonumber(needed_amount) then
			messages.warning(-1, {cn}, "PIZZA", string.format("yellow<Your company doesn't have enough> orange<%s> yellow<to deliver this pizza (>red<%i> yellow<needed /> red<%i> yellow<available)>", pizza.get_ingredient_name(ingredient["ingredientid"]), needed_amount, available_amount))
			return false
		end
	end
	return true
end

function pizza.deliver(cn, targetCN)
	-- pizza liefern
	if targetCN == nil then
		messages.error(-1, {cn}, "PIZZA", "orange<#pizza deliver cn> --- red<You have to specify the target player's client number (cn).>")
		return -1
	end
	if pizza.is_same_company(cn, targetCN) then
		messages.error(-1, {cn}, "PIZZA", "red<You can't deliver pizza's to staff of your own company!>")
	else
		local order = pizza.get_next_order(targetCN)
		if order ~= nil then
			local orderid = order["orderid"]
			local companyid = pizza.get_company(cn)
			if pizza.is_order_deliverable(cn, companyid, orderid) then
				local order_age = pizza.get_order_age(orderid)
				local order_age_string = pizza.get_order_age_string(order_age)
				local price100 = pizza.get_order_price(orderid)
				local real_price = pizza.get_realprice(price100, order_age)
				local savings = price100 - real_price
				local savings_percent = math.floor(price100 / 100 * savings)
				local player_provision = math.floor(real_price / 10)
				local company_earnings = real_price - player_provision

				pizza.player_change_money(targetCN, 0-real_price)
				pizza.player_change_blockedmoney(targetCN, 0-price100)
				pizza.player_change_savings(targetCN, savings)
				pizza.company_change_money(companyid, company_earnings)
				pizza.player_change_money(cn, player_provision)
				pizza.set_order_delivered(orderid, companyid)

				messages.info(-1, {cn}, "PIZZA", string.format("The pizza was delivered within %s. You have earned %s Lire. Your company earned %s Lire.", order_age_string, player_provision, company_earnings))
				messages.info(-1, {targetCN}, "PIZZA", string.format("Company %s delivered your pizza within %s. The price was %i Lire. You saved %i Lire (%i Percent).", pizza.get_company_name(companyid), order_age_string, real_price, savings, savings_percent))
			end
		else
			messages.warning(-1, {cn}, "PIZZA", "You can't deliver to this player (no orders)")
		end
	end
end

function pizza.usage(cn)
	messages.info(-1, {cn}, "PIZZA", string.format("red<#pizza status> --- green<Your personal money.>"))
	messages.info(-1, {cn}, "PIZZA", string.format("red<#pizza onstock> --- green<Lists ingredients your company's on stock>"))
	messages.info(-1, {cn}, "PIZZA", string.format("red<#pizza prices> --- green<Lists the ingredients and their prices>"))
	messages.info(-1, {cn}, "PIZZA", string.format("red<#pizza orders> --- green<Lists the orders from current online players>"))
	messages.info(-1, {cn}, "PIZZA", string.format("red<#pizza order ingredient1 ... ingredient_n> --- green<Order a pizza with given ingredients>"))
	messages.info(-1, {cn}, "PIZZA", string.format("red<#pizza deliver cn> --- green<Deliver the pizza to the player with given client number>"))
end



--[[
		COMMANDS
]]

function server.playercmd_pizza(cn, command, ...)
	if pizza.running == false then
		messages.error(-1, {cn}, "PIZZA", string.format("red<The pizza game is currently disabled.>"))
		return
	else
		if command ~= nil then
			if command == "status" then
				pizza.personal_status(cn)
			elseif command == "onstock" then
				pizza.list_onstock(cn)
			elseif command == "prices" then
				pizza.list_prices(cn)
			elseif command == "orders" then
				pizza.list_orders(cn)
			elseif command == "order" then
				pizza.ordering(cn, arg)
			elseif command == "deliver" then
				pizza.deliver(cn, arg[1])
			elseif command == "start" then
				if not hasaccess(cn, admin_access) then return end
				pizza.running = true
			elseif command == "stop" then
				if not hasaccess(cn, admin_access) then return end
				pizza.running = false
			else
				pizza.usage(cn)
			end
		else
			pizza.usage(cn)
		end
	end
end



--[[
		EVENTS
]]

server.event_handler("mapchange", function()
	pizza.running = pizza.is_game_running()
	pizza.moves.done = {}
end)

server.event_handler("scoreflag", function(cn)
	if pizza.running == false then return end
	pizza.add_company_ingredients_amount(pizza.get_company(cn), pizza.get_ingredient_id("cheese"), pizza.earning.cheese.amountscore)
end)

server.event_handler("frag", function(targetCN, cn)
	if pizza.running == false then return end
	cheater.respawn.lastdeath[targetCN] = server.gamemillis
	pizza.add_company_ingredients_amount(pizza.get_company(cn), pizza.get_ingredient_id("flour"), pizza.earning.flour.amount)
	pizza.add_company_ingredients_amount(pizza.get_company(targetCN), pizza.get_ingredient_id("flour"), pizza.earning.flour.gotfraggedamount)
end)

server.event_handler("teamkill", function(cn, victim)
	if pizza.running == false then return end
	pizza.add_company_ingredients_amount(pizza.get_company(cn), pizza.get_ingredient_id("tomato"), pizza.earning.tomato.teamkillamount)
end)

server.event_handler("takeflag", function(cn)
	if pizza.running == false then return end
	pizza.takeflag[cn] = server.gamemillis
	if server.player_team(cn) == "good" then
		cheater.fastscores.good.takeflagmillis = server.gamemillis
	elseif server.player_team(cn) == "evil" then
		cheater.fastscores.evil.takeflagmillis = server.gamemillis
	end
end)

server.event_handler("resetflag", function(cn)
	if pizza.running == false then return end
	if cn ~= nil and utils.is_numeric(cn) then
		pizza.add_company_ingredients_amount(pizza.get_company(cn), pizza.get_ingredient_id("flour"), pizza.earning.flour.flagresetamount)
	end
end)

server.event_handler("dropflag", function(cn)
	if pizza.running == false then return end
	local companyid = pizza.get_company(cn)
	local amount = math.floor((server.gamemillis - pizza.takeflag[cn]) / pizza.earning.cheese.millis * pizza.earning.cheese.amount)
	pizza.add_company_ingredients_amount(companyid, pizza.get_ingredient_id("cheese"), amount)
end)

server.event_handler("connect", function(cn)
	if pizza.running == false then return end
	pizza.playtime[cn] = 0
	pizza.company_id[cn] = pizza.get_company(cn)
end)

server.event_handler("disconnect", function(cn)
	if pizza.running == false then return end
	pizza.company_id[cn] = -1
	pizza.playtime[cn] = -1
end)

server.event_handler("move", function(cn, move, timeleft)
	if pizza.running == false then return end
	local moveid = move["moveid"]
	local companyid = pizza.get_company(cn)
	if companyid > 0 then
		if pizza.moves.done[cn] == nil then
			pizza.moves.done[cn] = {}
		end
		if pizza.moves.done[cn][moveid] == nil then
			local result = db.select("nl_pizza_move_ingredient", { "ingredientid", "amount" }, string.format("moveid=%i",moveid))
			if #result > 0 then
				for i, item in ipairs(result) do
					-- die zutaten bekommt die firma
					pizza.add_company_ingredients_amount(companyid, item["ingredientid"], item["amount"])
					-- die firma zahlt geld dafuer (Preis)
				end
			end
			pizza.moves.done[cn][moveid] = true
		end
	end
end)

-- Tomaten verdienen
server.interval(pizza.earning.tomato.millis, function()
	if pizza.running == false then return end
	for i,cn in ipairs(players.all()) do
		if server.player_status(cn) ~= "spectator" and server.player_status_code(cn) == server.ALIVE and server.access(cn) >= user_access then
			messages.debug(-1, players.admins(), "PIZZA", string.format("name:%s ingredientid:%i amount:%i", server.player_name(cn), pizza.get_ingredient_id("tomato"), pizza.earning.tomato.amount))
			pizza.add_company_ingredients_amount(pizza.get_company(cn), pizza.get_ingredient_id("tomato"), pizza.earning.tomato.amount)
		end
	end
end)

-- Geld verdienen durch spielen
-- Nur registrierte Spieler verdienen Geld!
server.interval(pizza.earning.lire.millis, function()
	if pizza.running == false then return end
	for i,cn in ipairs(players.all()) do
		if server.player_status(cn) ~= "spectator" and server.player_status_code(cn) == server.ALIVE and server.access(cn) >= user_access then
			pizza.playtime[cn] = pizza.playtime[cn] + pizza.earning.lire.millis
			if pizza.playtime[cn] > pizza.earning.lire.minplaytime then
				local playername = pizza.player_realname(cn)
				local companyid = pizza.get_company(cn)
				local unblocked_money = pizza.get_player_money(playername) - pizza.get_player_blockedmoney(playername)
				if unblocked_money > pizza.earning.max_unblocked and companyid > -1 then
					local other_companies = pizza.get_other_companies(companyid)
					for i,other_company in ipairs(other_companies) do
						pizza.company_change_money(tonumber(other_company["companyid"]), pizza.earning.lire.amount)
					end
					messages.warning(-1, {cn}, "PIZZA", string.format("You donated your earnings to the other companies because your pocket is full (%i Lire available). The other companies are very thankful! Order pizzas now.", unblocked_money))
				else
					pizza.player_change_money(cn, pizza.earning.lire.amount)
					messages.debug(-1, players.admins(), "PIZZA", string.format("%s has earned %i Lire", server.player_name(cn), pizza.earning.lire.amount))
				end
			end
		end
	end
end)

-- Zutaten vergammeln
server.interval(pizza.runsoutofseed.time, function()
	if pizza.running == false then return end
	local companies = pizza.get_all_companies()
	for i,company in ipairs(companies) do
		local ingredients = pizza.get_company_ingredients(company["companyid"])
		for i,ingredient in ipairs(ingredients) do
			local new_amount = ingredient["amount"] - math.floor(ingredient["amount"] / pizza.runsoutofseed.divisor)
			db.insert_or_update("nl_pizza_company_ingredients", { amount=new_amount}, string.format("companyid=%i and ingredientid=%i", company["companyid"], ingredient["ingredientid"]) ) 
			messages.debug(-1, players.admins(), "PIZZA", string.format("%s's %s run to seed (%i -> %i)", company["name"], pizza.get_ingredient_name(ingredient["ingredientid"]), ingredient["amount"], new_amount))
		end
	end
end)

