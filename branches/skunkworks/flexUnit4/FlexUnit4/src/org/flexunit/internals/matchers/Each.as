package org.flexunit.internals.matchers
{
	import org.hamcrest.Matcher;
	
	public class Each {
		public static function eachOne( individual:Matcher ):Matcher {
			return new EachMatcher( individual );
		}	
	}
}

import org.hamcrest.BaseMatcher;
import org.hamcrest.Matcher;
import org.hamcrest.not;
import org.hamcrest.hasItem;
import org.hamcrest.Description;

class EachMatcher extends BaseMatcher {

	private var allItemsAre:Matcher;
	private var individual:Matcher;

	public function EachMatcher( individual:Matcher ):void {
		this.individual = individual;
		allItemsAre = not(hasItem(not(individual)));
	}
	
    override public function matches(item:Object):Boolean {
      return allItemsAre.matches( item );
    }
    
    override public function describeTo(description:Description):void {
		description.appendText("each ");
		individual.describeTo(description);	      
    }
}