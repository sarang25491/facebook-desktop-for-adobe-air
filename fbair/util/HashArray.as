/*
  Copyright Facebook Inc.

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
// this class stores references to objects in both an array and dictionary
// in order to maintain a sorted ordering for iteration but also O(1)
// search and retrieve time. Keys are unique, adding an item at an existing
// key overwrites the previous entry
package fbair.util {
  import flash.net.registerClassAlias;
  import flash.utils.IDataInput;
  import flash.utils.IDataOutput;
  import flash.utils.IExternalizable;
  import flash.utils.Proxy;
  import flash.utils.flash_proxy;

  public class HashArray extends Proxy implements IExternalizable {

    private static const ALIAS:* =
      registerClassAlias("fbair.util.HashArray", HashArray);

    // array of {obj:*, key:String}
    private var list:Array;

    // hash of {obj:*, index:uint}
    private var hash:Object;

    public function HashArray(listObj:Array = null, fieldName:String = null) {
      list = new Array();
      hash = new Object();
      if (listObj && fieldName)
        addList(listObj, fieldName);
    }

    // takes a list of objects, adding them to the HashArray with the string
    // at fieldName becoming the key
    public function addList(listObj:Array, fieldName:String):uint {
      for each (var item:Object in listObj)
        push(item[fieldName], item);
      return length;
    }

    // creates and returns a raw array of contents
    public function asArray():Array {
      var arr:Array = new Array();
      for (var key:String in this)
        arr.push(getAtKey(key));
      return arr;
    }

    // creates and returns a raw array of contents
    public function asObject():Object {
      var obj:Object = new Object();
      for (var key:String in this)
        obj[key] = getAtKey(key);
      return obj;
    }

    // returns the first entry
    public function first():* {
      return list[0].obj;
    }

    // returns the object at index
    public function getAt(index:uint):* {
      return list[index].obj;
    }

    // returns the object at key, returns default if it doesn't exist
    public function getAtKey(key:String, defaultVal:* = null):* {
      if (!hasKey(key)) return defaultVal;
      return hash[key].obj;
    }

    // returns the object at key
    override flash_proxy function getProperty(name:*):* {
      return getAtKey(name);
    }

    // returns the key of the item at index in the list
    public function keyAtIndex(index:uint):String {
      return list[index].key;
    }

    // returns true if an entry for the key exists
    public function hasKey(key:String):Boolean {
      return hash[key] != null;
    }

    // returns the position in the array of the item at key
    public function indexAtKey(key:String):int {
      if (!hasKey(key)) return -1;
      return hash[key].index;
    }

    // returns the index where an object lives
    // returns -1 if the object is not in our list
    public function indexOf(obj:*):int {
      for (var i:int = 0; i < length; i++)
        if (list[i].obj == obj)
          return i;
      return -1;
    }

    public function insertAt(index:uint, key:String, obj:*):uint {
      if (hasKey(key)) {
        if (indexAtKey(key) < index)
          index--;
        removeKey(key);
      }
      var listItem:Object = {obj:obj, key:key};
      var hashItem:Object = {obj:obj, index:index};
      list.splice(index, 0, listItem);
      hash[key] = hashItem;
      // repair references
      for (var i:int = index + 1; i < length; i++)
        hash[list[i].key].index = i;
      return length;
    }

    // returns the last entry
    public function last():* {
      return list[length - 1].obj;
    }

    // number of objects in the HashArray
    public function get length():uint {
      return list.length;
    }

    override flash_proxy function nextName(index:int):String {
      return list[index - 1].key;
    }

    override flash_proxy function nextNameIndex(index:int):int {
      if (index < length)
        return index + 1;
      else
        return 0;
    }

    override flash_proxy function nextValue(index:int):* {
      return list[index - 1].obj;
    }

    // removes and returns the last item in the HashArray
    public function pop():* {
      var item:Object = list.pop();
      delete hash[item.key];
      return item.obj;
    }

    // adds a key value pair to the end of the list
    // returns the new length of the array
    public function push(key:String, obj:*):uint {
      if (hasKey(key))
        removeKey(key);
      var listItem:Object = {obj:obj, key:key};
      var hashItem:Object = {obj:obj, index:length};
      list.push(listItem);
      hash[key] = hashItem;
      return length;
    }

    public function readExternal(input:IDataInput):void {
      list = input.readObject() as Array;
      hash = input.readObject();
    }

    // removes an item at index, optionally removing a number of items
    // returns an array of the removed items
    public function removeIndex(index:uint, count:uint=1):Array {
      var removedItems:Array = list.splice(index, count);
      var removed:Array = new Array();
      for each (var item:Object in removedItems) {
        delete hash[item.key];
        removed.push(item.obj);
      }
      // repair references
      for (var i:int = index; i < length; i++)
        hash[list[i].key].index = i;
      return removed;
    }

    // removes an item by key
    // returns the removed item
    public function removeKey(key:String):* {
      var removed:Array = removeIndex(indexAtKey(key));
      return removed[0];
    }

    // we'll treat this as a push operation for key value pairs
    override flash_proxy function setProperty(key:*, value:*):void {
      push(key, value);
    }

    // removes and returns the first item in the list
    public function shift():* {
      var item:Object = list.shift();
      delete hash[item.key];
      return item.obj;
    }

    // adds a key value pair to the beginning of the list
    // returns the new length of the array
    public function unshift(key:String, obj:*):uint {
      if (hasKey(key))
        removeKey(key);
      var listItem:Object = {obj:obj, key:key};
      var hashItem:Object = {obj:obj, index:0};
      list.unshift(listItem);
      hash[key] = hashItem;
      // repair references
      for (var i:int = 1; i < length; i++)
        hash[list[i].key].index = i;
      return length;
    }

    public function writeExternal(output:IDataOutput):void {
      output.writeObject(list);
      output.writeObject(hash);
    }
  }
}
