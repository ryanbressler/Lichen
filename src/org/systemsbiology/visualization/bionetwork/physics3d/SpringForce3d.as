/*
**    Copyright (C) 2003-2009 Institute for Systems Biology
**                            Seattle, Washington, USA.
**
**    This library is free software; you can redistribute it and/or
**    modify it under the terms of the GNU Lesser General Public
**    License as published by the Free Software Foundation; either
**    version 2.1 of the License, or (at your option) any later version.
**
**    This library is distributed in the hope that it will be useful,
**    but WITHOUT ANY WARRANTY; without even the implied warranty of
**    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
**    Lesser General Public License for more details.
**
**    You should have received a copy of the GNU Lesser General Public
**    License along with this library; If not, see <http://www.gnu.org/licenses/>.
*/

package org.systemsbiology.visualization.bionetwork.physics3d
{
	/**
	 * Force simulating a spring force between two particles. This force
	 * iterates over each <code>Spring</code> instance in a simulation and
	 * computes the spring force between the attached particles. Spring forces
	 * are computed using Hooke's Law plus a damping term modeling frictional
	 * forces in the spring.
	 * 
	 * <p>The actual equation is of the form: <code>F = -k*(d - L) + a*d*(v1 - 
	 * v2)</code>, where k is the spring tension, d is the distance between
	 * particles, L is the rest length of the string, a is the damping
	 * co-efficient, and v1 and v2 are the velocities of the particles.</p>
	 */
	public class SpringForce3d implements IForce3d
	{		
		/**
		 * Applies this force to a simulation.
		 * @param sim the Simulation to apply the force to
		 */
		public function apply(sim:Simulation3d):void
		{
			var s:Spring3d, p1:Particle3d, p2:Particle3d;
			var dx:Number, dy:Number, dz:Number, dn:Number, dd:Number, k:Number, fx:Number, fy:Number, fz:Number;
			
			for (var i:uint=0; i<sim.springs.length; ++i) {
				s = Spring3d(sim.springs[i]);
				p1 = s.p1;
				p2 = s.p2;				
				dx = p1.x - p2.x;
				dy = p1.y - p2.y;
				dz = p1.z - p2.z;
				dn = Math.sqrt(dx*dx + dy*dy + dz*dz);
				dd = dn<1 ? 1 : dn;
				
				k  = s.tension * (dn - s.restLength);
				k += s.damping * (dx*(p1.vx-p2.vx) + dy*(p1.vy-p2.vy)+ dz*(p1.vz-p2.vz)) / dd;
				k /= dd;
				
				// provide a random direction when needed
				if (dn==0) {
					dx = 0.01 * (0.5-Math.random());
					dy = 0.01 * (0.5-Math.random());
				}
				
				fx = -k * dx;
				fy = -k * dy;
				fz = -k * dz;
				
				p1.fx += fx; p1.fy += fy;
				p2.fx -= fx; p2.fy -= fy;
				p2.fz -= fx; p2.fz -= fz;
				
			}
		}
		
	} // end of class SpringForce
}