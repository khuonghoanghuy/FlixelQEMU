package;

import flixel.FlxState;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIList;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using StringTools;

class MenuState extends FlxState
{
	var config = {
		typeMachine: "i386",
		ram: 16,
		cpu: "qemu32",
		cpuCores: 1,
		display: "gtk",
		vga: "std",
		nameMachine: "default"
	};

	override public function create()
	{
		bgColor = FlxColor.WHITE;
		super.create();
		genUI();
	}

	// Drop Box
	var cpuSelected:FlxUIDropDownMenu;
	var typeMachineSelected:FlxUIDropDownMenu;

	function genUI() {
		var runButton:FlxButton = new FlxButton(10, 10, "Run", onRunMachine);
		add(runButton);

		var cpuOptions:Array<String> = loadOptions("assets/data/cpuList.txt", ["qemu32"]);
		var typeMachinesOptions:Array<String> = loadOptions("assets/data/typeMachineList.txt", ["i386"]);

		var machineTxt:FlxText = new FlxText(10, 50, 0, "Machine Config", 18);
		machineTxt.color = FlxColor.BLACK;
		add(machineTxt);

		cpuSelected = new FlxUIDropDownMenu(machineTxt.x, machineTxt.y + 50, FlxUIDropDownMenu.makeStrIdLabelArray(cpuOptions, true), function (cpuList:String) {
			config.cpu = cpuOptions[Std.parseInt(cpuList)];
		});
		add(cpuSelected);

		typeMachineSelected = new FlxUIDropDownMenu(machineTxt.x + 150, cpuSelected.y, FlxUIDropDownMenu.makeStrIdLabelArray(typeMachinesOptions, true), function (typeMachineThing:String) {
			config.typeMachine = typeMachinesOptions[Std.parseInt(typeMachineThing)];
		});
		add(typeMachineSelected);
	}

	function loadOptions(path:String, defaultOptions:Array<String>):Array<String> {
		if (sys.FileSystem.exists(path)) {
			var content:String = sys.io.File.getContent(path);
			return content.split("\n").map(function(line) {
				return line.trim();
			}).filter(function(line) {
				return line != "";
			});
		} else {
			trace(path + " not found.");
			return defaultOptions;
		}
	}

	function onRunMachine() {
		trace("Run with the following settings: ");
		for (key in Reflect.fields(config))
			trace(key + ": " + Reflect.field(config, key));

		var command = 'qemu-system-' + config.typeMachine 
			+ ' -m ' + config.ram 
			+ ' -cpu ' + config.cpu 
			+ ' -smp ' + config.cpuCores 
			+ ' -display ' + config.display
			+ ' -vga ' + config.vga 
			+ ' -name ' + config.nameMachine;
		Sys.command(command);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
