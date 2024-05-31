/*
	@file_name: fn_gearHandle.sqf
	@file_author: Dyzalonius
*/

////////////////////////////////////////////////
//               SUB-FUNCTIONS                //
////////////////////////////////////////////////

fn_gearSnitch = {
	_gearMessage = "";

	{
		if ("MineDetector" in (vestItems player + uniformItems player + backpackItems player)) then {
			_gearMessage = _gearMessage + format["\n%1 - MINEDETECTOR", name _x];
		};
		if ((secondaryWeapon _x) in ["launch_MRAWS_green_F", "launch_MRAWS_olive_F", "launch_MRAWS_sand_F"]) then {
			_gearMessage = _gearMessage + format["\n%1 - MAAWS MOD1", name _x];
		};
		if (!((primaryWeapon _x) in [_weaponMain select 0, _weaponAR select 0]) && (primaryWeapon _x) != "") then {
			_gearMessage = _gearMessage + format["\n%1 - PRIMARY:\n%2", name _x, primaryWeapon _x];
		};
	} foreach allPlayers;

	if (_gearMessage == "") then {
		hint "No suspicious gear";
	} else {
		hint _gearMessage;
	};
};

fn_gearLoad = {
	_loadout = missionNameSpace getVariable "playerGear";

	if (_loadout isEqualTo []) exitWith {};

	// remove current container contents
	removeUniform player;
	removeVest player;
	removeHeadgear player;
	removeGoggles player;
	removeAllItems player;
	removeAllAssignedItems player;
	removeAllWeapons player;

	// Give all items if they dont have it already
	if ((_loadout select 0 select 0) == "") then {
		removeUniform player;
	} else {
		player forceAddUniform (_loadout select 0 select 0);
	};
	if ((_loadout select 0 select 1) == "") then {
		removeVest player;
	} else {
		player addVest (_loadout select 0 select 1);
	};
	if ((_loadout select 0 select 2) != (backpack player)) then {
		if ((_loadout select 0 select 2) == "") then {
			removeBackpack player;
		} else {
			player addBackpack (_loadout select 0 select 2);
		};
	};
	if ((_loadout select 0 select 3) == "") then {
		removeHeadgear player;
	} else {
		player addHeadgear (_loadout select 0 select 3);
	};
	if ((_loadout select 0 select 4) == "") then {
		removeGoggles player;
	} else {
		player addGoggles (_loadout select 0 select 4);
	};
	if ((_loadout select 0 select 5) == "") then {
		player unlinkItem (hmd player);
	} else {
		player linkItem (_loadout select 0 select 5);
	};
	if ((_loadout select 0 select 6) == "") then {
		player removeWeapon (binocular player);
	} else {
		player addWeapon (_loadout select 0 select 6);
	};
	{
		player linkItem _x;
	} foreach (_loadout select 1);

	// copy primary info over
	_primary = [];
	{
		_primary pushback _x;
	} foreach (_loadout select 5);

	// load primary plus attachments
	if (_primary select 0 != "") then {
		{
			player addItem _x;
		} foreach (_primary deleteAt 1);
		player addWeapon (_primary deleteAt 0);
		{
			player addPrimaryWeaponItem _x;
		} foreach _primary;
	} else {
		player removeWeapon (primaryWeapon player);
	};

	// copy secondary info over
	_secondary = [];
	{
		_secondary pushback _x;
	} foreach (_loadout select 6);

	// load secondary plus attachments
	if (_secondary select 0 != "") then {
		{
			player addItem _x;
		} foreach (_secondary deleteAt 1);
		player addWeapon (_secondary deleteAt 0);
		{
			player addSecondaryWeaponItem _x;
		} foreach _secondary;
	} else {
		player removeWeapon (secondaryWeapon player);
	};

	// copy handgun info over
	_handgun = [];
	{
		_handgun pushback _x;
	} foreach (_loadout select 7);

	// load handgun plus attachments
	if (_handgun select 0 != "") then {
		{
			player addItem _x;
		} foreach (_handgun deleteAt 1);
		player addWeapon (_handgun deleteAt 0);
		{
			player addHandgunItem _x;
		} foreach _handgun;
	} else {
		player removeWeapon (handgunWeapon player);
	};

	// load uniform contents
	{
		player addItemToUniform _x;
	} foreach (_loadout select 2);

	// load vest contents
	{
		player addItemToVest _x;
	} foreach (_loadout select 3);

	// load backpack contents
	{
		player addItemToBackpack _x;
	} foreach (_loadout select 4);
};

