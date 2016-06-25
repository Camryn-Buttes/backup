mob/living/carbon/human/proc/horse()
	var/mob/living/carbon/human/H = src

	if(H.mind && (H.mind.assigned_role != "Horse") || (!H.mind || !H.client)) //I am shamelessly copying this from the wizard cluwne spell
		boutput(H, "<span style=\"color:red\"><B>You NEIGH painfully!</B></span>")
		H.take_brain_damage(80)
		H.stuttering = 120
		if(H.mind)
			H.mind.assigned_role = "Horse"
		H.contract_disease(/datum/ailment/disability/clumsy,null,null,1)
		playsound(get_turf(H), pick("sound/voice/cluwnelaugh1.ogg","sound/voice/cluwnelaugh2.ogg","sound/voice/cluwnelaugh3.ogg"), 100, 0, 0, max(0.7, min(1.4, 1.0 + (30 - H.bioHolder.age)/50)))
		H.nutrition = 9000
		H.change_misstep_chance(66)
		animate_clownspell(H)
		H.drop_from_slot(H.wear_suit)
		H.drop_from_slot(H.wear_mask)
		H.equip_if_possible(new /obj/item/clothing/suit/cultist/cursed(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/mask/horse_mask/cursed(H), H.slot_wear_mask)
		H.real_name = "HORSE"

/proc/neigh(var/string) //This is it. This is the lowest point in my life.
	var/modded = ""
	var/list/text_tokens = dd_text2list(string, " ")
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
	color = "#FF0000"
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
	spawn_contents = list(/obj/item/paper/soul_selling_kit, /obj/item/storage/box/evil, /obj/item/clothing/under/misc/lawyer/red)

	make_my_stuff() //hijacking this from space loot secure safes
		..()
		if (prob(1)) //gotta be rare enough for it to not get stale
			new /obj/item/contract/horse(src) //can't have it in normal loot pool

		var/list/contracts = list(/obj/item/contract/yeti,/obj/item/contract/genetic,/obj/item/contract/mummy,/obj/item/contract/vampire,/obj/item/contract/hair,/obj/item/contract/wrestle,/obj/item/contract/macho,/obj/item/contract/satan,/obj/item/contract/greed)
		var/tempcontract = null

		if (prob(1)) //gotta be rare enough for it to not get stale
			var/loot = rand(1,2)
			switch(loot)
				if (1)
					new /obj/item/contract/horse(src) //can't have it in normal loot pool
				else if (2)
					new /obj/item/contract/fart(src) //ditto, it's way too ridiculous and would get old fast if it were common.
		else
			tempcontract = pick(contracts)
			new tempcontract(src)
			contracts -= tempcontract

		tempcontract = pick(contracts)
		new tempcontract(src)
		contracts -= tempcontract

		tempcontract = pick(contracts)
		new tempcontract(src)
		contracts -= tempcontract

		tempcontract = pick(contracts)
		new tempcontract(src)
		contracts -= tempcontract

/obj/item/contract
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
	var/inuse = 0

	New()
		src.color = random_color_hex()

	proc/MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob) //this calls the actual contract effect
		if (!user) //oh god how did this happen? I don't know, but somehow it did.
			return
		if (user.mind.diabolical == 1)
			boutput(user, "<span style=\"color:blue\">You can't sell your soul to yourself!</span>")
			return
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
			else if (src.inuse != 1)
				src.inuse = 1
				M.visible_message("<span style=\"color:red\"><B>[user] is guiding [M]'s hand to the signature field of a contract!</B></span>")
				if (!do_mob(user, M, 150))
					if (user && ismob(user))
						user.show_text("You were interrupted!", "red")
						return
				M.visible_message("<span style=\"color:red\">[user] forces [M] to sign a contract!</span>")
				logTheThing("combat", user, M, "forces %M% to sign a [src] at [log_loc(user)].")
				spawn(0)
				MagicEffect(M, user)
				spawn(0)
					src.inuse = 0
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

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
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

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in slim jims upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding slim jim contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.machoize(1)
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/wrestle
	desc = "A contract that promises to bestow upon whomever signs it athletic prowess, showmanship, and some other stuff you can't be bothered to read."

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
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
	desc = "A contract that promises to bestow upon whomever signs it near infinite power, an unending hunger, and some other stuff you can't be bothered to read. Seems like it only has three signature lines."
	oneuse = 1
	var/used = 0

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding yeti contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.makesuperyeti()
		if (src.oneuse == 1)
			src.used++
			spawn(0)
			if (src.used >= 3)
				src.vanish()
		else
			return

