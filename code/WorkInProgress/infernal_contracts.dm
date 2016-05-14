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
	src.playsound_local(src.loc,"sound/effects/screech.ogg", 100, 1)
	shake_camera(src, 20, 1)
	boutput(src, "<font color=red>[screamstring]</font>")
	boutput(src, "<i><b><font face = Tempus Sans ITC>His Grace accepts thee, spread His will! All who look close to the Enlightened may share His gifts.</font></b></i>")
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
	
/obj/item/contract
	name = "Infernal Contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll_seal"
	var/uses = 4.0
	flags = FPRINT | TABLEPASS
	w_class = 2.0
	item_state = "paper"
	color = "#FFEE44"
	throw_speed = 4
	throw_range = 20
	desc = "This contract promises nearly limitless vital "
