package org.systemsbiology.visualization.bionetwork.physics3d
{
	/**
	 * Force simulating a global gravitational pull on Particle instances.
	 */
	public class GravityForce3d implements IForce3d
	{
		private var _gx:Number;
		private var _gy:Number;
		private var _gz:Number;
		
		/** The gravitational acceleration in the horizontal dimension. */
		public function get gravityX():Number { return _gx; }
		public function set gravityX(gx:Number):void { _gx = gx; }
		
		/** The gravitational acceleration in the vertical dimension. */
		public function get gravityY():Number { return _gy; }
		public function set gravityY(gy:Number):void { _gy = gy; }
		
		/** The gravitational acceleration in the z dimension. */
		public function get gravityZ():Number { return _gz; }
		public function set gravityZ(gz:Number):void { _gz = gz; }
		
		/**
		 * Creates a new gravity force with given acceleration values.
		 * @param gx the gravitational acceleration in the horizontal dimension
		 * @param gy the gravitational acceleration in the vertical dimension
		 */
		public function GravityForce3d(gx:Number=0, gy:Number=0, gz:Number=0) {
			_gx = gx;
			_gy = gy;
			_gz = gz;
		}
		
		/**
		 * Applies this force to a simulation.
		 * @param sim the Simulation to apply the force to
		 */
		public function apply(sim:Simulation3d):void
		{
			if (_gx == 0 && _gy == 0 && _gz == 0) return;
			
			var p:Particle3d;
			for (var i:uint=0; i<sim.particles.length; ++i) {
				p = sim.particles[i];
				p.fx += _gx * p.mass;
				p.fy += _gy * p.mass;
				p.fz += _gz * p.mass;
			}
		}
		
	} // end of class GravityForce
}