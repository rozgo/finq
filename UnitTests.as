package finq {
	import flash.utils.Dictionary;
	
	import flexunit.framework.TestCase;
	
	import mx.collections.ArrayCollection;
	
	public class UnitTests extends TestCase {
		
		private var people:IEnumerable = new FinqObj([ 
		    {name:"Allen Frances", age:11, canCode:false}, 
		    {name:"Burke Madison", age:50, canCode:true}, 
		    {name:"David Charles", age:33, canCode:true}, 
		    {name:"Connor Morgan", age:50, canCode:false}, 
		    {name:"Everett Frank", age:16, canCode:true} 
		]);
		
		private var customers:IEnumerable = new FinqObj([ 
		    {id:1, name:"Gotts"}, 
		    {id:2, name:"Valdes"}, 
		    {id:3, name:"Gauwin"}, 
		    {id:4, name:"Deane"}, 
		    {id:5, name:"Zeeman"} 
		]);
 
		private var orders:IEnumerable = new FinqObj([ 
		    {id:1, description:"Order 1"}, 
		    {id:1, description:"Order 2"}, 
		    {id:4, description:"Order 3"}, 
		    {id:4, description:"Order 4"}, 
		    {id:5, description:"Order 5"} 
		]); 
 
		
		public function test_aggregate():void
		{
			var data:IEnumerable = new FinqObj([-1, 1, 2, 3, 4, 5]);
			var result:int = data.aggregate(function(x, y) {return x + y;});
			assertEquals(result, 14);
			result = data.aggregate(function(x, y) {return x + y;}, 10, function(x) {return 2*x;});
			assertEquals(result, 48);
			data = new FinqObj();
			result = data.aggregate(function(x, y) {return x + y;}, 10, function(x) {return 2*x;});
			assertEquals(result, 0);
		}
		 
		public function test_all():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:Boolean = data.all(function(x) {return x < 4;});
			assertFalse(result);
			result = data.all(function(x) {return x < 10;});
			assertTrue(result);
			data = new FinqObj();
			result = data.all(function(x) {return x < 10;});
			assertTrue(result);
		}
		
		public function test_any():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:Boolean = data.any(function(x) {return x < 4;});
			assertTrue(result);
			result = data.any(function(x) {return x > 10;});
			assertFalse(result);
			data = new FinqObj();
			result = data.any(function(x) {return x < 10;});
			assertFalse(result);
		}
		
		public function test_asEnumerable():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:* = data.asEnumerable();
			assertTrue(result is IEnumerable);
		}
		
		public function test_average():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var av:Number = data.average(function(x) {return 2*x;});
			assertEquals(av, 6);
			av = people.average(function(x) {return x.age;});
			assertEquals(av, 32);
			data = new FinqObj();
			av = data.average(function(x) {return 2*x;});
			assertEquals(av, NaN);
		}
		
		public function test_cast():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var expected:String = "null\nnull\nnull\nnull\nnull\n";
			var result:String = data.cast(String).print(null, true, "", false);
			assertEquals(result, expected);
			expected = "1\n2\n3\n4\n5\n";
			result = data.cast(Number).print(null, true, "", false);
			assertEquals(result, expected);
		}
			
		public function test_concat():void
		{
			var data1:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var data2:IEnumerable = new FinqObj([6, 7]);
			var expected:String = "1\n2\n3\n4\n5\n6\n7\n";
			var result:String = data1.concat(data2).print(null, true, "", false);
			assertEquals(result, expected);
			expected = "1\n2\n3\n4\n5\n";
			result = data1.concat(new FinqObj()).print(null, true, "", false);
			assertEquals(result, expected);
			expected = "6\n7\n";
			result = (new FinqObj() as IEnumerable).concat(data2).print(null, true, "", false);
			assertEquals(result, expected);
		}
		
		public function test_contains():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:Boolean = data.contains(3);
			assertTrue(result);
			result = data.contains(10);
			assertFalse(result);
			result = people.contains({name:"David Charles", age:33, canCode:true});
			assertTrue(result);
			result = people.contains({name:"David Charles", age:32, canCode:true});
			assertFalse(result);
			result = people.contains({name:"David Charles", age:33});
			assertFalse(result);
			result = people.contains(33, function(x, y) {return x.age == y;});
			assertTrue(result);
			result = people.contains(34, function(x, y) {return x.age == y;});
			assertFalse(result);
			result = (new FinqObj()).contains(null);
			assertFalse(result);
			result = data.contains(null);
			assertFalse(result);
		}
		
		public function test_defaultIfEmpty():void
		{
			var data:IEnumerable = new FinqObj();
			var result:IEnumerable = data.defaultIfEmpty();
			assertEquals(result[0], undefined);
			data = new FinqObj([1, 2, 3, 4, 5]);
			result = data.defaultIfEmpty();
			assertEquals(result.count(), 5);
		}
		
		public function test_distinct():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 2, 5]);
			var result:String = data.distinct().print(null, true, "", false);
			assertEquals(result, "1\n2\n3\n5\n");
			var result2:IEnumerable = people.distinct(function(x, y) { return x.age == y.age; });
			assertEquals(result2.count(), 4);
		}
		
		public function test_elementAt():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:int = data.elementAt(3);
			assertEquals(result, 4);
			result = data.elementAt(10);
			assertEquals(result, 0);
		}
		
		public function test_elementAtorDefault():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:int = data.elementAtorDefault(3);
			assertEquals(result, 4);
			result = data.elementAtorDefault(10);
			assertEquals(result, 0);
		}
		
		public function test_except():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:String = data.except(new FinqObj([3, 4])).print(null, true, "", false);
			assertEquals(result, "1\n2\n5\n");
			var result2:IEnumerable = people.except(new FinqObj([
		    	{name:"Connor Morgan", age:50, canCode:false}, 
		    	{name:"Everett Frank", age:16, canCode:true}
		    ]));
		    assertEquals(result2.count(), 3);
		    result2 = people.except(new FinqObj(["Everett Frank", "Connor Morgan"]),
		    	function (x, y) {return x.name == y;});
		    assertEquals(result2.count(), 3);
		}
		
		public function test_first():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:int = data.first();
			assertEquals(result, 1);
			result = data.first(function(x) { return x > 3; });
			assertEquals(result, 4);
			var result2:* = data.first(function(x) { return x > 10; });
			assertEquals(result2, undefined);
		}
		
		public function test_firstOrDefault():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:int = data.first();
			assertEquals(result, 1);
			result = data.first(function(x) { return x > 3; });
			assertEquals(result, 4);
			var result2:* = data.first(function(x) { return x > 10; });
			assertEquals(result2, undefined);
		}
		
		public function test_getElementKeys():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:Array = data.getElementKeys();
			assertEquals(result.length, 0);
			result = people.getElementKeys();
			assertEquals(result[0], "age");
			assertEquals(result[1], "canCode");
			assertEquals(result[2], "name");
			result = people.getElementKeys(function(x, y) { return x < y; });
			assertEquals(result[0], "name");
			assertEquals(result[1], "canCode");
			assertEquals(result[2], "age");
			result = people.getElementKeysDescending();
			assertEquals(result[0], "name");
			assertEquals(result[1], "canCode");
			assertEquals(result[2], "age");
		}
		
		public function test_groupBy():void
		{
			var result:IEnumerable = people.groupBy("canCode");
			assertEquals(result[0].key, "false");
			assertEquals(result[1].key, "true");
			assertTrue( (result[0].value as IEnumerable).sequenceEqual( new FinqObj([
				{age:11, canCode:false, name:"Allen Frances"},  
				{age:50, canCode:false, name:"Connor Morgan"}
			])) );
			assertTrue( (result[1].value as IEnumerable).sequenceEqual( new FinqObj([
				{name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Everett Frank", age:16, canCode:true}
			])) );
			result = people.groupBy( 
			    function(x) {     
			        if ( x.age > 0  && x.age <= 20 ) return "adolescent"; 
			        if ( x.age > 20 && x.age <= 35 ) return "young"; 
			        if ( x.age > 35 )                return "veteran"; 
			    }, 
			    "name"            
			);
			assertEquals(result[0].key, "adolescent");
			assertEquals(result[1].key, "veteran");
			assertEquals(result[2].key, "young");
			assertTrue( (result[0].value as IEnumerable).sequenceEqual( new FinqObj([
				"Allen Frances", "Everett Frank" 
			])) );
			assertTrue( (result[1].value as IEnumerable).sequenceEqual( new FinqObj([
				"Burke Madison", "Connor Morgan"
			])) );
			assertTrue( (result[2].value as IEnumerable).sequenceEqual( new FinqObj([
				"David Charles"
			])) );
		}
		
		public function test_groupJoin():void
		{
			var result:IEnumerable = 
			customers.groupJoin(             
			    orders,                      
			    "id",                        
			    "id",                        
			    function(c, g) {             
			        return {customerName:c.name, orders:g.select(function(order) { return order.description; })}; 
				}
			);
			assertEquals(result[0].customerName, "Gotts");
			assertEquals(result[1].customerName, "Valdes");
			assertEquals(result[2].customerName, "Gauwin");
			assertEquals(result[3].customerName, "Deane");
			assertEquals(result[4].customerName, "Zeeman");
			assertEquals(result[0].orders[0], "Order 1");
			assertEquals(result[0].orders[1], "Order 2");
			assertEquals(result[0].orders.length, 2);
			assertEquals(result[1].orders.length, 0);
			assertEquals(result[2].orders.length, 0);
			assertEquals(result[3].orders[0], "Order 3");
			assertEquals(result[3].orders[1], "Order 4");
			assertEquals(result[3].orders.length, 2);
			assertEquals(result[4].orders[0], "Order 5");
			assertEquals(result[4].orders.length, 1);
		}
		
		public function test_intersects():void
		{
			var data1:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var data2:IEnumerable = new FinqObj([4, 5, 6, 7]);
			var result:String = data1.intersect(data2).print(null, true, "", false);
			//assertEquals(result, "1\n2\n3\n4\n5\n6\n7\n")
			assertEquals(result, "4\n5\n");
			result = data1.intersect(new FinqObj()).print(null, true, "", false);
			assertEquals(result, "empty\n");
			result = (new FinqObj()).intersect(data2).print(null, true, "", false);
			assertEquals(result, "empty\n");
			var data3:IEnumerable = new FinqObj([
				{id:3, name:"Gauwin"}, 
		    	{id:4, name:"Deane"}, 
		    	{id:6, name:"Reeman"}
			]);
			var result2:IEnumerable = customers.intersect(data3);
			assertTrue(result2.sequenceEqual(new FinqObj([
				{id:3, name:"Gauwin"}, 
		    	{id:4, name:"Deane"}
			])));
			var data4:IEnumerable = new FinqObj([3, 4, 6]);
			result2 = customers.intersect(data4, function(x, y) { return x.id == y; });
			assertTrue(result2.sequenceEqual(new FinqObj([
				{id:3, name:"Gauwin"}, 
		    	{id:4, name:"Deane"}
			])));
		}
		
		public function test_join():void
		{
			var result:IEnumerable = customers.join(      
				orders,          
				"id",            
				"id",            
				function(c, o) { 
        			return { customerName:c.name, order:o.description }; 
    			} 
			);
			assertTrue(result.sequenceEqual(new FinqObj([
				{customerName:"Gotts", order:"Order 1"},  
		        {customerName:"Gotts", order:"Order 2"},  
		        {customerName:"Deane", order:"Order 3"},  
		        {customerName:"Deane", order:"Order 4"},  
		        {customerName:"Zeeman", order:"Order 5"}			
			])));
			result = customers.join(      
				orders,          
				function(x) {return x.id;},            
				function(x) {return x.id;},            
				function(c, o) { return { customerName:c.name, order:o.description }; },
    			function(x, y) { return x == y; }
			);
			assertTrue(result.sequenceEqual(new FinqObj([
				{customerName:"Gotts", order:"Order 1"},  
		        {customerName:"Gotts", order:"Order 2"},  
		        {customerName:"Deane", order:"Order 3"},  
		        {customerName:"Deane", order:"Order 4"},  
		        {customerName:"Zeeman", order:"Order 5"}			
			])));
			result = (new FinqObj() as IEnumerable).join(      
				(new FinqObj()),          
				"id",            
				"id",            
				function(c, o) { 
        			return { customerName:c.name, order:o.description }; 
    			});
    		assertTrue(result.sequenceEqual(new FinqObj()));    		
		}
		
		public function test_last():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:int = data.last();
			assertEquals(result, 5);
			result = data.last(function(x) { return x < 4; });
			assertEquals(result, 3);
			var result2:* = data.last(function(x) { return x > 10; });
			assertEquals(result2, undefined);
		}
		
		public function test_lastOrDefault():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:int = data.last();
			assertEquals(result, 5);
			result = data.last(function(x) { return x < 4; });
			assertEquals(result, 3);
			var result2:* = data.last(function(x) { return x > 10; });
			assertEquals(result2, undefined);
		}
		
		public function test_max():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5, -1, 3 , 2]);
			assertEquals(data.max(), 5);
			assertEquals(people.max(function(x) { return x.age; }).age, 50);
			assertEquals((new FinqObj()).max(), undefined);
		}
		
		public function test_min():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5, -1, 3 , 2]);
			assertEquals(data.min(), -1);
			assertEquals(people.min(function(x) { return x.age; }).age, 11);
			assertEquals((new FinqObj()).min(), undefined);
		}
		
		public function test_nonPrimitives():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 
				{name:"Allen Frances", age:11, canCode:false}, 
    			{name:"Burke Madison", age:50, canCode:true} 
    		]);
			assertTrue(data.nonPrimitives().sequenceEqual(new FinqObj([
				{name:"Allen Frances", age:11, canCode:false}, 
    			{name:"Burke Madison", age:50, canCode:true}
			])) );
		}
		
		public function test_ofType():void
		{
			var data:IEnumerable = new FinqObj([1, "2", "3", 4, 5]);
			assertTrue(data.ofType(Number).sequenceEqual(new FinqObj([1, 4, 5])));
			assertTrue(data.ofType(String).sequenceEqual(new FinqObj(["2", "3"])));
			assertTrue(data.ofType(Boolean).sequenceEqual(new FinqObj()));
		}
		
		public function test_orderBy():void
		{
			var data:IEnumerable = new FinqObj([5, 3, 2, 1, 4]);
			var result:IEnumerable = data.orderBy(
					function(x) { return x; }
				);
			assertEquals(result.print(null, true, "", false), "1\n2\n3\n4\n5\n");
			result = data.orderBy(
					function(x) { return x; },
					function(x, y) { return x < y; }
				);
			assertEquals(result.print(null, true, "", false), "5\n4\n3\n2\n1\n");
			result = people.orderBy("name");
			assertTrue(result.sequenceEqual(new FinqObj([
					{age:11, canCode:false, name:"Allen Frances"},  
					{age:50, canCode:true, name:"Burke Madison"},
					{age:50, canCode:false, name:"Connor Morgan"}, 
					{age:33, canCode:true, name:"David Charles"}, 
					{age:16, canCode:true, name:"Everett Frank"}
			])) );
			result = people.orderBy( 
			    function(x) { return x.name; },    
			    function(x:String, y:String) {    
			        if (x.toUpperCase() < y.toUpperCase()) return +1; 
			        if (x.toUpperCase() == y.toUpperCase()) return 0; 
			        return -1;  
    			} 
 			);
 			assertTrue(result.sequenceEqual(new FinqObj([
					{age:16, canCode:true, name:"Everett Frank"},  
					{age:33, canCode:true, name:"David Charles"},
					{age:50, canCode:false, name:"Connor Morgan"}, 
					{age:50, canCode:true, name:"Burke Madison"}, 
					{age:11, canCode:false, name:"Allen Frances"}
			])) );
		}
		
		public function test_orderByDescending():void
		{
			var data:IEnumerable = new FinqObj([5, 3, 2, 1, 4]);
			var result:IEnumerable = data.orderByDescending(
					function(x) { return x; }
				);
			assertEquals(result.print(null, true, "", false), "5\n4\n3\n2\n1\n");
			result = people.orderByDescending("name");
			assertTrue(result.sequenceEqual(new FinqObj([
					{age:16, canCode:true, name:"Everett Frank"},  
					{age:33, canCode:true, name:"David Charles"},
					{age:50, canCode:false, name:"Connor Morgan"}, 
					{age:50, canCode:true, name:"Burke Madison"}, 
					{age:11, canCode:false, name:"Allen Frances"}
			])) );
			result = people.orderByDescending( 
			    function(x) { return x.name; }   
 			);
 			assertTrue(result.sequenceEqual(new FinqObj([
					{age:16, canCode:true, name:"Everett Frank"},  
					{age:33, canCode:true, name:"David Charles"},
					{age:50, canCode:false, name:"Connor Morgan"}, 
					{age:50, canCode:true, name:"Burke Madison"}, 
					{age:11, canCode:false, name:"Allen Frances"}
			])) );
		}
		
		public function test_pop():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3]);
			assertEquals(data.count(), 3);
			assertEquals(data.pop(), 3);
			assertEquals(data.count(), 2);
			assertEquals(data.pop(), 2);
			assertEquals(data.count(), 1);
			assertEquals(data.pop(), 1);
			assertEquals(data.count(), 0);
			assertEquals(data.pop(), undefined);
			assertEquals(data.count(), 0);
		}
		
		public function test_primitives():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 
				{name:"Allen Frances", age:11, canCode:false}, 
    			{name:"Burke Madison", age:50, canCode:true} 
    		]);
			assertTrue(data.primitives().sequenceEqual(new FinqObj([1, 2, 3])));
		}
		
		public function test_push():void
		{
			var data:IEnumerable = new FinqObj([]);
			assertEquals(data.count(), 0);
			data.push(1);
			assertTrue(data.sequenceEqual(new FinqObj([1])));
			data.push(2);
			assertTrue(data.sequenceEqual(new FinqObj([1, 2])));
			data.push(3, 4);
			assertTrue(data.sequenceEqual(new FinqObj([1, 2, 3, 4])));
		}
		
		public function test_reverse():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			assertTrue(data.reverse().sequenceEqual(new FinqObj([5, 4, 3, 2, 1])));
			data = new FinqObj();
			assertEquals(data.reverse().count(), 0);
		}
		
		public function test_select():void
		{
			var data:IEnumerable = new FinqObj(["orange", "banana", "apple", "grapes", "mango"]);
			assertTrue(
				data.select(function(x) { return x.length; }).sequenceEqual(
				new FinqObj([6, 6, 5, 6 , 5])));
			assertTrue(
				data.select(function(x) { return { type:x, length:x.length }; }).sequenceEqual(
				new FinqObj([
					{length:6, type:"orange"},  
					{length:6, type:"banana"}, 
					{length:5, type:"apple"},  
					{length:6, type:"grapes"},  
					{length:5, type:"mango"} 
				])));
			assertTrue(
				people.select("name", "age").sequenceEqual(
				new FinqObj([
					{name:"Allen Frances", age:11}, 
				    {name:"Burke Madison", age:50}, 
				    {name:"David Charles", age:33}, 
				    {name:"Connor Morgan", age:50}, 
				    {name:"Everett Frank", age:16}  
				])));
		}
		
		public function test_sequenceEqual():void
		{
			var data:IEnumerable = new FinqObj();
			assertTrue(data.sequenceEqual(new FinqObj()));
			data = new FinqObj([1, 2, "3"]);
			assertTrue(data.sequenceEqual(new FinqObj([1, 2, "3"])));
			assertFalse(data.sequenceEqual(new FinqObj([1, "3"])));
			assertFalse(data.sequenceEqual(new FinqObj([1, 4, "3"])));
			assertFalse(data.sequenceEqual(new FinqObj([1, 2, 3])));
			assertTrue(people.sequenceEqual(new FinqObj([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			])));
			assertFalse(people.sequenceEqual(new FinqObj([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:"16", canCode:true} 
			])));
			assertFalse(people.sequenceEqual(new FinqObj([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:17, canCode:true} 
			])));
			assertFalse(people.sequenceEqual(new FinqObj([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			])));
			assertFalse(people.sequenceEqual(new FinqObj([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			])));
			assertFalse(people.sequenceEqual(new FinqObj([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50},
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			])));
		}
		
		public function test_single():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:Boolean; 
			try {
				data.single();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			assertFalse(result);
			data = new FinqObj();
			try {
				data.single();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			assertFalse(result);
			data = new FinqObj([1]);
			try {
				data.single();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			assertTrue(result);
		}
		
		public function test_singleOrDefault():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var result:Boolean; 
			try {
				data.singleOrDefault();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			assertFalse(result);
			data = new FinqObj();
			try {
				data.singleOrDefault();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			assertTrue(result);
			data = new FinqObj([1]);
			try {
				data.singleOrDefault();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			assertTrue(result);
		}
		
		public function test_skip():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			assertTrue(data.skip(3).sequenceEqual(new FinqObj([4, 5])));
			assertEquals(data.skip(10).count(), 0);
			assertTrue(people.skip(3).sequenceEqual(new FinqObj([
				{name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true}	
			])));
			assertEquals(people.skip(10).count(), 0);
			assertEquals((new FinqObj()).skip(10).count(), 0);
		}
		
		public function test_skipWhile():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			assertTrue(data.skipWhile(function(x){return x<4}).sequenceEqual(new FinqObj([4, 5])));
			assertEquals((new FinqObj()).skipWhile(function(x){return x < 4}).count(), 0);
			var result:IEnumerable = customers.skipWhile(function(x) {
				return x.name != "Gauwin";
			});
			assertTrue(result.sequenceEqual(new FinqObj([
			    {id:3, name:"Gauwin"}, 
			    {id:4, name:"Deane"}, 
			    {id:5, name:"Zeeman"}
		    ])));
		}
		
		public function test_sum():void
		{
			var data:IEnumerable = new FinqObj([-1, 1, 2, 3, 4, 5]);
			var result:int = data.sum(function(x) {return x;});
			assertEquals(result, 14);
			var result2:String = data.sum(function(x:int):String {return x.toString();});
			assertEquals(result2, "-112345");
		}
		
		public function test_take():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			assertTrue(data.take(3).sequenceEqual(new FinqObj([1, 2, 3])));
			assertEquals(data.take(10).count(), 5);
			assertTrue(people.take(3).sequenceEqual(new FinqObj([
				{name:"Allen Frances", age:11, canCode:false}, 
		    	{name:"Burke Madison", age:50, canCode:true}, 
		    	{name:"David Charles", age:33, canCode:true}	
			])));
			assertEquals(people.take(10).count(), 5);
			assertEquals((new FinqObj()).take(10).count(), 0);
		}
		
		public function test_takeWhile():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			assertTrue(data.takeWhile(function(x){return x<4}).sequenceEqual(new FinqObj([1, 2, 3])));
			assertEquals((new FinqObj()).takeWhile(function(x){return x<4}).count(), 0);
			var result:IEnumerable = customers.takeWhile(function(x) {
				return x.name != "Gauwin";
			});
			assertTrue(result.sequenceEqual(new FinqObj([
			    {id:1, name:"Gotts"}, 
		    	{id:2, name:"Valdes"} 
		    ])));
		}
		
		public function test_thenBy():void
		{
			var result:IEnumerable = people.orderBy("canCode").thenBy("name");
			assertTrue(result.sequenceEqual(new FinqObj([
				{name:"Allen Frances", age:11, canCode:false}, 
		    	{name:"Connor Morgan", age:50, canCode:false},
		    	{name:"Burke Madison", age:50, canCode:true}, 
		    	{name:"David Charles", age:33, canCode:true}, 
		    	{name:"Everett Frank", age:16, canCode:true} 	
			])));
			var result2:IEnumerable = people.orderBy("canCode").thenBy(
				function(x) { return x.name; },
				function(x, y) { return x > y; }
			);
			assertTrue(result.sequenceEqual(result2));
		}
		
		public function test_thenByDescending():void
		{
			var result:IEnumerable = people.orderBy("canCode").thenByDescending("name");
			assertTrue(result.sequenceEqual(new FinqObj([
				{name:"Connor Morgan", age:50, canCode:false},
				{name:"Allen Frances", age:11, canCode:false}, 
		    	{name:"Everett Frank", age:16, canCode:true}, 
		    	{name:"David Charles", age:33, canCode:true}, 
		    	{name:"Burke Madison", age:50, canCode:true}	
			])));
			var result2:IEnumerable = people.orderBy("canCode").thenByDescending(
				function(x) { return x.name; }
			);
			assertTrue(result.sequenceEqual(result2));
		}
		
		public function test_toArray():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3]);
			var result:Array = data.toArray();
			assertEquals(result.length, 3);
			assertEquals(result[0], 1);
			assertEquals(result[1], 2);
			assertEquals(result[2], 3);
		}
		
		public function test_toArrayCollection():void
		{
			var data:IEnumerable = new FinqObj([1, 2, 3]);
			var result:ArrayCollection = data.toArrayCollection();
			assertEquals(result.length, 3);
			assertEquals(result[0], 1);
			assertEquals(result[1], 2);
			assertEquals(result[2], 3);
		}
		
		public function test_toDictionary():void
		{
			var i:uint = 0;
			var result:Dictionary = people.toDictionary(
				function(x) {return x.name;},
				function(x) {return (x.name as String).length + i++;},
				function(x, y) {return x.toUpperCase() == y.toUpperCase()}
			);
			assertEquals(result["Allen Frances"], 13);	 
			assertEquals(result["Burke Madison"], 14);
			assertEquals(result["David Charles"], 15);
			assertEquals(result["Connor Morgan"], 16);
			assertEquals(result["Everett Frank"], 17);
		}
		
		public function test_toFinqObj():void
		{
			var data:IEnumerable = new FinqObj([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			]);
			var result:IEnumerable = data.toFinqObj();
			assertTrue(result.sequenceEqual(people)); 
		}
		
		public function test_union():void
		{
			var data1:IEnumerable = new FinqObj([1, 2, 3, 4, 5]);
			var data2:IEnumerable = new FinqObj([4, 5, 6, 7]);
			var result:String = data1.union(data2).print(null, true, "", false);
			assertEquals(result, "1\n2\n3\n4\n5\n6\n7\n");
			result = data1.union(new FinqObj()).print(null, true, "", false);
			assertEquals(result, "1\n2\n3\n4\n5\n");
			result = (new FinqObj()).union(data2).print(null, true, "", false);
			assertEquals(result, "4\n5\n6\n7\n");
			var data3:IEnumerable = new FinqObj([
				{id:3, name:"Gauwin"}, 
		    	{id:4, name:"Deane"}, 
		    	{id:6, name:"Reeman"}
			]);
			var result2:IEnumerable = customers.union(data3);
			assertTrue(result2.sequenceEqual(new FinqObj([
				{id:1, name:"Gotts"}, 
			    {id:2, name:"Valdes"}, 
			    {id:3, name:"Gauwin"}, 
			    {id:4, name:"Deane"}, 
			    {id:5, name:"Zeeman"},
		    	{id:6, name:"Reeman"}
			])));
			var data4:IEnumerable = new FinqObj([3, 4, 6]);
			result2 = customers.union(data4, function(x, y) { return x.id == y; });
			assertTrue(result2.sequenceEqual(new FinqObj([
				{id:1, name:"Gotts"}, 
			    {id:2, name:"Valdes"}, 
			    {id:3, name:"Gauwin"}, 
			    {id:4, name:"Deane"}, 
			    {id:5, name:"Zeeman"},
		    	6
			])));
		}
		
		public function test_where():void
		{
			var data:IEnumerable = new FinqObj([6, 8, 3, 4, 7]);
			var result:IEnumerable = data.where(
				function(x) {return x > 5;}
			);
			assertTrue(result.sequenceEqual(new FinqObj([6, 8, 7])));
			result = people.where(function(x) { return x.canCode == true; });
			assertTrue(result.sequenceEqual(new FinqObj([
				{name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Everett Frank", age:16, canCode:true}
			])));
			result = (new FinqObj()).where(function(x) { return x.canCode == true; });
			assertTrue(result.sequenceEqual(new FinqObj()));
		}
		
	}
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
