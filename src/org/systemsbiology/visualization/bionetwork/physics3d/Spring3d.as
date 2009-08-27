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
	 * Represents a Spring in a physics simulation. A spring connects two
	 * particles and is defined by the springs rest length, spring tension,
	 * and damping (friction) co-efficient.
	 */
	public class Spring3d
	{
		/** The first particle attached to the spring. */
		public var p1:Particle3d;
		/** The second particle attached to the spring. */
		public var p2:Particle3d;
		/** The rest length of the spring. */
		public var restLength:Number;
		/** The tension of the spring. */
		public var tension:Number;
		/** The damping (friction) co-efficient of the spring. */
		public var damping:Number;
		/** Flag indicating that the spring is scheduled for removal. */
		public var die:Boolean;
		/** Tag property for storing an arbitrary value. */
		public var tag:uint;
		
		/**
		 * Creates a new Spring with given parameters.
		 * @param p1 the first particle attached to the spring
		 * @param p2 the second particle attached to the spring
		 * @param restLength the rest length of the spring
		 * @param tension the tension of the spring
		 * @param damping the damping (friction) co-efficient of the spring
		 */
		public function Spring3d(p1:Particle3d, p2:Particle3d, restLength:Number=10,
							   tension:Number=0.1, damping:Number=0.1)
		{
			init(p1, p2, restLength, tension, damping);
		}
		
		/**
		 * Initializes an existing spring instance.
		 * @param p1 the first particle attached to the spring
		 * @param p2 the second particle attached to the spring
		 * @param restLength the rest length of the spring
		 * @param tension the tension of the spring
		 * @param damping the damping (friction) co-efficient of the spring
		 */
		public function init(p1:Particle3d, p2:Particle3d, restLength:Number=10,
							 tension:Number=0.1, damping:Number=0.1):void
		{
			this.p1 = p1;
			this.p2 = p2;
			this.restLength = restLength;
			this.tension = tension;
			this.damping = damping;
			this.die = false;
			this.tag = 0;
		}
		
		/**
		 * "Kills" this spring, scheduling it for removal in the next
		 * simulation cycle.
		 */
		public function kill():void {
			this.die = true;
		}
		
	} // end of class Spring
}