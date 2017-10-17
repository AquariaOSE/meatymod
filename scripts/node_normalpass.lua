-- Copyright (C) 2007, 2010 - Bit-Blot
--
-- This file is part of Aquaria.
--
-- Aquaria is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

function init(me)
end

function update(me, dt)
    local n = getNaija()
	if not isForm(FORM_NORMAL) and node_isEntityIn(me, n) then
		playSfx("shield-hit")
		spawnParticleEffect("barrier-hit", entity_x(n), entity_y(n))
		
		local w, h = node_getSize(me)
		local x, y = 0, 0
		entity_clearVel(n)
		if w > h then
			y = entity_y(n) - node_y(me)
            x = (math.random() - 0.5) * (y/2)
			if entity_y(n) < node_y(me) then
				entity_setPosition(n, entity_x(n), node_y(me) - (h/2) - 10)
			else
				entity_setPosition(n, entity_x(n), node_y(me) + (h+10)/2 + 10)
			end
		else
			x = entity_x(n) - node_x(me)
            y = (math.random() - 0.5) * (x/2)
		end
		
		
		x, y = vector_setLength(x, y, 2800)
		entity_setMaxSpeedLerp(n, 4.6)
		entity_setMaxSpeedLerp(n, 1, 4)
		entity_addVel(n, x, y)

		if chance(50) then
			emote(EMOTE_NAIJAUGH)
		end
	end
end
