package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxInputText;
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
	var extraText:FlxInputText;

	/**
	 * Ok so, if uiPref is "machine", mean is will set the ui as on machine, if uiPref is "misc", mean is will set the ui as on misc and other,...
	 * cool
	 */
	var uiPref:String = "machine";

	var uiPrefButtonLeft:FlxButton;
	var uiPrefButtonRight:FlxButton;
	var uiPrefIndex:Int = 0;
	var getForFirstBoot:Bool = true;

	function genUI() {
		var runButton:FlxButton = new FlxButton(10, 10, "Run", onRunMachine);
		add(runButton);

		if (uiPref == "machine" && getForFirstBoot)
		{
			getMachine();
			getForFirstBoot = false;
		}

		uiPrefButtonLeft = new FlxButton(10, FlxG.height - 40, "Page Left", function()
		{
			uiPrefIndex--;
			if (uiPrefIndex < 0)
				uiPrefIndex = 1;
			switch (uiPrefIndex)
			{
				case 0:
					clear();
					genUI();
					uiPref = "machine";
					getMachine();
				case 1:
					clear();
					genUI();
					uiPref = "misc";
					getMisc();
				default:
					clear();
					genUI();
					uiPref = "machine";
					getMachine();
			}
		});
		add(uiPrefButtonLeft);
		uiPrefButtonRight = new FlxButton(FlxG.width - 100, FlxG.height - 40, "Page Right", function()
		{
			uiPrefIndex++;
			if (uiPrefIndex > 1)
				uiPrefIndex = 0;
			switch (uiPrefIndex)
			{
				case 0:
					clear();
					genUI();
					uiPref = "machine";
					getMachine();
				case 1:
					clear();
					genUI();
					uiPref = "misc";
					getMisc();
				default:
					clear();
					genUI();
					uiPref = "machine";
					getMachine();
			}
		});
		add(uiPrefButtonRight);
	}

	function getMachine()
	{
		var machineTxt:FlxText = new FlxText(10, 45, 0, "Machine Config", 18);
		machineTxt.color = FlxColor.BLACK;
		add(machineTxt);

		var cpuOptions:Array<String> = loadOptions("assets/data/cpuList.txt", ["qemu32"]);
		cpuSelected = new FlxUIDropDownMenu(machineTxt.x, machineTxt.y + 50, FlxUIDropDownMenu.makeStrIdLabelArray(cpuOptions, true), function (cpuList:String) {
			config.cpu = cpuOptions[Std.parseInt(cpuList)];
		});
		quickCreateText([cpuSelected.x, cpuSelected.y - 25], "CPU");
		add(cpuSelected);

		var typeMachinesOptions:Array<String> = loadOptions("assets/data/typeMachineList.txt", ["i386"]);
		typeMachineSelected = new FlxUIDropDownMenu(machineTxt.x + 150, cpuSelected.y, FlxUIDropDownMenu.makeStrIdLabelArray(typeMachinesOptions, true), function (typeMachineThing:String) {
			config.typeMachine = typeMachinesOptions[Std.parseInt(typeMachineThing)];
		});
		quickCreateText([typeMachineSelected.x, typeMachineSelected.y - 25], "Type Machine");
		add(typeMachineSelected);
	}

	function getMisc()
	{
		var machineTxt:FlxText = new FlxText(10, 45, 0, "Misc Config", 18);
		machineTxt.color = FlxColor.BLACK;
		add(machineTxt);

		extraText = new FlxInputText(machineTxt.x, machineTxt.y + 50, 0, "", 16);
		quickCreateText([extraText.x, extraText.y - 25], "Extras Params");
		extraText.font = extraText.systemFont;
		add(extraText);
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

	function quickCreateText(pos:Array<Float>, text:String)
	{
		var text:FlxText = new FlxText(pos[0], pos[1], 0, text, 16);
		text.color = FlxColor.BLACK;
		return add(text);
	}

	function onRunMachine() {
		trace("Run with the following settings: ");
		for (key in Reflect.fields(config))
			trace(key + ": " + Reflect.field(config, key) + '.');
		if (extraText.text != null)
			trace("Extra Params Found: " + extraText.text + '.');

		var command = 'qemu-system-' + config.typeMachine 
			+ ' -m ' + config.ram 
			+ ' -cpu ' + config.cpu 
			+ ' -smp ' + config.cpuCores 
			+ ' -display ' + config.display
			+ ' -vga ' + config.vga 
			+ ' -name ' + config.nameMachine + extraText.text;
		Sys.command(command);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
