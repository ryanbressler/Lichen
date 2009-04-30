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
	 * Force simulating an N-Body force of charged particles with pairwise
	 * interaction, such as gravity or electrical charge. This class uses a
	 * quad-tree structure to aggregate charge values and optimize computation.
	 * The force function is a standard inverse-square law (though in this case
	 * approximated due to optimization): <code>F = G * m1 * m2 / d^2</code>,
	 * where G is a constant (e.g., gravitational constant), m1 and m2 are the
	 * masses (charge) of the particles, and d is the distance between them.
	 * 
	 * <p>The algorithm used is that of J. Barnes and P. Hut, in their research
	 * paper <i>A Hierarchical  O(n log n) force calculation algorithm</i>, Nature, 
	 * v.324, December 1986. For more details on the algorithm, see one of
	 * the following links:
	 * <ul>
	 *   <li><a href="http://www.cs.berkeley.edu/~demmel/cs267/lecture26/lecture26.html">James Demmel's UC Berkeley lecture notes</a>
	 *   <li><a href="http://www.physics.gmu.edu/~large/lr_forces/desc/bh/bhdesc.html">Description of the Barnes-Hut algorithm</a>
	 *   <li><a href="http://www.ifa.hawaii.edu/~barnes/treecode/treeguide.html">Joshua Barnes' implementation</a>
	 * </ul></p>
	 */
	public class NBodyForce3d implements IForce3d
	{
		private var _g:Number;     // gravitational constant
		private var _t:Number;     // barnes-hut theta
		private var _max:Number;   // max effective distance
		private var _min:Number;   // min effective distance
		private var _eps:Number;   // epsilon for determining 'same' location
		
		private var _x1:Number, _y1:Number, _z1:Number, _x2:Number, _y2:Number, _z2:Number;
		private var _root:OctTreeNode;
		
		/** The gravitational constant to use. 
		 *  Negative values produce a repulsive force. */
		public function get gravitation():Number { return _g; }
		public function set gravitation(g:Number):void { _g = g; }
		
		/** The maximum distance over which forces are exerted. 
		 *  Any greater distances will be ignored. */
		public function get maxDistance():Number { return _max; }
		public function set maxDistance(d:Number):void { _max = d; }
		
		/** The minumum effective distance over which forces are exerted.
		 * 	Any lesser distances will be treated as the minimum. */
		public function get minDistance():Number { return _min; }
		public function set minDistance(d:Number):void { _min = d; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new NBodyForce with given parameters.
		 * @param g the gravitational constant to use.
		 *  Negative values produce a repulsive force.
		 * @param maxd a maximum distance over which the force should operate.
		 *  Particles separated by more than this distance will not interact.
		 * @param mind the minimum distance over which the force should operate.
		 *  Particles closer than this distance will interact as if they were
		 *  the minimum distance apart. This helps avoid extreme forces.
		 *  Helpful when particles are very close together.
		 * @param eps an epsilon values for determining a minimum distance
		 *  between particles
		 * @param t the theta parameter for the Barnes-Hut approximation.
		 *  Determines the level of approximation (default value if 0.9).
		 */
		public function NBodyForce3d(g:Number=-1, max:Number=200, min:Number=2,
								   eps:Number=0.01, t:Number=0.9)
		{
			_g = g;
			_max = max;
			_min = min;
			_eps = eps;
			_t = t;
			_root = OctTreeNode.node();
		}

		/**
		 * Applies this force to a simulation.
		 * @param sim the Simulation to apply the force to
		 */
		public function apply(sim:Simulation3d):void
		{
			if (_g == 0) return;
			
			// clear the quadtree
			clear(_root); _root = OctTreeNode.node();
			
			// get the tree bounds
			bounds(sim);
        
        	// populate the tree
        	for (var i:uint = 0; i<sim.particles.length; ++i) {
        		insert(sim.particles[i], _root, _x1, _y1, _z1, _x2, _y2, _z2);
        	}	
        	
        	// traverse tree to compute mass
        	accumulate(_root);
        	
        	// calculate forces on each particle
        	for (i=0; i<sim.particles.length; ++i) {
        		forces(sim.particles[i], _root, _x1, _y1, _z1, _x2, _y2, _z2);
        	}
		}
		
		private function accumulate(n:OctTreeNode):void {
			var xc:Number = 0, yc:Number = 0, zc:Number = 0;
			n.mass = 0;
			
			// accumulate childrens' mass
			var recurse:Function = function(c:OctTreeNode):void {
				if (c == null) return;
				accumulate(c);
				n.mass += c.mass;
				xc += c.mass * c.cx;
				yc += c.mass * c.cy;
				zc += c.mass * c.cz;
			}
			if (n.hasChildren) {
				recurse(n.c1); recurse(n.c2); recurse(n.c3); recurse(n.c4); recurse(n.c5); recurse(n.c6); recurse(n.c7); recurse(n.c8);
			}
			
			// accumulate own mass
			if (n.p != null) {
				n.mass += n.p.mass;
				xc += n.p.mass * n.p.x;
				yc += n.p.mass * n.p.y;
				zc += n.p.mass * n.p.z;
			}
			n.cx = xc / n.mass;
			n.cy = yc / n.mass;
			n.cz = zc / n.mass;
		}
		
		private function forces(p:Particle3d, n:OctTreeNode,
			x1:Number, y1:Number, z1:Number, x2:Number, y2:Number, z2 : Number):void
		{
			var f:Number = 0;
			var dx:Number = n.cx - p.x;
			var dy:Number = n.cy - p.y;
			var dz:Number = n.cz - p.z;
			var dd:Number = Math.sqrt(dx*dx + dy*dy + dz*dz);
			var max:Boolean = _max > 0 && dd > _max;
			if (dd==0) { // add direction when needed
				dx = _eps * (0.5-Math.random());
				dy = _eps * (0.5-Math.random());
				dz = _eps * (0.5-Math.random());
			}
			
			// the Barnes-Hut approximation criteria is if the ratio of the
        	// size of the quadtree box to the distance between the point and
        	// the box's center of mass is beneath some threshold theta.
        	if ( (!n.hasChildren && n.p != p) || ((x2-x1)/dd < _t) )
        	{
            	if ( max ) return;
            	// either only 1 particle or we meet criteria
            	// for Barnes-Hut approximation, so calc force
            	dd = dd<_min ? _min : dd;
            	f = _g * p.mass * n.mass / (dd*dd*dd)
            	p.fx += f*dx; p.fy += f*dy; p.fz += f*dz;
        	}
        	else if ( n.hasChildren )
        	{
            	// recurse for more accurate calculation
            	var sx:Number = (x1+x2)/2
            	var sy:Number = (y1+y2)/2;
            	var sz:Number = (z1+z2)/2;
            	
            	if (n.c1) forces(p, n.c1, x1, z1, y1, sx, sy, sz);
				if (n.c2) forces(p, n.c2, sx, z1, y1, x2, sy, sz);
				if (n.c3) forces(p, n.c3, x1, z1, sy, sx, y2, sz);
				if (n.c4) forces(p, n.c4, sx, z1, sy, x2, y2, sz);
				if (n.c5) forces(p, n.c5, x1, sz, y1, sx, sy, z1);
				if (n.c6) forces(p, n.c6, sx, sz, y1, x2, sy, z1);
				if (n.c7) forces(p, n.c7, x1, sz, sy, sx, y2, z1);
				if (n.c8) forces(p, n.c8, sx, sz, sy, x2, y2, z1);

            	if ( max ) return;
            	if ( n.p != null && n.p != p ) {
            		dd = dd<_min ? _min : dd;
                	f = _g * p.mass * n.p.mass / (dd*dd*dd);
                	p.fx += f*dx; p.fy += f*dy, p.fz += f*dz;
            	}
			}
		}
				
		// -- Helpers ---------------------------------------------------------
		
		private function insert(p:Particle3d, n:OctTreeNode,
			x1:Number, y1:Number, z1:Number, x2:Number, y2:Number, z2:Number):void
		{
			// ignore particles with NaN coordinates
			if (isNaN(p.x) || isNaN(p.y) || isNaN(p.z)) return;
			
			// try to insert particle p at node n in the quadtree
        	// by construction, each leaf will contain either 1 or 0 particles
        	if ( n.hasChildren ) {
            	// n contains more than 1 particle
            	insertHelper(p,n,x1,y1,z1,x2,y2,z2);
        	} else if ( n.p != null ) {
            	// n contains 1 particle
            	if ( isSameLocation(n.p, p) ) {
            		// recurse
                	insertHelper(p,n,x1,y1,z1,x2,y2,z2);
            	} else {
            		// divide
            		var v:Particle3d = n.p; n.p = null;
                	insertHelper(v,n,x1,y1,z1,x2,y2,z2);
                	insertHelper(p,n,x1,y1,z1,x2,y2,z2);
            	}
        	} else { 
            	// n is empty, add p as leaf
            	n.p = p;
        	}
		}
		
		private function insertHelper(p:Particle3d, n:OctTreeNode, 
			x1:Number, y1:Number,z1:Number, x2:Number, y2:Number, z2:Number):void
    	{
    		// determine split
			var sx:Number = (x1+x2)/2;
			var sy:Number = (y1+y2)/2;
			var sz:Number = (z1+z2)/2;
			var c:uint = (p.x >= sx ? 1 : 0) + (p.y >= sy ? 2 : 0)+ (p.z >= sz ? 4 : 0);
			
			// update bounds
			if (p.x >= sx) x1 = sx; else x2 = sx;
			if (p.y >= sy) y1 = sy; else y2 = sy;
			if (p.z >= sz) z1 = sz; else z2 = sz;
			
			
			// update children
			var cn:OctTreeNode;
			if (c == 0) {
				if (n.c1==null) n.c1 = OctTreeNode.node();
				cn = n.c1;
			} else if (c == 1) {
				if (n.c2==null) n.c2 = OctTreeNode.node();
				cn = n.c2;
			} else if (c == 2) {
				if (n.c3==null) n.c3 = OctTreeNode.node();
				cn = n.c3;
			} else if (c == 3){
				if (n.c4==null) n.c4 = OctTreeNode.node();
				cn = n.c4;
			} else if (c == 4) { //CONTINUE FROM HERE
				if (n.c5==null) n.c5 = OctTreeNode.node();
				cn = n.c5;
			} else if (c == 5) {
				if (n.c6==null) n.c6 = OctTreeNode.node();
				cn = n.c6;
			} else if (c == 6) {
				if (n.c7==null) n.c7 = OctTreeNode.node();
				cn = n.c7;
			} else {
				if (n.c8==null) n.c8 = OctTreeNode.node();
				cn = n.c8;
			}
			n.hasChildren = true;
			insert(p,cn,x1,y1,z1,x2,y2,z2);
    	}
		
		private function clear(n:OctTreeNode):void
		{
			if (n.c1 != null) clear(n.c1);
			if (n.c2 != null) clear(n.c2);
			if (n.c3 != null) clear(n.c3);
			if (n.c4 != null) clear(n.c4);
			if (n.c5 != null) clear(n.c5);
			if (n.c6 != null) clear(n.c6);
			if (n.c7 != null) clear(n.c7);
			if (n.c8 != null) clear(n.c8);
			OctTreeNode.reclaim(n);
		}
		
		private function bounds(sim:Simulation3d):void
		{
			var p:Particle3d, dx:Number, dy:Number, dz:Number;
			_x1 = _y1 = _z1 = Number.MAX_VALUE;
			_x2 = _y2 = _z2 = Number.MIN_VALUE;


			// get bounding box
			for (var i:uint = 0; i<sim.particles.length; ++i) {
				p = sim.particles[i] as Particle3d;
				if (p.x < _x1) _x1 = p.x;
				if (p.y < _y1) _y1 = p.y;
				if (p.z < _z1) _z1 = p.z;
				if (p.x > _x2) _x2 = p.x;
				if (p.y > _y2) _y2 = p.y;
				if (p.z > _z2) _z2 = p.z;
			}
			
			// square the box
			dx = _x2 - _x1;
			dy = _y2 - _y1;
			dz = _z2 - _z1;
			if (dx > dy && dx> dz) {
				_y2 = _y1 + dx;
				_z2 = _z1 + dx;
			} else if (dy > dz && dy> dx)  {
				_x2 = _x1 + dy;
				_z2 = _z1 + dy;
			} else {
				_x2 = _x1 + dz;
				_y2 = _y1 + dz;
				
			}
		}
		
		private function isSameLocation(p1:Particle3d, p2:Particle3d):Boolean {
        	return (Math.abs(p1.x - p2.x) < _eps && 
        			Math.abs(p1.y - p2.y) < _eps && 
        			Math.abs(p1.z - p2.z) < _eps);
    	}
		
	} // end of class NBodyForce
}