fn_gearLoadout = {
	_loadout = _this;

	switch (_loadout) do {
		case "AT RIFLEMAN": {
			[] call fn_gearStart;

			// give rifleman gear
			player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1);
			player addWeapon ((missionNameSpace getVariable "gearWeaponMain") select 0);
			{
				player addPrimaryWeaponItem _x;
			} foreach ((missionNameSpace getVariable "gearWeaponMain") select 2);
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShell";};
			for "_i" from 1 to 16 do {player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1)};
			player addBackpack (missionNameSpace getVariable "gearBackpack");
			player addItemToBackpack ((missionNameSpace getVariable "gearWeaponLauncher") select 1);
			player addWeapon ((missionNameSpace getVariable "gearWeaponLauncher") select 0);
			{
				player addSecondaryWeaponItem _x;
			} foreach ((missionNameSpace getVariable "gearWeaponLauncher") select 2);
			for "_i" from 1 to 3 do {player addItemToBackpack ((missionNameSpace getVariable "gearWeaponLauncher") select 1)};

			// set to non-medic and non-engineer
			player setVariable ["Ace_medical_medicClass", 0, true];
			player setVariable ["Ace_IsEngineer", 0, true];
		};

		case "AUTORIFLEMAN": {
			[] call fn_gearStart;

			// give AR gear
			player addItemToVest ((missionNameSpace getVariable "gearWeaponAR") select 1);
			player addWeapon ((missionNameSpace getVariable "gearWeaponAR") select 0);
			{
				player addPrimaryWeaponItem _x;
			} foreach ((missionNameSpace getVariable "gearWeaponAR") select 2);
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShell";};
			for "_i" from 1 to 8 do {player addItemToVest ((missionNameSpace getVariable "gearWeaponAR") select 1)};
			player addBackpack (missionNameSpace getVariable "gearBackpack");
			for "_i" from 1 to 3 do {player addItemToBackpack ((missionNameSpace getVariable "gearWeaponAR") select 1)};

			// set to non-medic and non-engineer
			player setVariable ["Ace_medical_medicClass", 0, true];
			player setVariable ["Ace_IsEngineer", 0, true];
		};

		case "ENGINEER": {
			[] call fn_gearStart;

			// give rifleman gear
			player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1);
			player addWeapon ((missionNameSpace getVariable "gearWeaponMain") select 0);
			{
				player addPrimaryWeaponItem _x;
			} foreach ((missionNameSpace getVariable "gearWeaponMain") select 2);
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShell";};
			for "_i" from 1 to 16 do {player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1)};
			player addBackpack (missionNameSpace getVariable "gearBackpack");
			player addItemToBackpack "ToolKit";
			player addItemToBackpack "ACE_EntrenchingTool";

			// set to non-medic and engineer
			player setVariable ["Ace_medical_medicClass", 0, true];
			player setVariable ["Ace_IsEngineer", 1, true];
		};

		case "GRENADIER": {
			[] call fn_gearStart;

			// give rifleman gear
			player addItemToVest ((missionNameSpace getVariable "gearWeaponGrenadier") select 1);
			player addItemToVest ((missionNameSpace getVariable "gearWeaponGrenadier") select 3);
			player addWeapon ((missionNameSpace getVariable "gearWeaponGrenadier") select 0);
			{
				player addPrimaryWeaponItem _x;
			} foreach ((missionNameSpace getVariable "gearWeaponGrenadier") select 2);
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShell";};
			for "_i" from 1 to 16 do {player addItemToVest ((missionNameSpace getVariable "gearWeaponGrenadier") select 1)};
			player addBackpack (missionNameSpace getVariable "gearBackpack");
			for "_i" from 1 to 16 do {player addItemToBackpack ((missionNameSpace getVariable "gearWeaponGrenadier") select 3)};

			// set to non-medic and non-engineer
			player setVariable ["Ace_medical_medicClass", 0, true];
			player setVariable ["Ace_IsEngineer", 0, true];
		};

		case "MARKSMAN": {
			[] call fn_gearStart;

			// give marksman gear
			player addItemToVest ((missionNameSpace getVariable "gearWeaponMarksman") select 1);
			player addWeapon ((missionNameSpace getVariable "gearWeaponMarksman") select 0);
			{
				player addPrimaryWeaponItem _x;
			} foreach ((missionNameSpace getVariable "gearWeaponMarksman") select 2);
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShell";};
			for "_i" from 1 to 8 do {player addItemToVest ((missionNameSpace getVariable "gearWeaponMarksman") select 1)};
			player addBackpack (missionNameSpace getVariable "gearBackpack");
			for "_i" from 1 to 3 do {player addItemToBackpack ((missionNameSpace getVariable "gearWeaponMarksman") select 1)};

			// set to non-medic and non-engineer
			player setVariable ["Ace_medical_medicClass", 0, true];
			player setVariable ["Ace_IsEngineer", 0, true];
		};

		case "MEDIC": {
			[] call fn_gearStart;

			// give medic gear
			player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1);
			player addWeapon ((missionNameSpace getVariable "gearWeaponMain") select 0);
			{
				player addPrimaryWeaponItem _x;
			} foreach ((missionNameSpace getVariable "gearWeaponMain") select 2);
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShell";};
			for "_i" from 1 to 16 do {player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1)};
			player addBackpack (missionNameSpace getVariable "gearBackpack");
			for "_i" from 1 to 8 do {
				for "_i" from 1 to 3 do {player addItemToBackpack "ACE_salineIV"};
				for "_i" from 1 to 5 do {player addItemToBackpack "ACE_fieldDressing"};
				for "_i" from 1 to 1 do {player addItemToBackpack "ACE_tourniquet"};
				for "_i" from 1 to 2 do {player addItemToBackpack "ACE_epinephrine"};
				for "_i" from 1 to 2 do {player addItemToBackpack "ACE_morphine"};
				for "_i" from 1 to 2 do {player addItemToBackpack "ACE_splint"};
			};

			// set to medic and non-engineer
			player setVariable ["Ace_medical_medicClass", 1, true];
			player setVariable ["Ace_IsEngineer", 0, true];
		};

		case "RIFLEMAN": {
			[] call fn_gearStart;

			// give rifleman gear
			player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1);
			player addWeapon ((missionNameSpace getVariable "gearWeaponMain") select 0);
			{
				player addPrimaryWeaponItem _x;
			} foreach ((missionNameSpace getVariable "gearWeaponMain") select 2);
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShell";};
			for "_i" from 1 to 16 do {player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1)};
			player addBackpack (missionNameSpace getVariable "gearBackpack");
			player addItemToBackpack "ACE_EntrenchingTool";
			player addWeapon (missionNameSpace getVariable "gearWeapon1Use");

			// set to non-medic and non-engineer
			player setVariable ["Ace_medical_medicClass", 0, true];
			player setVariable ["Ace_IsEngineer", 0, true];
		};

		case "TEAMLEADER": {
			[] call fn_gearStart;

			// give leader gear
			player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1);
			player addWeapon ((missionNameSpace getVariable "gearWeaponMain") select 0);
			{
				player addPrimaryWeaponItem _x;
			} foreach ((missionNameSpace getVariable "gearWeaponMain") select 2);
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShell";};
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShellGreen";};
			for "_i" from 1 to 3 do {player addItemToVest "UK3CB_BAF_SmokeShellBlue";};
			for "_i" from 1 to 16 do {player addItemToVest ((missionNameSpace getVariable "gearWeaponMain") select 1)};
			player addBackpack (missionNameSpace getVariable "gearBackpackLeader");

			// set to non-medic and non-engineer
			player setVariable ["Ace_medical_medicClass", 0, true];
			player setVariable ["Ace_IsEngineer", 0, true];
		};
	};

	// Save default loadout to playerGear if it's empty
	_loadout = missionNameSpace getVariable "playerGear";
	if (_loadout isEqualTo []) exitWith {[] call fn_gearSave;};
};

