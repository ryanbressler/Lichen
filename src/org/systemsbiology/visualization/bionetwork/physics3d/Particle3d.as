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
	 * Represents a Particle in a physics simulation. A particle is a 
	 * point-mass (or point-charge) subject to physical forces.
	 */
	public class Particle3d
	{
		/** The mass (or charge) of the particle. */
		public var mass:Number;
		/** The number of springs (degree) attached to this particle. */
		public var degree:Number;
		/** The x position of the particle. */
		public var x:Number;
		/** The y position of the particle. */
		public var y:Number;
		/** The z position of the particle. */
		public var z:Number;
		/** The x velocity of the particle. */
		public var vx:Number;
		/** A temporary x velocity variable. */
		public var _vx:Number;
		/** The y velocity of the particle. */
		public var vy:Number;
		/** A temporary y velocity variable. */
		public var _vy:Number;
		/** The z velocity of the particle. */
		public var vz:Number;
		/** A temporary z velocity variable. */
		public var _vz:Number;
		/** The x force exerted on the particle. */
		public var fx:Number;
		/** The y force exerted on the particle. */
		public var fy:Number;
		/** The z force exerted on the particle. */
		public var fz:Number;
		/** The age of the particle in simulation ticks. */
		public var age:Number;
		/** Flag indicating if the particule should have a fixed position. */
		public var fixed:Boolean;
		/** Flag indicating that the particle is scheduled for removal. */
		public var die:Boolean;
		/** Tag property for storing an arbitrary value. */
		public var tag:uint;
		
		/**
		 * Creates a new Particle with given parameters.
		 * @param mass the mass (or charge) of the particle
		 * @param x the x position of the particle
		 * @param y the y position of the particle
		 * @param vx the x velocity of the particle
		 * @param vy the y velocity of the particle
		 * @param fixed flag indicating if the particle should have a 
		 *  fixed position
		 */
		public function Particle3d(mass:Number=1, x:Number=0, y:Number=0, z:Number=0,
								 vx:Number=0, vy:Number=0, vz:Number=0, fixed:Boolean=false)
		{
			init(mass, x, y, z, vx, vy, vz, fixed);
		}
		
		/**
		 * Initializes an existing particle instance.
		 * @param mass the mass (or charge) of the particle
		 * @param x the x position of the particle
		 * @param y the y position of the particle
		 * @param vx the x velocity of the particle
		 * @param vy the y velocity of the particle
		 * @param fixed flag indicating if the particle should have a 
		 *  fixed position
		 */
		public function init(mass:Number=1, x:Number=0, y:Number=0, z:Number=0,
			vx:Number=0, vy:Number=0, vz:Number=0, fixed:Boolean=false):void
		{
			this.mass = mass;
			this.degree = 0;
			this.x = x;
			this.y = y;
			this.z = z;
			this.vx = this._vx = vx;
			this.vy = this._vy = vy;
			this.vz = this._vz = vz;
			this.fx = 0;
			this.fy = 0;
			this.fz = 0;
			this.age = 0;
			this.fixed = fixed;
			this.die = false;
			this.tag = 0;
		}
		
		/**
		 * "Kills" this particle, scheduling it for removal in the next
		 * simulation cycle.
		 */
		public function kill():void {
			this.die = true;
		}
		
	} // end of class Particle
}