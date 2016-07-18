//////////////////////////////////////////// Setup //////////////////////////////////////////////////

/mob/proc/make_merchant()
	if (ishuman(src))
		var/datum/abilityHolder/merchant/A = src.get_ability_holder(/datum/abilityHolder/merchant)
		if (A && istype(A))
			return
		var/datum/abilityHolder/merchant/W = src.add_ability_holder(/datum/abilityHolder/merchant)
		W.addAbility(/datum/targetable/merchant/summon_contract)
		if (src.mind)
			if (!isdiabolical(src))
				src.mind.diabolical = 1
			else
				return
		
	else return

//////////////////////////////////////////// Ability holder /////////////////////////////////////////
/obj/screen/ability/merchant
	clicked(params)
		var/datum/targetable/merchant/spell = owner
		var/datum/abilityHolder/holder = owner.holder
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span style=\"color:red\">You can't use this ability here.</span>")
			return
		if (spell.targeted && usr:targeting_spell == owner)
			usr:targeting_spell = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_spell = owner
			owner.holder.owner.update_cursor()
		else
			spawn
				spell.handleCast()
		return


/datum/abilityHolder/merchant
	usesPoints = 0
	regenRate = 0
	tabName = "Souls"
	notEnoughPointsMessage = "<span style=\"color:red\">You need more souls to use this ability!</span>"

	onAbilityStat() // In the "Souls" tab.
		..()
		stat("Total number of souls collected:", total_souls_sold)
		stat("Number of unspent souls:", total_souls_value)
		return

/////////////////////////////////////////////// Merchant spell parent ////////////////////////////

/datum/targetable/merchant
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/merchant
	var/when_stunned = 1 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0

	New()
		var/obj/screen/ability/merchant/B = new /obj/screen/ability/merchant(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /obj/screen/ability/merchant()
			object.icon = src.icon
			object.owner = src
		if (src.last_cast > world.time)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state
		return

	proc/incapacitation_check(var/stunned_only_is_okay = 0)
		if (!holder)
			return 0

		var/mob/living/M = holder.owner
		if (!M || !ismob(M))
			return 0

		switch (stunned_only_is_okay)
			if (0)
				if (M.stat != 0 || M.stunned > 0 || M.paralysis > 0 || M.weakened > 0)
					return 0
				else
					return 1
			if (1)
				if (M.stat != 0 || M.paralysis > 0)
					return 0
				else
					return 1
			else
				return 1

	castcheck()
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M)
			return 0

		if (!(ishuman(M) || iscritter(M)))
			boutput(M, __red("You cannot use any powers in your current form."))
			return 0

		if (M.transforming)
			boutput(M, __red("You can't use any powers right now."))
			return 0

		if (incapacitation_check(src.when_stunned) != 1)
			boutput(M, __red("You can't use this ability while incapacitated!"))
			return 0

		if (src.not_when_handcuffed == 1 && M.restrained())
			boutput(M, __red("You can't use this ability when restrained!"))
			return 0
		
		if (!(isdiabolical(M)))
			boutput(M, __red("You aren't evil enough to use this power!"))
			boutput(M, __red("Also, you should probably contact a coder because something has gone horribly wrong."))
			return 0
		
		if (!(total_souls_value >= 5))
			boutput(M, __red("You don't have enough souls in your satanic bank account to buy another contract!"))
			boutput(M, __red("You need [5 - total_souls_value] more to afford a contract!"))
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/////////////////////////////////////////////// Contract Summoning Spell ////////////////////////////

/datum/targetable/merchant/summon_contract
	icon_state = "clairvoyance"
	name = "Summon Contract"
	desc = "Spend five souls to summon a random new contract to your location"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	
	cast(mob/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner
		var/datum/abilityHolder/merchant/H = holder
		if (!M)
			return 1
		if (!(total_souls_value >= 5))
			boutput(M, __red("You don't have enough souls in your satanic bank account to buy another contract!"))
			boutput(M, __red("You need [5 - total_souls_value] more to afford a contract!"))
			return 1
		if (!isdiabolical(M))
			boutput(M, __red("You aren't evil enough to use this power!"))
			boutput(M, __red("Also, you should probably contact a coder because something has gone horribly wrong."))
			return 1
		total_souls_value -= 5
		boutput(M, __red("You spend five souls and summon a brand new contract along with a pen! However, losing the power of those souls has weakened your weapons."))
		spawncontract(M, 1, 1) //strong contract + pen
		return 0
