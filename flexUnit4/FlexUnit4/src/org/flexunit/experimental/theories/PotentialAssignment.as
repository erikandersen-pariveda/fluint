package org.flexunit.experimental.theories {
	public class PotentialAssignment implements IPotentialAssignment {
		public var value:Object;
		public var name:String;

		public static function forValue( name:String, value:Object ):PotentialAssignment {
			return new PotentialAssignment( name, value );
		}

		public function PotentialAssignment( name:String, value:Object ) {
			this.name = name;
			this.value = value;
		}

		public function getValue():Object {
			return value;
		}
		
		public function getDescription():String {
			return name;
		}

		public function toString():String {
			return "[" + String( value ) + "]";
		}
	}
}