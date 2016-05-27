//TODO: make dedicated procs for all contracts, use blood drawing with pen to forcibly sign things, finish horse contract, make minor contracts
/mob/proc/make_shitty_vampire()
	if (ishuman(src) || iscritter(src))
		if (ishuman(src))
			var/datum/abilityHolder/vampire/A = src.get_ability_holder(/datum/abilityHolder/vampire)
			if (A && istype(A))
				return

			var/datum/abilityHolder/vampire/V = src.add_ability_holder(/datum/abilityHolder/vampire)
			V.addAbility(/datum/targetable/vampire/blood_tracking) //no spells, HAHAHA!

			if (src.mind)
				src.mind.is_vampire = V

			spawn (25) // Don't remove.
				if (src) src.assign_gimmick_skull()

		else if (iscritter(src)) // For testing. Just give them all abilities that are compatible.
			var/mob/living/critter/C = src

			if (isnull(C.abilityHolder)) // They do have a critter AH by default...or should.
				var/datum/abilityHolder/vampire/A2 = C.add_ability_holder(/datum/abilityHolder/vampire)
				if (!A2 || !istype(A2, /datum/abilityHolder/))
					return

			C.abilityHolder.addAbility(/datum/targetable/vampire/cancel_stuns/mk2)
			C.abilityHolder.addAbility(/datum/targetable/vampire/glare)
			C.abilityHolder.addAbility(/datum/targetable/vampire/hypnotize)
			C.abilityHolder.addAbility(/datum/targetable/vampire/plague_touch)
			C.abilityHolder.addAbility(/datum/targetable/vampire/phaseshift_vampire)
			C.abilityHolder.addAbility(/datum/targetable/vampire/call_bats)
			C.abilityHolder.addAbility(/datum/targetable/vampire/vampire_scream)
			C.abilityHolder.addAbility(/datum/targetable/vampire/enthrall)

			if (C.mind)
				C.mind.is_vampire = C.abilityHolder

		if (src.mind && src.mind.special_role != "omnitraitor")
			src << browse(grabResource("html/traitorTips/vampireTips.html"),"window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0")
			boutput(src, "<span style=\"color:blue\">Oh shit, your fangs just broke off! Looks like you'll have to get blood the HARD way.</span>")

	else return


mob/living/carbon/human/proc/horse()
	var/mob/living/carbon/human/H = src

	if(H.mind && (H.mind.assigned_role != "Horse") || (!H.mind || !H.client)) //I am shamelessly copying this from the wizard cluwne spell
		boutput(H, "<span style=\"color:red\"><B>You NEIGH painfully!</B></span>")
		//H.take_brain_damage(80) uncomment if horses are really dumb
		H.stuttering = 120
		if(H.mind)
			H.mind.assigned_role = "Horse"
		//H.contract_disease(/datum/ailment/disability/clumsy,null,null,1) uncomment if horses are really clumsy
		//H.contract_disease(/datum/ailment/disease/cluwneing_around,null,null,1)  uncomment if horses are clowns (they aren't)
		playsound(get_turf(H), pick("sound/voice/cluwnelaugh1.ogg","sound/voice/cluwnelaugh2.ogg","sound/voice/cluwnelaugh3.ogg"), 100, 0, 0, max(0.7, min(1.4, 1.0 + (30 - H.bioHolder.age)/50)))
		H.nutrition = 9000
		H.change_misstep_chance(66)
		animate_clownspell(H)
		//H.unequip_all()
		H.drop_from_slot(H.wear_suit)
		//H.drop_from_slot(H.shoes)
		H.drop_from_slot(H.wear_mask)
		//H.drop_from_slot(H.gloves)
		H.equip_if_possible(new /obj/item/clothing/suit/cultist/cursed(H), H.slot_wear_suit)
		//H.equip_if_possible(new /obj/item/clothing/shoes/cursedclown_shoes(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/mask/horse_mask/cursed(H), H.slot_wear_mask)
		//H.equip_if_possible(new /obj/item/clothing/gloves/cursedclown_gloves(H), H.slot_gloves)
		H.real_name = "HORSE"

/proc/neigh(var/string) //This is it. This is the lowest point in my life.
	var/modded = ""
	var/list/text_tokens = dd_text2List(string, " ")
	for(var/token in text_tokens)
		modded += "NEIGH "
	modded += "NEIGH!"
	if(prob(15))
		modded += " - NEEEEEEIIIIGH!!!"

	return modded

