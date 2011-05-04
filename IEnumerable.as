package finq
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	public interface IEnumerable
	{
		function aggregate(aggregator:Function, seed:* = null, resultSelector:Function = null):*;
		
		function all(predicate:Function):Boolean;
		
		function any(predicate:Function = null):Boolean;
		
		function asEnumerable():IEnumerable;
		
		function asQueryable():*;
		
		function average(selector:Function):Number;
		
		function cast(type:*):IEnumerable;
		
		function concat(second:IEnumerable):IEnumerable;
		
		function contains(value:*, equalityComparer:* = null):Boolean;
		
		function count(predicate:Function = null):uint;
		
		function defaultIfEmpty(defaultValue:* = undefined):IEnumerable;
		
		function distinct(equalityComparer:* = null):IEnumerable;
		
		function elementAt(index:int):*;
		
		function elementAtorDefault(index:int):*;
		
		function except(second:IEnumerable, equalityComparer:Function = null):IEnumerable;
		
		function first(predicate:Function = null):*;
		
		function firstOrDefault(predicate:Function = null):*;
		
		function forEach(callback:Function, thisObject:* = null):void;
		
		function getElementKeys(keyComparer:* = null):Array;
		
		function getElementKeysDescending():Array;
		
		function groupBy(keySelector:*, elementSelector:* = null, resultAggregator:Function = null, keyEqualityComparer:Function = null):IEnumerable;
	    
	    function groupJoin(inner:IEnumerable, outerKeySelector:*, innerKeySelector:*, resultAggregator:Function, keyEqualityComparer:Function = null):IEnumerable;
	    
	    function intersect(second:IEnumerable, equalityComparer:Function = null):IEnumerable;
	    
	    function join(inner:IEnumerable, outerKeySelector:*, innerKeySelector:*, resultAggregator:Function, keyEqualityComparer:Function = null):IEnumerable;
	    
	    function last(predicate:Function = null):*;
	    
	    function lasttOrDefault(predicate:Function = null):*;
	    
	    function longCount(predicate:Function = null):*;
	    
	    function max(selector:Function = null):*;
	    
	    function min(selector:Function = null):*;
	    
	    function nonPrimitives():IEnumerable;
	    
	    function ofType(type:*):IEnumerable;
	    
	    function orderBy(keySelector:*, keyComparer:Function = null):IEnumerable;
	    
	    function orderByDescending(keySelector:*):IEnumerable;
	    
	    function pop():*;
	    
	    function primitives():IEnumerable;
	    
	    function print(orderedKeys:Array = null, ascendingKeys:Boolean = true, indentation:String = "", outputDebug:Boolean = true):String;
	    
	    function push(...elements):uint;
	    
	    function reverse():IEnumerable;
	    
	    function select(...args):IEnumerable;
	    
	    function selectMany(valueSelector:Function = null):IEnumerable;
	    
	    function sequenceEqual(second:IEnumerable, equalityComparer:Function = null):Boolean;
	    
	    function single(predicate:Function = null):*;
	    
	    function singleOrDefault(predicate:Function = null):*;
	    
	    function skip(count:int):IEnumerable;
	    
	    function skipWhile(predicate:Function):IEnumerable;
	    
	    function sum(selector:Function = null):*;
	    
	    function take(count:int):IEnumerable;
	    
	    function takeWhile(predicate:Function):IEnumerable;
	    
	    function thenBy(keySelector:*, valueComparer:Function = null):IEnumerable;
	    
	    function thenByDescending(keySelector:*):IEnumerable;
	    
	    function toArray():Array;
	    
	    function toArrayCollection():ArrayCollection;
	    
		function toDictionary(keySelector:*, elementSelector:Function = null, keyEqualityComparer:Function = null):Dictionary;
		
		function toFinqObj():FinqObj;
		
		function toList():*;
		
		function toLookup(keySelector:*, elementSelector:Function = null, keyEqualityComparer:Function = null):*;
		
		function union(second:IEnumerable, equalityComparer:Function = null):IEnumerable;
		
		function where(predicate:Function):IEnumerable;		   
	}
	
}