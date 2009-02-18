package org.systemsbiology.visualization.bionetwork.physics3d
{
	/**
	 * Interface representing a force within a physics simulation.
	 */
	public interface IForce3d
	{
		/**
		 * Applies this force to a simulation.
		 * @param sim the Simulation to apply the force to
		 */
		function apply(sim:Simulation3d):void;
		
	} // end of interface IForce
}