/mob/proc/sellsoul()
	if (src.mind)
		if (src.mind.diabolical == 1)
			boutput(src, "<span style=\"color:blue\">You can't sell a soul to yourself!</span>")
			return
		else if (src.mind.sold_soul == 1) //even though this check is already in the individual contracts, it's good to take precautions
			boutput(src, "<span style=\"color:blue\">You don't have a soul to sell!</span>") //after all
			return //this is byond we're talking about here
		else if ((src.mind.sold_soul == 0))
			src.mind.sold_soul = 1
			total_souls_sold++
			if (src.mind.assigned_role == "Head of Security" || src.mind.assigned_role == "Security Officer")
				total_souls_value += 2 //security jobs are worth more, because they presumably have a more virtuous soul (pffft)
			else
				total_souls_value++
		else
			boutput(src, "<span style=\"color:blue\">Something has gone horribly wrong with your soul! Report this to the nearest coder as soon as possible!</span>") //oh god, you've got like half a soul, how does that even WORK?
			return
	else
		return

/mob/proc/makesuperyeti() //this is my magnum opus
	new /obj/critter/yeti/super(src.loc)
	src.partygib() //it brings a tear to my eye

/mob/proc/shittymachoize()
	if (src.mind || src.client)
		message_admins("[key_name(src)] has been made a faustian macho man.")
		logTheThing("admin", null, src, "%target% has been made a faustian macho man.")
		var/mob/living/carbon/human/machoman/W = new/mob/living/carbon/human/machoman(src)

		var/turf/T = get_turf(src)
		if (!(T && isturf(T)) || (isrestrictedz(T.z) && !(src.client && src.client.holder)))
			var/ASLoc = pick(latejoin)
			if (ASLoc)
				W.set_loc(ASLoc)
			else
				W.set_loc(locate(1, 1, 1))
		else
			W.set_loc(T)

		if (src.mind)
			src.mind.transfer_to(W)
			W.mind.special_role = "faustian macho man"
			ticker.mode.Agimmicks.Add(W)
		else
			var/key = src.client.key
			if (src.client)
				src.client.mob = W
			W.mind = new /datum/mind()
			ticker.minds += W.mind
			W.mind.key = key
			W.mind.current = W
		qdel(src)

		spawn (25) // Don't remove.
			if (W) W.assign_gimmick_skull()
		spawn (5)
			if (W)
				W.traitHolder.addTrait("deathwish") //evil
				W.traitHolder.addTrait("glasscannon") //what good will those stimulants do you now?
			if (W)
				for(var/mob/living/carbon/human/machoman/verb/V in W)
					W.verbs -= V //this is just diabolical
					W.reagents.add_reagent("anti_fart", 800) //as is this

		boutput(W, "<span style=\"color:blue\">You are now a miserable mockery of the true macho man! Take out your envy upon the station!</span>")
		
		

		return W
	return 0

/mob/proc/satanclownize()
	src.transforming = 1
	src.canmove = 0
	src.invisibility = 101
	for(var/obj/item/clothing/Q in src)
		src.u_equip(Q)
		if (Q)
			Q.set_loc(src.loc)
			Q.dropped(src)
			Q.layer = initial(Q.layer)

	var/mob/living/carbon/human/cluwne/satan/C = new(src.loc)
	if(src.mind)
		src.mind.transfer_to(C)
	else
		C.key = src.key

	var/acount = 0 //borrowing this from his grace
	var/amax = rand(10,15)
	var/screamstring = null
	var/asize = 1
	while(acount <= amax)
		screamstring += "<font size=[asize]>a</font>"
		if(acount > (amax/2))
			asize--
		else
			asize++
		acount++
	src.playsound_local(C.loc,"sound/effects/screech.ogg", 100, 1)
	if(C.mind)	
		shake_camera(C, 20, 1)
		boutput(C, "<font color=red>[screamstring]</font>")
		boutput(C, "<i><b><font face = Tempus Sans ITC>You have sold your soul and become an avatar of evil! Spread darkness across the land!</font></b></i>")
		C.mind.special_role = "Faustian Cluwne"
		logTheThing("admin", src, null, "has transformed into a demonic cluwne at [log_loc(C)]!")
		ticker.mode.Agimmicks.Add(C)
		C.choose_name(3)
	else
		return
		
	spawn(10)
		qdel(src)

/obj/item/pen/fancy/satan
	name = "infernal pen"
	desc = "A pen once owned by Old Nick himself. About as sharp as the Devil's wit."
	force = 15
	throwforce = 15
	hit_type = DAMAGE_STAB
	color = "#FF0000"
	font_color = "#FF0000"

/obj/item/storage/box/evil // the one you get in your backpack
	name = "box of infernal pens"
	desc = "Contains a set of seven pens, great for collectors."
	spawn_contents = list(/obj/item/pen/fancy/satan = 7)
	
