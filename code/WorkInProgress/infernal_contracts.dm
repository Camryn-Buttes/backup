/mob/proc/makesuperyeti()
	new /obj/critter/yeti/super(src.loc)
	src.partygib

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
	name = "Infernal pen"
	desc = "A pen once owned by Old Nick himself."
	force = 15
	throwforce = 15
	hit_type = DAMAGE_STAB
	color = "#FF0000"
	font_color = "#FF0000"
	
/obj/item/storage/briefcase/satan
	name = "Devilish Briefcase"
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
	desc = "A diabolical human leather-bound briefcase, capable of holding a number of small objects and tormented souls."
	stamina_damage = 90 //is this a bad idea?
	stamina_cost = 30
	stamina_crit_chance = 45 //yes, yes it is.
	spawn_contents = list(/obj/item/contract/satan, obj/item/contract/macho, obj/item/contract/wrestle, /obj/item/pen/fancy/satan = 2, /obj/item/clothing/under/misc/lawyer/red)
	
	make_my_stuff() //hijacking this from space loot secure safes
		..()
		var/loot = rand(1,9)
		switch (loot)
			if (1)
				new obj/item/contract/yeti(src)
			if (2)
				new obj/item/contract/genetic(src)

/obj/item/contract
	name = "Infernal Contract"
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
	oneuse = 0
	
	New()
		src.color = random_color_hex()

