package;

import haxe.xml.Access;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Main {
    	public static function main():Void {
        // Create a folder to prevent messing with hmm libraries
      	if (!FileSystem.exists(".haxelib"))
          	FileSystem.createDirectory(".haxelib");

        // brief explanation: first we parse a json/xml containing the library names, data, and such
        var libs = new Access(Xml.parse(File.getContent("./setup/desktop-libraries.xml")).firstElement());
  
        for (data in libs.elements) {
         switch (data.x.nodeName) {
         case "haxelib":
          var version = data.has.version ? data.att.version : "";
          Sys.println("");
          Sys.println('Installing ${data.att.name}@${version.trim() == "" ? "latest" : version} from haxelib');
          Sys.println("");
          Sys.command('haxelib --quiet install ${data.att.name} $version --always --skip-dependencies');
        case "git":
          Sys.println("");
          Sys.println('Installing ${data.att.name}@git from ${data.att.url}');
          Sys.println("");
          Sys.command('haxelib --quiet git ${data.att.name} ${data.att.url} --always --skip-dependencies');
      }
   }

          Sys.println("");
          Sys.println('Finished installing all libs!');
        // after the loop, we can leave
Sys.exit(0);
  }
}