/obj/item/paper/soul_selling_kit
	name = "Paper-'Instructions'"
	info = {"<center><b>SO YOU WANT TO STEAL SOULS?</b></center><ul>
			<li>Step One: Grab a complimentary pen and your contract of choice.</li>
			<li>Step Two: Present your contract to your victim by clicking on them with said contract, but be sure you have your hellish writing utensil handy in your other hand!</li>
			<li>Step Three: It takes about fifteen seconds for you to force your victim to sign their name, be sure not to move during this process or the ink will smear!</li></ul>
			<b>Alternatively, you can just have people sign the contract willingly, but where's the fun in that?</b>"}


/obj/item/storage/briefcase/satan
	name = "devilish briefcase"
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH
	color = "#FF0000" //look, I can't sprite for shit, so I'm just making all these things satan red. It worked for toolboxes!
	force = 15
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_wclass = 3
	desc = "A diabolical human leather-bound briefcase, capable of holding a number of small objects and tormented souls. All those tormented souls really weigh it down."
	stamina_damage = 90 //is this a bad idea?
	stamina_cost = 30
	stamina_crit_chance = 45 //yes, yes it is.
	spawn_contents = list(/obj/item/contract/satan, /obj/item/storage/box/evil, /obj/item/clothing/under/misc/lawyer/red = 3)
	
	make_my_stuff() //hijacking this from space loot secure safes
		..()
		if (prob(1)) //gotta be rare enough for it to not get stale
			new /obj/item/contract/horse(src) //can't have it in normal loot pool
		else
			var/loot = rand(1,3) // TODO: add more
			switch (loot)
				if (1)
					new /obj/item/contract/yeti(src)
				if (2)
					new /obj/item/contract/genetic(src)
				if (3)
					new /obj/item/contract/mummy(src)
				if (4)
					new /obj/item/contract/vampire(src)
				if (5)
					new /obj/item/contract/fart(src)
				if (6)
					new /obj/item/contract/hair(src)
				if (7)
					new /obj/item/contract/wrestle(src)
				if (8)
					new /obj/item/contract/macho(src)

/obj/item/contract  //TODONE: make a way for contracts to be signed non-willingly
	name = "infernal contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll_seal"
	var/uses = 4.0
	flags = FPRINT | TABLEPASS
	w_class = 2.0
	item_state = "paper"
	color = "#FF0000"
	throw_speed = 4
	throw_range = 20
	desc = "A blank contract that's gone missing from hell."
	var/oneuse = 0
	
	New()
		src.color = random_color_hex()

	proc/MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //maybe this will let me cut down on the duplicate code
		if (!user) //oh god how did this happen
			return
	
	proc/vanish()
		src.visible_message("<span style=\"color:red\"><B>[src] suddenly vanishes!</B></span>")
		spawn(0)
		qdel(src)

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (!ismob(M))
			return
		if (!user.find_type_in_hand(/obj/item/pen/fancy/satan))
			return
		else if (user.mind.diabolical == 1)
			if (M == user)
				boutput(user, "<span style=\"color:blue\">You can't sell your soul to yourself!</span>")
				return
			else
				M.visible_message("<span style=\"color:red\"><B>[user] is guiding [M]'s hand to the signature field of a contract!</B></span>")
				if (!do_mob(user, M, 150))
					if (user && ismob(user))
						user.show_text("You were interrupted!", "red")
						return
				M.visible_message("<span style=\"color:red\">[user] forces [M] to sign a contract!</span>")
				logTheThing("combat", user, M, "forces %M% to sign a [src] at [log_loc(user)].")
				spawn(0)
				MagicEffect(M, user)
		else
			return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/pen))
			if (user.mind.diabolical == 1)
				boutput(user, "<span style=\"color:blue\">You can't sell your soul to yourself!</span>")
				return
			else if (user.mind.sold_soul == 1)
				boutput(user, "<span style=\"color:blue\">You don't have a soul to sell!</span>")
				return
			else if (istype(W, /obj/item/pen/fancy/satan))
				MagicEffect(user)
			else
				user.visible_message("<span style=\"color:red\"><b>[user] looks puzzled as [he_or_she(user)] realizes [his_or_her(user)] pen isn't evil enough to sign the [src]!</b></span>")
				return
		else
			return