obj/item/contract/satan
	desc = "This contract promises to whomever signs it near immortality, great power, and some other stuff you can't be bothered to read."
	
	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/pen))
			if (user.mind.sold_soul == 1)
				boutput(user, "<span style=\"color:blue\">You don't have a soul to sell!</span>")
				return
			if (istype(W, /obj/item/pen/fancy/satan))
				user.visible_message("<span style=\"color:red\"><b>[user] signs \his name in blood upon the [src]!</b></span>")
				logTheThing("admin", user, null, "signed a soul-binding contract at [log_loc(user)]!"
				user.mind.sold_soul = 1
				spawn(5)
				user.satanclownize()
				if (src.oneuse == 1)
					spawn(10)
					qdel(src)
				else
					return
				
			else
				user.visible_message("<span style=\"color:red\"><b>[user] looks puzzled as \he realizes \his pen isn't evil enough to sign the [src]!</b></span>")
				return
		else
			return

obj/item/contract/macho
	desc = "This contract promises to whomever signs it everlasting machismo, drugs, and some other stuff you can't be bothered to read."

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/pen))
			if (user.mind.sold_soul == 1)
				boutput(user, "<span style=\"color:blue\">You don't have a soul to sell!</span>")
				return
			if (istype(W, /obj/item/pen/fancy/satan))
				user.visible_message("<span style=\"color:red\"><b>[user] signs \his name in slim jims upon the [src]!</b></span>")
				logTheThing("admin", user, null, "signed a soul-binding slim jim contract at [log_loc(user)]!"
				user.mind.sold_soul = 1
				spawn(5)
				user.shittymachoize()
				if (src.oneuse == 1)
					spawn(10)
					qdel(src)
				else
					return
				
				
			else
				user.visible_message("<span style=\"color:red\"><b>[user] looks puzzled as \he realizes \his pen isn't evil enough to sign the [src]!</b></span>")
				return
		else
			return
	
obj/item/contract/wrestle
	desc = "This contract promises to whomever signs it athletic prowess, showmanship, and some other stuff you can't be bothered to read."

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/pen))
			if (user.mind.sold_soul == 1)
				boutput(user, "<span style=\"color:blue\">You don't have a soul to sell!</span>")
				return
			if (istype(W, /obj/item/pen/fancy/satan))
				user.visible_message("<span style=\"color:red\"><b>[user] signs \his name in cocaine upon the [src]!</b></span>")
				logTheThing("admin", user, null, "signed a soul-binding cocaine contract at [log_loc(user)]!"
				user.mind.sold_soul = 1
				spawn(5)
				user.make_wrestler(1)
				user.traitHolder.addTrait("addict") //HEH
				boutput(user, "<span style=\"color:blue\">Oh cripes, looks like your years of drug abuse caught up with you! </span>")
				user.mind.special_role = "Faustian Wrestler"
				ticker.mode.Agimmicks.Add(user)
				if (src.oneuse == 1)
					spawn(10)
					qdel(src)
				else
					return
				
			else
				user.visible_message("<span style=\"color:red\"><b>[user] looks puzzled as \he realizes \his pen isn't evil enough to sign the [src]!</b></span>")
				return
		else
			return

obj/item/contract/yeti
	desc = "This contract promises to whomever signs it near infinite power, an unending hunger, and some other stuff you can't be bothered to read."
	oneuse = 1
	
	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/pen))
			if (user.mind.sold_soul == 1)
				boutput(user, "<span style=\"color:blue\">You don't have a soul to sell!</span>")
				return
			if (istype(W, /obj/item/pen/fancy/satan))
				user.visible_message("<span style=\"color:red\"><b>[user] signs \his name in blood upon the [src]!</b></span>")
				logTheThing("admin", user, null, "signed a soul-binding yeti contract at [log_loc(user)]!"
				user.mind.sold_soul = 1
				spawn(5)
				user.makesuperyeti()
				if (src.oneuse == 1)
					spawn(10)
					qdel(src)
				else
					return
				
			else
				user.visible_message("<span style=\"color:red\"><b>[user] looks puzzled as \he realizes \his pen isn't evil enough to sign the [src]!</b></span>")
				return
		else
			return


obj/item/contract/admin
	desc = "This contract promises to whomever signs it everlasting machismo, drugs, and some other stuff you can't be bothered to read."
	oneuse = 1
	
	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/pen))
			if (user.mind.sold_soul == 1)
				boutput(user, "<span style=\"color:blue\">You don't have a soul to sell!</span>")
				return
			if (istype(W, /obj/item/pen/fancy/satan))
				user.visible_message("<span style=\"color:red\"><b>[user] signs \his name in slim jims upon the [src]!</b></span>")
				logTheThing("admin", user, null, "signed a soul-binding slim jim contract at [log_loc(user)]!"
				user.mind.sold_soul = 1
				spawn(5)
				user.machoize()
				if (src.oneuse == 1)
					spawn(10)
					qdel(src)
				else
					return
				
				
			else
				user.visible_message("<span style=\"color:red\"><b>[user] looks puzzled as \he realizes \his pen isn't evil enough to sign the [src]!</b></span>")
				return
		else
			return

obj/item/contract/genetic
	desc = "This contract promises to unlock the hidden potential of whomever signs it."
	oneuse = 0
	
	New()
		..()
		if (prob(10))
			src.oneuse = 1

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/pen))
			if (user.mind.sold_soul == 1)
				boutput(user, "<span style=\"color:blue\">You don't have a soul to sell!</span>")
				return
			if (istype(W, /obj/item/pen/fancy/satan))
				user.visible_message("<span style=\"color:red\"><b>[user] signs \his name in blood upon the [src]!</b></span>")
				logTheThing("admin", user, null, "signed a soul-binding genetic modifiying contract at [log_loc(user)]!"
				user.mind.sold_soul = 1
				spawn(5)
				user.bioholder.AddEffect("activator",666)
				user.bioholder.AddEffect("mutagenic_field",666)
				if (src.oneuse == 1)
					user.unkillable = 1 //This isn't nearly as much of a boon as one might think.
					user.bioholder.AddEffect("mutagenic_field_prenerf",666) //The reason being that
					spawn(10) //after they come back to life, all the powers they had activated by the activator
					qdel(src) //will no longer be considered as activated from their potential, so all the stability effects
				else //will kick in at that point and they'll
					return // be reduced to a genetic monstrosity in short order.
				
			else //This is coming from personal experience as a solnerd. Trust me, superpowers and soul based shields don't mix.
				user.visible_message("<span style=\"color:red\"><b>[user] looks puzzled as \he realizes \his pen isn't evil enough to sign the [src]!</b></span>")
				return
		else
			return
