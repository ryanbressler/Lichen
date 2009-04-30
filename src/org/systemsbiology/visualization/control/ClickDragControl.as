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

package org.systemsbiology.visualization.control{
import flare.vis.controls.Control;
import flare.vis.data.DataSprite;
import flare.vis.events.SelectionEvent;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

[Event(name="select",   type="flare.vis.events.SelectionEvent")]
[Event(name="deselect", type="flare.vis.events.SelectionEvent")]

/**
 */
public class ClickDragControl extends Control
{
	private var _timer:Timer;
	private var _cur:DisplayObject;
	private var _clicks:uint = 0;
	private var _clear:Boolean = false;
	private var _event:MouseEvent = null;
	
	private var _mx:Number, _my:Number;
	
	/** The number of clicks needed to trigger a click event. Setting this
	 *  value to zero effectively disables the click control. */
	public var numClicks:uint;
	
	/**
	 * Flag indicating if the control is also acting as dragcontrol
	 */
	
	public var drag:Boolean;
	
	/** The maximum allowed delay (in milliseconds) between clicks. 
	 *  The delay determines the maximum time interval between a
	 *  mouse up event and a subsequent mouse down event. */
	public function get clickDelay():Number { return _timer.delay; }
	public function set clickDelay(d:Number):void { _timer.delay = d; }
	
	/** Indicates if drag should be followed at frame rate only.
	 *  If false, drag events can be processed faster than the frame
	 *  rate, however, this may pre-empt other processing. */
	public var trackAtFrameRate:Boolean = false;
	
	/** The active item currently being dragged. */
	public function get activeItem():DisplayObject { return _cur; }
	
	// --------------------------------------------------------------------
	
	/**
	 * Creates a new ClickDragControl.
	 * @param filter a Boolean-valued filter function indicating which
	 *  items should trigger hover processing
	 * @param numClicks the number of clicks
	 * @param drag if true the control also acts as a DragControl
	 * @param onClick an optional SelectionEvent listener for click events
	 */
	public function ClickDragControl(filter:*=null, numClicks:uint=1,drag:Boolean = true,
		onClick:Function=null, onClear:Function=null)
	{
		this.filter = filter;
		this.numClicks = numClicks;
		_timer = new Timer(150);
		_timer.addEventListener(TimerEvent.TIMER, onTimer);
		if (onClick != null)
			addEventListener(SelectionEvent.SELECT, onClick);
		if (onClear != null)
			addEventListener(SelectionEvent.DESELECT, onClear);
		
		this.drag = drag;
	}
	
	/** @inheritDoc */
	public override function attach(obj:InteractiveObject):void
	{
		if (obj==null) { detach(); return; }
		super.attach(obj);
		if (obj != null) {
			if (drag) {
				obj.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			} else {
				obj.addEventListener(MouseEvent.CLICK, onClick);
			}
		}
	}
	
	/** @inheritDoc */
	public override function detach():InteractiveObject
	{
		if (_object != null) {
			_object.removeEventListener(MouseEvent.CLICK, onClick);
			_object.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_object.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			_object.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
		}
		return super.detach();
	}
	
	// -----------------------------------------------------
	
	private function onDown(event:MouseEvent):void // only called if the drag flag is set
	{
		_timer.stop();
		
		var s:Sprite = event.target as Sprite;
		if (s==null) return; // exit if not a sprite
		
		if (_filter==null || _filter(s)) {
			_cur = s;
			_mx = _object.mouseX;
			_my = _object.mouseY;
			if (_cur is DataSprite) (_cur as DataSprite).fix();

			if (!_cur.stage.hasEventListener(MouseEvent.MOUSE_MOVE)) {
				_cur.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			}
			_object.addEventListener(MouseEvent.CLICK, onClick);
			
			event.stopPropagation();
		}
		
	}
	
	private function onDrag(event:Event) : void {
		var x:Number = _object.mouseX;
		if (x != _mx) {
			_cur.x += (x - _mx);
			_mx = x;
		}
		
		var y:Number = _object.mouseY;
		if (y != _my) {
			_cur.y += (y - _my);
			_my = y;
		}
		
		_object.removeEventListener(MouseEvent.CLICK, onClick);     //dragging -> no click event
		_object.stage.addEventListener(MouseEvent.MOUSE_UP, onUp);  
	}
	
	private function onClick(event:MouseEvent):void
	{
		var n:DisplayObject = event.target as DisplayObject;
		if (n==null || (_filter!=null && !_filter(n))) {
			_clicks++;
			_clear = true;
		} else if (_cur != n) {
			_clear = false;
			_clicks = 1;
			_cur = n;
		} else {
			_clicks++;
		}
		_event = event;
		_timer.start();
		
		_object.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
	}
	
	private function onUp(event:MouseEvent) : void {
		if (_cur != null) {
			_cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			_cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			
			if (_cur is DataSprite) (_cur as DataSprite).unfix();
			event.stopPropagation();
		}
		_cur = null;
	}
	
	private function onTimer(event:Event=null):void
	{
		if (_clicks == numClicks && _cur) {
			var type:String = _clear ? SelectionEvent.DESELECT 
									 : SelectionEvent.SELECT;
			if (hasEventListener(type))
				dispatchEvent(new SelectionEvent(type, _cur, _event));
			if (_clear) _cur = null;
		}
		_timer.stop();
		_clicks = 0;
		_event = null;
		_clear = false;
		
		_cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
	}
	
} // end of class ClickDragControl
}