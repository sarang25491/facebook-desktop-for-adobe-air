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
package fbair.util {
  import flash.data.EncryptedLocalStore;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.utils.ByteArray;

  public class Preferences {
    public static const LOAD:String = "loadPreferences";
    public static const UNLOAD:String = "unloadPreferences";

    public static var dispatcher:EventDispatcher = new EventDispatcher();

    public static function getPreference(prefName:String):Object {
      var bytes:ByteArray = EncryptedLocalStore.getItem(prefName);
      if (!bytes) return null;
      return bytes.readObject();
    }

    public static function setPreference(prefName:String,
                                         prefObject:Object):void {
      var bytes:ByteArray = new ByteArray();
      bytes.writeObject(prefObject);
      EncryptedLocalStore.setItem(prefName, bytes);
    }
  }
}
