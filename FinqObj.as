package finq
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	public dynamic class FinqObj extends Array implements IEnumerable
	{
		private static var lastOrderedBy:* = null;
		
		public function FinqObj(initVal:* = null)
		{
			super();
			if (initVal == null) return;
			copyFrom(initVal);
		}
		
		public function copyFrom(obj:*):void
		{
			this.splice(0, this.length);
			try {
				obj.forEach(function(e:*, i:int, r:Array):void { this.push(e); }, this);
			} catch (e:Error) {
				throw new Error("FinqObj.copyFrom(): copy source must be a numeric indexed array");
			}
		}
		
	    public function where(predicate:Function):IEnumerable
	    {
	    	var result:IEnumerable = new FinqObj();
	    	(this as Array).forEach(function(e:*, i:int, r:Array):void {
	    		try {
	    			if (predicate(e, i)) result.push(e);
	    		} catch (err:Error) {
	    			if (predicate(e)) result.push(e);
	    		}
	    	});
	    	return result;
	    }
	    
	    public function select(...args):IEnumerable
	    {
	    	var result:IEnumerable = new FinqObj();
	    	if (args.length == 0) {
	    		(result as FinqObj).copyFrom(this);
	    		return result;
	    	}
	    	var valueSelector:Function = args[0] as Function;
	    	if (valueSelector != null) {
	    		(this as Array).forEach(function(e:*, i:int, r:Array):void {
	    			try { 
	    				result.push(valueSelector(e, i));
	    			} catch (err:Error) {
	    				result.push(valueSelector(e));
	    			}
	    		});
	    	} else {
	    		(this as Array).forEach(function(e:*, i:int, r:Array):void {
	    			var record:Object = new Object();
	    			for each (var keySelector:* in args) {
						record[keySelector] = e[keySelector];
	    			}
	    			result.push(record);
	    		});
	    	}
	    	return result;	    	
	    }
	    
	    public function join(inner:IEnumerable, outerKeySelector:*, innerKeySelector:*,
	    						resultAggregator:Function, keyEqualityComparer:Function = null):IEnumerable
	    {
	    	var result:IEnumerable = new FinqObj();
			for each (var x:* in this) {
				for each (var y:* in inner) { 
					var first:* = _getValue(outerKeySelector, x);
					var second:* = _getValue(innerKeySelector, y);
					var equal:Boolean;
					if (keyEqualityComparer != null) {
						equal = keyEqualityComparer(first, second);
					} else {
						equal = (first === second);
					}
					if (equal) {
						result.push(resultAggregator(x, y));
					}
				};
			};
	    	return result;
	    }
	    
	    public function forEach(callback:Function, thisObject:* = null):void
	    {
	    	(this as Array).forEach(callback, thisObject);
	    }
	    
	    public function orderBy(keySelector:*, keyComparer:Function = null):IEnumerable
	    {
	    	return _orderBy(keySelector, true, keyComparer);
	    }
	    
	    public function orderByDescending(keySelector:*):IEnumerable
	    {
	    	return _orderBy(keySelector, false, null);
	    }
	    
	    private function _orderBy(keySelector:*, ascending:Boolean, keyComparer:Function):IEnumerable
	    {
	    	var result:FinqObj = new FinqObj(this);
	    	_sort(result, keySelector, ascending, keyComparer);
	    	lastOrderedBy = keySelector;
	    	return result;
	    }
	    
	    public function thenBy(keySelector:*, valueComparer:Function = null):IEnumerable
	    {
	    	return (new FinqObj(this))._thenBy(keySelector, true, valueComparer);
	    }
	    
	    public function thenByDescending(keySelector:*):IEnumerable
	    {
	    	return (new FinqObj(this))._thenBy(keySelector, false, null);
	    }
	    
	    private function _thenBy(keySelector:*, ascending:Boolean, valueComparer:Function):IEnumerable
	    {
	    	if (this.length == 0) return this;
	    	if (lastOrderedBy == null) return this;
	    	var lastValue:* = _getValue(lastOrderedBy, this[0]);
	    	var startIndex:int = 0;
	    	var endIndex:int = 0;
	    	var result:Array = [];
	    	for each (var e:* in this) {
	    		if (lastValue != _getValue(lastOrderedBy, e)) {
	    			var temp:Array = this.slice(startIndex, endIndex);
	    			if (temp.length > 1) _sort(temp, keySelector, ascending, valueComparer);
		    		result = result.concat(temp);
	    			startIndex = endIndex;
	    			lastValue = _getValue(lastOrderedBy, e);
	    		}
	    		endIndex++;
	    	}
	    	var last:Array = this.slice(startIndex, endIndex);
	    	if (last.length > 1) _sort(last, keySelector, ascending, valueComparer);
		    result = result.concat(last);
	    	this.copyFrom(result);
	    	lastOrderedBy = keySelector;
	    	return this;
	    }
	    
	    public function groupBy(keySelector:*, elementSelector:* = null, 
	    	resultAggregator:Function = null, keyEqualityComparer:Function = null):IEnumerable
	    {
	    	var temp:Dictionary = new Dictionary(true);
	    	var result:IEnumerable = new FinqObj();
	    	if (elementSelector == null) {
	    		elementSelector = function(x:*):* { return x; };
	    	}
	    	if (keyEqualityComparer == null) {
	   			keyEqualityComparer = function(x:*, y:*):Boolean { return x === y; };
	   		}
	    	(this as Array).forEach(function(e:*, i:int, r:Array):void {
	    		var key:* = _getValue(keySelector, e); 
	    		if (_distinctKeys(key, temp, keyEqualityComparer)) {
	    			temp[key] = new FinqObj();
	    		}
	    		(temp[key] as Array).push(_getValue(elementSelector, e));
	    	});
	    	var keys:Array = _getKeys(temp);
	    	for each (var k:* in keys) {
	    		var group:Object = new Object();
	    		group.key = k;
	    		group.value = temp[k];
	    		result.push((resultAggregator == null)? group :
	    			resultAggregator(group.key, group.value));
	    	}
	    	return result;
	    }
	    
	    public function print(orderedKeys:Array = null, ascendingKeys:Boolean = true,
	    	indentation:String = "", outputDebug:Boolean = true):String
	    {
	    	var result:String = "";
			if (this.length == 0) {
				outputDebug? trace("empty") : false;
				return "empty\n";
			}
			for each (var e:* in this) {
	    		var line:String = indentation;
	    		var keys:Array;
	    		if (orderedKeys == null) {
		    		keys = _getKeys(e, ascendingKeys);
	    		} else {
	    			keys = orderedKeys;
	    		} 
	    		if (keys.length == 0) {
	    			outputDebug? trace(indentation + e) : false;
	    			result += indentation + e + "\n";
	    			continue;
	    		}
	    		for each (var field:* in keys) {
    				line += field + ":" + e[field] + "    \t";
    			}
    			line = line.substr(0, line.length-3);
	    		outputDebug? trace(line) : false;
	    		result += line + "\n"
	    	} 
	    	return result;
	    }
	    
	    public function getElementKeys(keyComparer:* = null):Array
	    {
	    	if (this.length == 0) return [];
	    	return _getKeys(this[0], true, keyComparer);
	    }
	    
	    public function getElementKeysDescending():Array
	    {
	    	if (this.length == 0) return [];
	    	return _getKeys(this[0], false, null);	
	    }
	    
	    private static function _getKeys(obj:*, ascending:Boolean = true, keyComparer:Function = null):Array
	    {
	    	var keys:Array = [];
	    	var first:* = obj;
	    	if (first != null) { 
		    	for (var key:* in first) {
		    		keys.push(key);
		    	}
		    }
		    if (keyComparer != null) {
		    	keys.sort(function(x:*, y:*):int {
		    		return keyComparer(x, y);
		    	});
		    } else {
		    	var dir:int = ascending? +1 : -1;
		    	keys.sort(function(x:*, y:*):int {
		    		if (x < y) return -dir;
		    		if (x === y) return 0;
		    		return dir;
		    	});
		    }
	    	return keys;
	    }
	    
	    private static function _sort(obj:*, keySelector:*, ascending:Boolean, keyComparer:Function = null):void
	    {
	    	if (keyComparer != null) {
	    		obj.sort(function(x:*, y:*):int {
		    		var first:* = _getValue(keySelector, x);
		    		var second:* = _getValue(keySelector, y);
		    		var result:* = keyComparer(first, second);
		    		if (result is Boolean) return result? +1 : -1;
		    		return result;
		    	});
	    	} else {
		    	var dir:int = ascending? +1 : -1; 
		    	obj.sort(function(x:*, y:*):int {
		    		var first:* = _getValue(keySelector, x);
		    		var second:* = _getValue(keySelector, y);
		    		if (first < second) return -dir;
		    		if (first === second) return 0;
		    		return dir;
				});
	    	}
	    }
	    
	    private static function _getValue(selector:*, e:*):*
	    {
	    	return (selector is Function)? selector(e) : e[selector];  
	    }
	    
	    public function all(predicate:Function):Boolean
	    {
	    	return every(predicate, this);	
	    }
	    
	    public function any(predicate:Function = null):Boolean
	    {
	    	return (predicate == null)?  this.length > 0 : this.some(predicate);
	    }
	    
	    public function average(selector:Function):Number
	    {
	    	var result:Number = 0;
	    	(this as Array).forEach(function(e:*, i:*, r:Array):void { result += selector(e); });
	    	return result/this.length;
	    }
	    
	    public function cast(type:*):IEnumerable
	    {
	    	var result:IEnumerable = new FinqObj();
	    	(this as Array).forEach(function(x:*):* { result.push(x as type); });
	    	return result;
	    }
	    
	    public function contains(value:*, equalityComparer:* = null):Boolean
	    {
	    	var equalityClosure:Function = _getEqualityClosure(value, equalityComparer);
	    	return this.some(equalityClosure);
	    }
	    
	    private function _getEqualityClosure(value:*, equalityComparer:*):Function
	    {
	    	var equalityClosure:Function;
	    	if (equalityComparer != null) {
	    		if (!(equalityComparer is Function)) {
	    			var key:String = equalityComparer; 
	    			equalityComparer = function(x:*, y:*):Boolean {
	    				return x[key] === y[key];
	    			}; 
	    		} 
	    		equalityClosure = function(x:* , i:int = 0, r:Array = null):Boolean {
		    		return equalityComparer(x, value);
		    	}
	    	} else {
	    		var keys:Array = _getKeys(value);
	    		if (keys.length == 0) {  
			    	equalityClosure = function(x:* , i:int = 0, r:Array = null):Boolean {
		    			return x === value;
		    		}
		    	} else {
		    		equalityClosure = function(x:* , i:int = 0, r:Array = null):Boolean {
		    			if (_getKeys(x).length != keys.length) return false;	
						for each (var key:* in keys) {
							if (value[key] !== x[key]) return false	
						}									    		
			    		return true;
			    	}
			    }
		    }
	    	return equalityClosure;
	    }	    
	    
	    public function count(predicate:Function = null):uint
	    {
	    	if (predicate == null) return this.length; 
	    	var result:uint = 0;
	    	(this as Array).forEach(function(e:*, i:*, r:Array):void {
	    		if (predicate(e)) result++;
	    	});
	    	return result;
	    }
	    
	    public function longCount(predicate:Function = null):*		
	    {
	    	throw new Error("FinqObj.toLookUp(): not implemented");		
	    }
	    
	    public function defaultIfEmpty(defaultValue:* = undefined):IEnumerable
	    {
	    	if (this.length == 0) {
	    		return new FinqObj([defaultValue]);	
	    	}
	    	return new FinqObj(this);
	    }
	    
	    public function elementAt(index:int):*
	    {
	    	return this[index];
	    }
	    
	    public function elementAtorDefault(index:int):*
	    {
	    	return this[index];
	    }
	    
	    public function distinct(equalityComparer:* = null):IEnumerable
	    {
	    	var result:IEnumerable = new FinqObj();
	    	(this as Array).forEach(function(m:*, i:int, r:Array):void {
				if (!result.contains(m, equalityComparer)) result.push(m);
			});
	    	return result;
	    }
	    
	    public function except(second:IEnumerable, equalityComparer:Function = null):IEnumerable
	    {
	    	var result:IEnumerable = new FinqObj();
	    	var equalityComparer2:Function;
	    	if (equalityComparer != null ) {
	    		equalityComparer2 = function(x:*, y:*):Boolean {
	    			return equalityComparer(y, x);
	    		}
	    	} else { 
	    		equalityComparer2 = null;
	    	}
			(this as Array).forEach(function(m:*, i:int, r:Array):void {
				if (!second.contains(m, equalityComparer2)) result.push(m);
			});
			return result;
	    }
	    
	    public function first(predicate:Function = null):*
	    {
	    	if (predicate == null) return this[0];
	    	for each (var e:* in this) {
	    		if (predicate(e)) {
	    			return e;
	    		}
	    	}
	    	return undefined;
	    }
	    
	   	public function firstOrDefault(predicate:Function = null):*
	   	{
	   		return this.first(predicate);
	   	}
	   	
	   	public function last(predicate:Function = null):*
	    {
	    	var result:* = (new FinqObj((this as IEnumerable).reverse()))
	    		.first(predicate);
	    	return result;
	    }
	   	
	   	public function lasttOrDefault(predicate:Function = null):*
	   	{
	   		return this.last(predicate);
	   	}
	   	
	   	public function intersect(second:IEnumerable, equalityComparer:Function = null):IEnumerable
	    {
	    	var result:IEnumerable = new FinqObj();
	    	var equalityComparer2:Function;
	    	if (equalityComparer != null ) {
	    		equalityComparer2 = function(x:*, y:*):Boolean {
	    			return equalityComparer(y, x);
	    		}
	    	} else { 
	    		equalityComparer2 = null;
	    	}
			(this as Array).forEach(function(m:*, i:int, r:Array):void {
				if (second.contains(m, equalityComparer2)) {
					result.push(m);
				}
			});
	    	return result;
	    }
	    
	    public function max(selector:Function = null):*
	   	{
	   		var result:* = this[0];
	   		if (selector == null) {
	   			selector = function(x:*):* { return x; };
	   		}
	   		for each (var e:* in this) {
	   			if (selector(e) > selector(result)) {
	   				result = e;
	   			}
	   		}
	   		return result;
	   	}
	   	
	   	public function min(selector:Function = null):*
	   	{
	   		var result:* = this[0];
	   		if (selector == null) {
	   			selector = function(x:*):* { return x; };
	   		}
	   		for each (var e:* in this) {
	   			if (selector(e) < selector(result)) {
	   				result = e;
	   			}
	   		}
	   		return result;
	   	}
	   	
	   	public function reverse():IEnumerable
	   	{
	   		var result:IEnumerable = new FinqObj(this);
	   		(result as Array).reverse();
	   		return result;
	   	}
	   	
	   	public function sequenceEqual(second:IEnumerable, equalityComparer:Function = null):Boolean
	    {
	    	if (this.length != second.count()) return false;
			for (var i:int = 0; i < this.length; i++) {
				var comparer:Function = _getEqualityClosure(this[i], equalityComparer);
				if (!comparer(second[i])) return false;	
			}
			return true;
	    }
	   	
	   	public function single(predicate:Function = null):*
	   	{
	   		if (predicate == null) {
	   			predicate = function(x:*):Boolean {
	   				return true;
	   			};
	   		}
	   		var result:IEnumerable = this.where(predicate); 
	   		if (result.count() == 1) return result[0];
	   		throw new Error("FinqObj.single(): sequence does not contain exactly one element");
	   	}
	   	
	   	public function singleOrDefault(predicate:Function = null):*
	   	{
	   		if (predicate == null) {
	   			predicate = function(x:*):Boolean {
	   				return true;
	   			};
	   		}
	   		var result:IEnumerable = this.where(predicate); 
	   		if (result.count() == 1) return result[0];
	   		if (result.count() == 0) return undefined;
	   		throw new Error("FinqObj.single(): sequence does not contain exactly one element");
	   	}
	   	
	   	public function skip(count:int):IEnumerable
	   	{
	   		return (new FinqObj(this.slice(count, this.length)));
	   	}
	   	
	   	public function skipWhile(predicate:Function):IEnumerable
	   	{
	   		for (var i:int = 0; i < this.length; i++) {
	   			try {
					if (!predicate(this[i], i)) break;
	   			} catch (err:Error) {
	   				if (!predicate(this[i])) break;
	   			}
			}
			return this.skip(i);
	   	}
	   	
	   	public function sum(selector:Function = null):*
	   	{
	   		if (this.length == 0) return undefined;
	   		if (selector == null) {
	   			selector = function(x:*):* { return x; };
	   		}
	   		var result:* = selector(this[0]);
	   		for (var i:int = 1; i < this.length; i++) {
				result += selector(this[i]); 	
			}
	   		return result;
	   	}
	   	
	   	public function take(count:int):IEnumerable
	   	{
	   		return (new FinqObj(this.slice(0, count)));
	   	}
	   	
	   	public function takeWhile(predicate:Function):IEnumerable
	   	{
	   		for (var i:int = 0; i < this.length; i++) {
	   			try {
					if (!predicate(this[i], i)) break;
	   			} catch (err:Error) {
	   				if (!predicate(this[i])) break;
	   			}
			}
			return this.take(i);
	   	}
	   	
	   	public function toArray():Array
	   	{
	   		var result:Array = [];
	   		for each (var e:* in this) {
	   			result.push(e);
	   		}
	   		return result;
	   	}
	   	
	   	public function toFinqObj():FinqObj
	   	{
	   		return this;
	   	}
	   	
	   	public function toDictionary(keySelector:*, elementSelector:Function = null,
	   		keyEqualityComparer:Function = null):Dictionary
	    {
	    	var result:Dictionary = new Dictionary(true);
	    	if (elementSelector == null) {
	   			elementSelector = function(x:*):* { return x; };
	   		}
	   		if (keyEqualityComparer == null) {
	   			keyEqualityComparer = function(x:*, y:*):Boolean { return x === y; };
	   		}
	   		for each (var e:* in this) {
	    		var key:* = _getValue(keySelector, e);
	    		if (_distinctKeys(key, result, keyEqualityComparer)) {
	    			result[key] = elementSelector(e);
	    		} else {
	    			throw new Error("FinqObj.toDictionary(): key <" + key.toString() + "> allready in use");
	    		}
	    	}
	    	return result;
	    }

		public function toLookup(keySelector:*, elementSelector:Function = null,
	   		keyEqualityComparer:Function = null):*
   		{
   			throw new Error("FinqObj.toLookUp(): not implemented")	
   		}

		private function _distinctKeys(key:*, d:Dictionary, keyEqualityComparer:Function):Boolean
		{
			for (var k:* in d) {
				var res:Boolean = keyEqualityComparer(k, key);
				if (key is Boolean) {
					key = key.toString();
				}
				if (keyEqualityComparer(k, key)) return false;
			} 
			return true;	
		}
		
		public function toArrayCollection():ArrayCollection
	   	{
	   		var result:ArrayCollection = new ArrayCollection;
	   		for each (var e:* in this) {
	   			result.addItem(e);
	   		}
	   		return result;
	   	}
	   	
	   	public function toList():*
	   	{
	   		throw new Error("FinqObj.toList(): not implemented")
	   	}
		
		public function union(second:IEnumerable, equalityComparer:Function = null):IEnumerable
	    {
	    	var result:IEnumerable = new FinqObj();
	    	(this as Array).forEach(function(m:*, i:int, r:Array):void {
				if (!result.contains(m, equalityComparer)) result.push(m);
			});
			second.forEach(function(n:*, i:int, r:Array):void {
				if (!result.contains(n, equalityComparer)) result.push(n);
			});
	    	return result;
	    }
	    
	    public function asEnumerable():IEnumerable
	    {
	    	return (new FinqObj(this) as IEnumerable);
	    }
		
		public function asQueryable():*
	    {
	    	throw new Error("FinqObj.asQueryable(): not implemented")
	    }
	    
	    public function aggregate(aggregator:Function, seed:* = null, resultSelector:Function = null):*
	   	{
	   		if (this.length == 0) return undefined;
	   		var result:* = (seed == null)? this[0] : seed;
	   		for (var i:int = ((seed == null)? 1 : 0 ); i < this.length; i++) {
				result = aggregator(result, this[i]); 	
			}
	   		return (resultSelector == null)? result : resultSelector(result);
	   	}
	   	
	   	public function concat(second:IEnumerable):IEnumerable
	   	{
	   		return (new FinqObj((this as Array).concat(second)));
	   	}
	   	
	   	public function ofType(type:*):IEnumerable
	   	{
	   		var result:IEnumerable = new FinqObj();
	   		for each (var e:* in this) {
	   			if (e is type) result.push(e);
	   		}
	   		return result;
	   	}
	   	
	   	public function primitives():IEnumerable
	   	{
	   		return this.where(function(x:*):Boolean { return _isPrimitive(x); });
	   	}
	   	
	   	public function nonPrimitives():IEnumerable
	   	{
	   		return this.where(function(x:*):Boolean { return !_isPrimitive(x); });
	   	}
	   	
	   	private function _isPrimitive(obj:*):Boolean 
		{
			for (var k:* in obj) return false;
			return true;
		}
		
		public function selectMany(valueSelector:Function = null):IEnumerable
		{
			throw new Error("FinqObj.selectMany(): not implemented")
		}
		
		public function groupJoin(inner:IEnumerable, outerKeySelector:*, innerKeySelector:*,
	    	resultAggregator:Function, keyEqualityComparer:Function = null):IEnumerable
	    {
	    	if (keyEqualityComparer == null) {
	    		keyEqualityComparer = function(x:*, y:*):Boolean { return x === y; };
	    	}
	    	var temp:IEnumerable = inner.groupBy(innerKeySelector);
	    	var result:IEnumerable = this.select(function(c:*):* {
				var t:* = temp.singleOrDefault(function(x:*):Boolean {
					return keyEqualityComparer(_getValue(outerKeySelector, c), x.key);
				});
				var g:FinqObj = (t == undefined)? new FinqObj() : t.value;
				return resultAggregator(c, g);
			});
			return result;
	    }
	    
	    public function push(...elements):uint
	    {
	    	for each (var e:* in elements) {
	    		(this as Array).push(e);
	    	}
	    	return this.length;
	    }
	    
	    public function pop():*
	    {
	    	return (this as Array).pop();
	    }
	    
	}
	
}