package;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import flash.display.Sprite;
import flash.utils.Timer;
import flash.events.TimerEvent;

class Test extends Sprite {
  public static var datas:Map<String, String>;
  
  public static function loadAsset(url:String, key:String){
    var request:URLRequest = new URLRequest(url);
    var loader:URLLoader = new URLLoader(request);
    loader.addEventListener(Event.COMPLETE, setData(key));
  }

  private static function setData(key:String):Event->Void {
    return function(e:Event):Void {
      datas.set(key, e.target.data);
    };
  }
  
  public static function main(){
    datas = new Map<String,String>();
    trace("new version");
    loadAsset("https://grubhttp.appspot.com/alice/name", "name");
    loadAsset("https://grubhttp.appspot.com/alice/hobby", "hobby");

    var timer:Timer = new Timer(3000);
    timer.addEventListener(TimerEvent.TIMER, function(e){
      trace(datas);
    });
    timer.start();
  }
}