obj/item/contract/satan
	desc = "A contract that promises to bestow upon whomever signs it near immortality, great power, and some other stuff you can't be bothered to read."
	
	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)]name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.satanclownize()
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/macho
	desc = "A contract that promises to bestow upon whomever signs it everlasting machismo, drugs, and some other stuff you can't be bothered to read."

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in slim jims upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding slim jim contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.shittymachoize()
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/wrestle
	desc = "A contract that promises to bestow upon whomever signs it athletic prowess, showmanship, and some other stuff you can't be bothered to read."

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in cocaine upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding cocaine contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.make_wrestler(1)
		user.traitHolder.addTrait("addict") //HEH
		boutput(user, "<span style=\"color:blue\">Oh cripes, looks like your years of drug abuse caught up with you! </span>")
		user.mind.special_role = "Faustian Wrestler"
		ticker.mode.Agimmicks.Add(user)
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/yeti
	desc = "A contract that promises to bestow upon whomever signs it near infinite power, an unending hunger, and some other stuff you can't be bothered to read."
	oneuse = 1
	
	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding yeti contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.makesuperyeti()
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/admin
	desc = "A contract that promises to bestow upon whomever signs it everlasting machismo, drugs, and some other stuff you can't be bothered to read."
	oneuse = 1
	
	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in slim jims upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding slim jim contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.machoize()
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/genetic
	desc = "A contract that promises to unlock the hidden potential of whomever signs it."
	oneuse = 0

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding genetic modifiying contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.bioholder.AddEffect("activator", variant = 666)
		user.bioholder.AddEffect("mutagenic_field", variant = 666)
		boutput(user, "<span style=\"color:blue\">You have finally achieved your full potential! Mom would so proud!</span>")
		if (prob(5))
			spawn(10)
			boutput(user, "<span style=\"color:green\">You feel an upwelling of additional power!</span>")
			user.unkillable = 1 //This isn't nearly as much of a boon as one might think.
			user.bioholder.AddEffect("mutagenic_field_prenerf", variant = 666) //The reason being that
			spawn(2) //after they come back to life, all the powers they had activated by the activator
			boutput(user, "<span style=\"color:blue\">You have ascended beyond mere humanity! Spread your gifts to the rest of the world!</span>")  //will no longer be considered as activated from their potential, so all the stability effects
			user.mind.special_role = "Genetic Demigod" //will kick in at that point and they'll
			ticker.mode.Agimmicks.Add(user) // be reduced to a genetic monstrosity in short order.
		if (src.oneuse == 1) //This is coming from personal experience as a solnerd. Trust me, superpowers and soul based shields don't mix.
			src.vanish() //This is coming from personal experience as a solnerd. Trust me, superpowers and soul based shields don't mix.
		else
			return

obj/item/contract/horse //TODO: finish horsepocalypse ALSO, UNFORTUNATELY, THIS ONE IS TOO SPECIAL TO DESPAGHETTIFY.
	desc = "A piece of parchment covered in nearly indecipherable scrawl. You can just barely make out something about horses and signatures."
	
	proc/endtimes()
		var/turf/spawn_turf = get_turf(src)
		new /obj/effects/ydrone_summon/horseman( spawn_turf ) //still need a sprite for horseman

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding horse contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.horse() //TODO(NE): turn into horse
		user.traitHolder.addTrait("soggy") //to spread the curse around
		boutput(user, "<span style=\"color:red\"><font size=6><B>NEIGH</b></font></span>")
		user.mind.special_role = "Faustian Horse" //neigh
		ticker.mode.Agimmicks.Add(user)
		if (total_souls_value >= 20) //OKAY, SO THIS IS NOW BASICALLY WORKING?
			src.endtimes()
			return
		if (src.oneuse == 1) //this particular contract should never be one use, but JUST IN CASE
			src.vanish()
		else
			return

obj/item/contract/mummy
	desc = "A contract that promises to turn whomever signs it into a mummy. That's it. No tricks."

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding yeti contract at [log_loc(user)]!")
		user.sellsoul()
		var/list/limbs = list("l_arm","r_arm","l_leg","r_leg","head","chest")
		for (var/target in limbs)
			if (!user.bandaged.Find(target))
				user.bandaged += target
				user.update_body()
		if(user.reagents)
			user.reagents.add_reagent("formaldehyde", 300) //embalming fluid for mummies
		if(prob(10))
			boutput(user, "<span style=\"color:blue\">Wow, that contract did a really thorough job of mummifying you! It removed your organs and everything!</span>") 
			spawn(0)
			user:organHolder.drop_organ("all")
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/vampire
	desc = "A contract that promises to bestow upon whomever signs it near immortality, great power, and some other stuff you can't be bothered to read. There's some warning about not using this one in the chapel written on the back."
	
	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)]name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.make_shitty_vampire()
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/fart //for popecrunch
	desc = "It's just a piece of paper with the word 'fart' written all over it."
	
	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)]name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.bioholder.AddEffect("linkedfart", variant = 666)
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/hair //for Megapaco
	desc = "This contract promises to make the undersigned individual have the best hair of anybody within 10 kilometers."
	
	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //HOPEFULLY CUTS OUT A BUNCH OF UNNECESSARY STUFF.
		..() //TODO: CHANGE REST OF CONTRACTS
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)]name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		for(var/mob/living/carbon/human/H in mobs)
			if (H == user)
				continue
			else
				H.bioHolder.mobAppearance.customization_first = "None"
		if (src.oneuse == 1)
			src.vanish()
		else
			return
