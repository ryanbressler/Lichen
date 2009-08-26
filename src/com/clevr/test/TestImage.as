/* AS3
	Copyright 2007 Sphex LLP

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	    http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

package com.clevr.test {
	
	import flash.events.*;
	import com.clevr.graphics.*;
	import flash.geom.*;
	import flash.display.*;
	import flash.filters.*;
	import mx.core.*;
	import flash.net.*;
	
	/*
	* 	Test of histogram stretching.
	*
	* 	@langversion ActionScript 3.0
	*	@playerversion Flash 9.0
	*
	*	@author Matt Kane
	* 	@since  24.07.2007
	*/	
	public class TestImage extends EventDispatcher {
		
		public function TestImage(url:String){
			super();
			var urlReq:URLRequest = new URLRequest(url);
			var ldr:Loader = new Loader();
			
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void {
				processImage(e);
			});
			ldr.load(urlReq);
			
		}
		
		private function processImage(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, processImage);
			var ldr:Loader = e.target.loader;
			original = new BitmapData(ldr.width, ldr.height);
			original.draw(ldr);
			histogram = new Histogram(original);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function get originalImage():UIComponent {
			var u:UIComponent = new UIComponent();
			u.addChild(new Bitmap(original));
			return u;
		}
		
		public function correctedImage(threshold:int):UIComponent {
			var u:UIComponent = new UIComponent();
			corrected = original.clone();
			var t:ColorTransform = histogram.stretchTransform(threshold);
			corrected.colorTransform(new Rectangle(0, 0, original.width / 2, original.height), t);
			trace(corrected);
			u.addChild(new Bitmap(corrected));
			return u;
		}
		
		public function colorTransform(percent:Number):ColorTransform {
			if (percent < 0) {
				return histogram.stretchTransform(1, 100 - (-50 * percent));
			}
			var threshold:int = ((original.width * original.height) / 256) * (percent / 100);
			return histogram.stretchTransform(threshold);
		}
		
		private var histogram:Histogram;
		private var original:BitmapData;
		private var corrected:BitmapData;
	}
	
}