fn_gearSave = {
	_items = [];
	_linkedItems = [];

	_uniform = [];
	_vest = [];
	_backpack = [];

	_primary = [];
	_secondary = [];
	_handgun = [];

	// save loose items
	_items pushback (uniform player);
	_items pushback (vest player);
	_items pushback (backpack player);
	_items pushback (headgear player);
	_items pushback (goggles player);
	_items pushback (hmd player);
	_items pushback (binocular player);

	// save linked items
	_linkedItems = (assignedItems player);

	// save uniform contents
	{
		_uniform pushback _x;
	} foreach (uniformItems player);

	// save vest contents
	{
		_vest pushback _x;
	} foreach (vestItems player);

	// save backpack contents
	{
		_backpack pushback _x;
	} foreach (backpackItems player);

	// save primary plus attachments
	_primary pushback (primaryWeapon player);
	_primary pushback (primaryWeaponMagazine player);
	{
		_primary pushback _x;
	} foreach (primaryWeaponItems player);

	// save secondary plus attachments
	_secondary pushback (secondaryWeapon player);
	_secondary pushback (secondaryWeaponMagazine player);
	{
		_secondary pushback _x;
	} foreach (secondaryWeaponItems player);

	// save pistol plus attachments
	_handgun pushback (handgunWeapon player);
	_handgun pushback (handgunMagazine player);
	{
		_handgun pushback _x;
	} foreach (handgunItems player);

	// save loadout
	_loadout = [_items, _linkedItems, _uniform, _vest, _backpack, _primary, _secondary, _handgun];
	missionNameSpace setVariable ["playerGear", _loadout, false];
};

