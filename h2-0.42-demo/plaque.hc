/*
 * $Header: /H3/game/hcode/plaque.hc 19    8/16/97 9:16a Rlove $
 */

float PLAQUE_INVISIBLE = 1;
float PLAQUE_ACTIVATE  = 2;

/*
================
plague_use

Activate a plaque
================
*/
void plaque_use (void)
{
	if (self.spawnflags & PLAQUE_ACTIVATE)
		self.inactive = 0;
}

void plaque_touch (void)
{
	vector	spot1, spot2;	

	if (self.inactive)
		return;

	if ((other.classname == "player") && (!other.plaqueflg))
	{
		makevectors (other.v_angle);
		spot1 = other.origin + other.view_ofs;
		spot2 = spot1 + (v_forward*25); // Look just a little ahead
		traceline (spot1, spot2 , FALSE, other);

		if ((trace_fraction == 1.0) || (trace_ent.classname!="plaque"))
		{
			traceline (spot1, spot2 - (v_up * 30), FALSE, other);  // 30 down
		
			if ((trace_fraction == 1.0) || (trace_ent.classname!="plaque"))
			{
				traceline (spot1, spot2 + v_up * 30, FALSE, other);  // 30 up
			
				if ((trace_fraction == 1.0) || (trace_ent.classname!="plaque"))
					return;
			}
		}

		other.plaqueflg = 1;
		other.plaqueangle = other.v_angle;
		msg_entity = other;
	 	plaque_draw(MSG_ONE,self.message);

  		if (other.noise1 != "")
  			sound (other, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
		else
			sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	}
}

/*QUAKED plaque (.5 .5 .5) ? INVISIBLE deactivated

A plaque on the wall a player can read
-------------------------FIELDS-------------------------

"message" the index of the string in the text file

"noise1" the wav file activated when plaque is used

deactivated - if this is on, the plaque will not be readable until a trigger has activated it.
--------------------------------------------------------
*/
void() plaque =
{
	setsize (self, self.mins, self.maxs);
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	self.solid = SOLID_SLIDEBOX;

	if (deathmatch)  // I don't do a remove because they might be a part of the architecture
		return;

	self.use = plaque_use;

	precache_sound("raven/use_plaq.wav");
	self.noise = "raven/use_plaq.wav";

	self.touch = plaque_touch;

	if (self.spawnflags & PLAQUE_INVISIBLE)
		self.effects (+) EF_NODRAW;

	if (self.spawnflags & PLAQUE_ACTIVATE)
		self.inactive = 1;
	else
		self.inactive = 0;
};