// -- Helper HexTreeNode class -----------------------------------------------

import org.systemsbiology.visualization.bionetwork.physics3d.Particle3d;

class OctTreeNode
{
	public var mass:Number = 0;
	public var cx:Number = 0;
	public var cy:Number = 0;
	public var cz:Number = 0;
	public var p:Particle3d = null;
	public var c1:OctTreeNode = null;
	public var c2:OctTreeNode = null;
	public var c3:OctTreeNode = null;
	public var c4:OctTreeNode = null;
	public var c5:OctTreeNode = null;
	public var c6:OctTreeNode = null;
	public var c7:OctTreeNode = null;
	public var c8:OctTreeNode = null;
	public var hasChildren:Boolean = false;
	
	// -- Factory ---------------------------------------------------------
	
	private static var _nodes:Array = new Array();
	
	public static function node():OctTreeNode {
		var n:OctTreeNode;
		if (_nodes.length > 0) {
			n = OctTreeNode(_nodes.pop());
		} else {
			n = new OctTreeNode();
		}
		return n;
	}
	
	public static function reclaim(n:OctTreeNode):void {
		n.mass = n.cx = n.cy = n.cz = 0;
		n.p = null;
		n.hasChildren = false;
		n.c1 = n.c2 = n.c3 = n.c4 = n.c5 = n.c6 = n.c7 = n.c8 = null;
		_nodes.push(n);
	}
}