fn_gearStart = {
	removeAllWeapons player;
	removeUniform player;
	removeVest player;
	removeBackpack player;
	removeHeadgear player;
	removeAllAssignedItems player;
	removeGoggles player;

	player linkItem "ItemMap";
	player linkItem "itemGPS";
	player linkItem (missionNameSpace getVariable "gearRadio");
	player linkItem "ItemCompass";
	player linkItem "ItemWatch";
	player addWeapon "Binocular";
	if (missionNameSpace getVariable "gearGiveNightvision") then {
		player linkItem (missionNameSpace getVariable "gearNightvision");
	};

	player forceAddUniform (missionNameSpace getVariable "gearUniform");
	player addItemToUniform "ACE_bodyBag";
	player addItemToUniform "ACE_EarPlugs";
	for "_i" from 1 to 5 do {
		player addItemToUniform "ACE_morphine";
		player addItemToUniform "ACE_epinephrine";
		player addItemToUniform "ACE_splint";
	};
	for "_i" from 1 to 2 do {
		player addItemToUniform "ACE_tourniquet";
	};
	for "_i" from 1 to 30 do {player addItemToUniform "ACE_fieldDressing"};

	player addVest (missionNameSpace getVariable "gearVest");
	player addHeadgear (missionNameSpace getVariable "gearHeadgear");
};

////////////////////////////////////////////////
//               FUNCTION LOOP                //
////////////////////////////////////////////////

if (side player == sideLogic) exitWith {true};

_request = (_this select 0);

switch (_request) do {
	// gear start
	case 0: {
		[] call fn_gearStart;
	};

	// gear loadout
	case 1: {
		_loadout = (_this select 1);
		_loadout call fn_gearLoadout;
	};

	// save gear
	case 2: {
		[] call fn_gearSave;
	};

	// rearm from save
	case 3: {
		[] call fn_gearLoad;
	};

	// check unallowed gear
	case 4: {
		[] call fn_gearSnitch;
	};
};