obj/item/contract/admin
	desc = "A contract that promises to bestow upon whomever signs it everlasting machismo, drugs, and some other stuff you can't be bothered to read."
	oneuse = 1

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
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

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding genetic modifiying contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.bioHolder.AddEffect("activator", variant = 666)
		user.bioHolder.AddEffect("mutagenic_field", variant = 666)
		boutput(user, "<span style=\"color:blue\">You have finally achieved your full potential! Mom would so proud!</span>")
		if (prob(5))
			spawn(10)
			boutput(user, "<span style=\"color:green\">You feel an upwelling of additional power!</span>")
			user.unkillable = 1 //This isn't nearly as much of a boon as one might think.
			user.bioHolder.AddEffect("mutagenic_field_prenerf", variant = 666) //The reason being that
			spawn(2) //after they come back to life, all the powers they had activated by the activator
			boutput(user, "<span style=\"color:blue\">You have ascended beyond mere humanity! Spread your gifts to the rest of the world!</span>")  //will no longer be considered as activated from their potential, so all the stability effects
			user.mind.special_role = "Genetic Demigod" //will kick in at that point and they'll
			ticker.mode.Agimmicks.Add(user) // be reduced to a genetic monstrosity in short order.
		if (src.oneuse == 1) //This is coming from personal experience as a solnerd. Trust me, superpowers and soul based shields don't mix.
			src.vanish() //This is coming from personal experience as a solnerd. Trust me, superpowers and soul based shields don't mix.
		else
			return

obj/item/contract/horse
	desc = "A piece of parchment covered in nearly indecipherable scrawl. You can just barely make out something about horses and signatures."

	attack_self(mob/user as mob)
		if (total_souls_value >= 20) //OKAY, SO THIS IS NOW BASICALLY WORKING?
			src.endtimes()
			return
		else
			boutput(user, "<span style=\"color:red\"><font size=3><B>You currently have [total_souls_sold] souls, the total worth of which is [total_souls_value] soul points. You need 20 soul points to begin the end times. </b></font></span>")

	proc/endtimes()
		total_souls_value -= 20 //The last thing we need is endless horseman drones.
		spawn(0)
			var/turf/spawn_turf = get_turf(src)
			new /obj/effects/ydrone_summon/horseman(spawn_turf)

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)] name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding horse contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.horse()
		user.traitHolder.addTrait("soggy") //to spread the curse around
		boutput(user, "<span style=\"color:red\"><font size=6><B>NEIGH</b></font></span>")
		user.mind.special_role = "Faustian Horse" //neigh
		ticker.mode.Agimmicks.Add(user)
		if (src.oneuse == 1) //this particular contract should never be one use, but JUST IN CASE
			src.vanish()
		else
			return

obj/item/contract/mummy
	desc = "A contract that promises to turn whomever signs it into a mummy. That's it. No tricks."

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
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

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)]name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.make_vampire(1)
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/fart //for popecrunch
	desc = "It's just a piece of paper with the word 'fart' written all over it."

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)]name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		user.bioHolder.AddEffect("linkedfart", variant = 666)
		if (src.oneuse == 1)
			src.vanish()
		else
			return

obj/item/contract/hair //for Megapaco
	desc = "This contract promises to make the undersigned individual have the best hair of anybody within 10 kilometers."

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
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

obj/item/contract/greed //how the fuck did I not think of this yet
	desc = "This contract is positively covered in dollar signs."

	MagicEffect(var/mob/living/carbon/human/user as mob, var/mob/badguy as mob)
		..()
		user.visible_message("<span style=\"color:red\"><b>[user] signs [his_or_her(user)]name in blood upon the [src]!</b></span>")
		logTheThing("admin", user, null, "signed a soul-binding contract at [log_loc(user)]!")
		user.sellsoul()
		spawn(5)
		new /obj/item/spacecash/random(user.loc)
		boutput(user, "<span style=\"color:blue\">Some money appears at your feet. What, did you expect some sort of catch or trick?</span>")
		var/wealthy = rand(1,2)
		if (wealthy == 2)
			spawn(100)
			boutput(user, "<span style=\"color:blue\">Well, you were right.</span>")
			user.become_gold_statue()
		if (src.oneuse == 1)
			src.vanish()
		else
			return
