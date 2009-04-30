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
	 * Force simulating frictional drag forces (e.g., air resistance). For
	 * each particle, this force applies a drag based on the particles
	 * velocity (<code>F = a * v</code>, where a is a drag co-efficient and
	 * v is the velocity of the particle).
	 */
	public class DragForce3d implements IForce3d
	{
		private var _dc:Number;
		
		/** The drag co-efficient. */
		public function get drag():Number { return _dc; }
		public function set drag(dc:Number):void { _dc = dc; }
		
		/**
		 * Creates a new DragForce with given drag co-efficient.
		 * @param dc the drag co-efficient.
		 */
		public function DragForce3d(dc:Number=0.1) {
			_dc = dc;
		}
		
		/**
		 * Applies this force to a simulation.
		 * @param sim the Simulation to apply the force to
		 */
		public function apply(sim:Simulation3d):void
		{
			if (_dc == 0) return;
			for (var i:uint = 0; i<sim.particles.length; ++i) {
				var p:Particle3d = sim.particles[i];
				p.fx -= _dc * p.vx;
				p.fy -= _dc * p.vy;
				p.fz -= _dc * p.vz;
			}
		}
		
	} // end of class DragForce
}