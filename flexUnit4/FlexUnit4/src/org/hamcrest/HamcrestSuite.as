package org.hamcrest {
	import org.hamcrest.collection.IsArrayTest;
	import org.hamcrest.collection.IsArrayWithSizeTest;
	import org.hamcrest.collection.IsCollectionContainingTest;
	import org.hamcrest.core.AllOfTest;
	import org.hamcrest.core.AnyOfTest;
	import org.hamcrest.core.DescribedAsTest;
	import org.hamcrest.core.EveryTest;
	import org.hamcrest.core.IsAnythingTest;
	import org.hamcrest.core.IsEqualTest;
	import org.hamcrest.core.IsInstanceOfTest;
	import org.hamcrest.core.IsNotTest;
	import org.hamcrest.core.IsNullTest;
	import org.hamcrest.core.IsSameTest;
	import org.hamcrest.core.ThrowsTest;
	import org.hamcrest.text.StringContainsTest;
	import org.hamcrest.text.StringEndsWithTest;
	import org.hamcrest.text.StringStartsWithTest;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class HamcrestSuite {
		public var t1:BaseMatcherTest; 
 		public var t2:CustomMatcherTest;
		public var t3:CustomTypeSafeMatcherTest; 
		public var t4:MatcherAssertTest;
		public var t5:TypeSafeMatcherTest; 
		        
		          // core
		public var t6:AllOfTest;
		public var t7:AnyOfTest; 
		public var t8:DescribedAsTest; 
		public var t9:EveryTest;
		public var t10:IsAnythingTest; 
		public var t11:IsEqualTest;
		public var t12:IsInstanceOfTest; 
		public var t13:IsNotTest;
		public var t14:IsNullTest; 
		public var t15:IsSameTest;
		          
		          // collection
		public var t16:IsArrayTest;
		public var t17:IsArrayWithSizeTest;
		public var t18:IsCollectionContainingTest;
		          
		          // text
		public var t19:StringContainsTest;
		public var t20:StringEndsWithTest;
		public var t21:StringStartsWithTest;
		          
		          // extras
		public var t22:ThrowsTest;
 	}
}