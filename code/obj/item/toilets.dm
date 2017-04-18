/*
CONTAINS:
TOILET

*/

var/list/all_toilets = new/list()

/obj/item/storage/toilet
	name = "toilet"
	w_class = 4.0
	anchored = 1.0
	density = 0.0
	mats = 5
	var/status = 0.0
	var/clogged = 0.0
	anchored = 1.0
	icon = 'icons/obj/objects.dmi'
	icon_state = "toilet"
	rand_pos = 0

	New()
		..()
		all_toilets.Add(src)

	suicide(var/mob/user as mob)
		if(!hasvar(user,"organHolder")) return 0

		user.visible_message("<span style=\"color:red\"><b>[user] sticks \his head into the [src.name] and flushes it, giving \himself an atomic swirlie!</b></span>")
		var/obj/head = user:organHolder.drop_organ("head")
		var/list/emergeplaces = new/list()
		if ((src.clogged >= 1) || (src.contents.len >= 7))
			head.set_loc(get_turf(src.loc))
			playsound(src.loc, "sound/effects/slosh.ogg", 50, 1)
			src.visible_message("<span style=\"color:blue\">[head.name] floats up out of the clogged [src]!</span>")
			for (var/mob/O in AIviewers(head, null))
				if (prob(33) && ishuman(O) && !(O == user))
					O.show_message("<span style=\"color:red\">You feel ill from watching that.</span>")
					for (var/mob/V in viewers(O, null))
						V.show_message("<span style=\"color:red\">[O] pukes all over \himself.</span>", 1)
						playsound(O.loc, "sound/effects/splat.ogg", 50, 1)
						new /obj/decal/cleanable/vomit(O.loc)
		else
			for(var/obj/item/storage/toilet/T in all_toilets)
				if(T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z)) continue
				emergeplaces.Add(T)
			if(emergeplaces.len)
				var/atom/picked = pick(emergeplaces)
				head.set_loc(get_turf(picked.loc))
				playsound(picked.loc, "sound/effects/slosh.ogg", 50, 1)
				head.visible_message("<span style=\"color:blue\">[head.name] emerges from the toilet!</span>")
			for (var/mob/O in AIviewers(head, null))
				if (prob(33) && ishuman(O))
					O.show_message("<span style=\"color:red\">You feel ill from watching that.</span>")
					for (var/mob/V in viewers(O, null))
						V.show_message("<span style=\"color:red\">[O] pukes all over \himself.</span>", 1)
						playsound(O.loc, "sound/effects/splat.ogg", 50, 1)
						new /obj/decal/cleanable/vomit(O.loc)
		playsound(src.loc, 'sound/effects/slosh.ogg', 50, 1)
		user.updatehealth()
		spawn(100)
			if (user)
				user.suiciding = 0
		return 1

/obj/item/storage/toilet/attackby(obj/item/W as obj, mob/user as mob)

	if (src.contents.len >= 7)
		boutput(user, "The toilet is clogged!")
		return
	if (istype(W, /obj/item/storage/))
		return
	if (istype(W, /obj/item/grab))
		playsound(src.loc, "sound/effects/slosh.ogg", 50, 1)
		user.visible_message("<span style=\"color:blue\">[user] gives [W:affecting] a swirlie!</span>", "<span style=\"color:blue\">You give [W:affecting] a swirlie. It's like Middle School all over again!</span>")
		return

	return ..()

/obj/item/storage/toilet/MouseDrop(atom/over_object, src_location, over_location)
	if (usr && over_object == usr && in_range(src, usr) && iscarbon(usr) && !usr.stat)
		usr.visible_message("<span style=\"color:red\">[usr] [pick("shoves", "sticks", "stuffs")] [his_or_her(usr)] hand into [src]!</span>")
		playsound(src.loc, "sound/effects/slosh.ogg", 50, 1)
	..()

/obj/item/storage/toilet/MouseDrop_T(mob/M as mob, mob/user as mob)
	if (!ticker)
		boutput(user, "You can't help relieve anyone before the game starts.")
		return
	if ((!( istype(M, /mob) ) || get_dist(src, user) > 1 || M.loc != src.loc || user.restrained() || usr.stat))
		return
	if ((M == usr) && (istype(M:w_uniform, /obj/item/clothing/under/gimmick/mario)) && (istype(M:head, /obj/item/clothing/head/mario)))
		user.visible_message("<span style=\"color:blue\">[user] dives into the toilet!</span>", "<span style=\"color:blue\">You dive into the toilet!</span>")
		particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(get_turf(src.loc)))
		playsound(src.loc, "sound/effects/slosh.ogg", 50, 1)
		var/list/destinations = new/list()

		for(var/obj/item/storage/toilet/T in all_toilets)
			if(T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z)) continue
			destinations.Add(T)

		if(destinations.len)
			var/atom/picked = pick(destinations)
			particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(get_turf(picked.loc)))
			M.set_loc(get_turf(picked.loc))
			playsound(picked.loc, "sound/effects/slosh.ogg", 50, 1)
			user.visible_message("<span style=\"color:blue\">[user] emerges from the toilet!</span>", "<span style=\"color:blue\">You emerge from the toilet!</span>")
			M.unlock_medal("It'sa me, Mario", 1)
		return
	else if (M == usr)
		user.visible_message("<span style=\"color:blue\">[user] sits on the toilet.</span>", "<span style=\"color:blue\">You sit on the toilet.</span>")
	else
		user.visible_message("<span style=\"color:blue\">[M] is seated on the toilet by [user]!</span>")
	M.anchored = 1
	M.buckled = src
	M.set_loc(src.loc)
	src.add_fingerprint(user)
	return

/obj/item/storage/toilet/attack_hand(mob/user as mob)
	for(var/mob/M in src.loc)
		if (M.buckled)
			if (M != user)
				user.visible_message("<span style=\"color:blue\">[M] is zipped up by [user]. That's... that's honestly pretty creepy.</span>")
			else
				user.visible_message("<span style=\"color:blue\">[M] zips up.</span>", "<span style=\"color:blue\">You zip up.</span>")
//			boutput(world, "[M] is no longer buckled to [src]")
			M.anchored = 0
			M.buckled = null
			src.add_fingerprint(user)
	if((src.clogged < 1) || (src.contents.len < 7) || (user.loc != src.loc))
		user.visible_message("<span style=\"color:blue\">[user] flushes the toilet.</span>", "<span style=\"color:blue\">You flush the toilet.</span>")
		src.clogged = 0
		src.contents.len = 0
	else if((src.clogged >= 1) || (src.contents.len >= 7) || (user.buckled != src.loc))
		src.visible_message("<span style=\"color:blue\">The toilet is clogged!</span>")

/obj/item/storage/toilet/random
	New()
		..()
		if (prob(1))
			var/something = pick(trinket_safelist)
			if (ispath(something))
				new something(src)
