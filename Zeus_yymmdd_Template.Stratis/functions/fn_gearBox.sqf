/*
	@file_name: fn_gearBox.sqf
	@file_author: Dyzalonius
*/

////////////////////////////////////////////////
//               SUB-FUNCTIONS                //
////////////////////////////////////////////////

fn_addAllActions = {
	_this call fn_addRearmAction;
	_this call fn_addSaveAction;
	[_this, "AT RIFLEMAN"]  call fn_addLoadoutAction;
	[_this, "AUTORIFLEMAN"] call fn_addLoadoutAction;
	[_this, "ENGINEER"]     call fn_addLoadoutAction;
	[_this, "GRENADIER"]    call fn_addLoadoutAction;
	[_this, "MARKSMAN"]     call fn_addLoadoutAction;
	[_this, "MEDIC"]        call fn_addLoadoutAction;
	[_this, "RIFLEMAN"]     call fn_addLoadoutAction;
	[_this, "TEAMLEADER"]   call fn_addLoadoutAction;
	[_this, "VEHICLE CREW"] call fn_addLoadoutAction;
};

fn_addLoadoutAction = {
	params ["_object", "_type"];


	// Add the hold-action to the object
	[
		/* 0 object */                      	_object,
		/* 1 action title */                	format ["Load %1", _type],
		/* 2 idle icon */                   	"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloadDevice_ca.paa",
		/* 3 progress icon */               	"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloadDevice_ca.paa",
		/* 4 condition to show */           	"(_this distance _target < 3)",
		/* 5 condition for action */        	"(_this distance _target < 3)",
		/* 6 code executed on start */      	{},
		/* 7 code executed per tick */      	{},
		/* 8 code executed on completion */
		{
			_type = param [3] # 0;
			playSound "sound1";
			[1, _type] call ZO_fnc_gearHandle;
		},
		/* 9 code executed on interruption */   {},
		/* 10 arguments */                      [_type],
		/* 11 action duration */                1,
		/* 12 priority */                       8,
		/* 13 remove on completion */           false,
		/* 14 show unconscious */               false
	] remoteExec ["BIS_fnc_holdActionAdd",[0,-2] select isDedicated,true];
};

fn_addRearmAction = {
	_object = _this;

	// Add the hold-action to the object
	[
		/* 0 object */                      	_object,
		/* 1 action title */
		{
			switch (_this getVariable 'rearmUses') do {
				case -1: {
					"REARM";
				};

				case 0: {
					(format ["REARM</t><t color='#FF0000' align='left'> (%1 uses)", (_this getVariable 'rearmUses')]);
				};

				case 1: {
					(format ["REARM (%1 use)", (_this getVariable 'rearmUses')]);
				};

				default {
					(format ["REARM (%1 uses)", (_this getVariable 'rearmUses')]);
				};
			};
		},
		/* 2 idle icon */                   	"files\holdAction_rearm.paa",
		/* 3 progress icon */               	"files\holdAction_rearm.paa",
		/* 4 condition to show */           	"(_this distance _target < 3)",
		/* 5 condition for action */        	"(_this distance _target < 3) && (_target getVariable ""rearmUses"") != 0",
		/* 6 code executed on start */      	{},
		/* 7 code executed per tick */      	{},
		/* 8 code executed on completion */
		{
			playSound "sound1";

			if (!((missionNameSpace getVariable "playerGear") isEqualTo [])) then {
				_rearmUses = (_target getVariable "rearmUses");
				if (_rearmUses != 0) then {
					if (_rearmUses > 0) then {
						_target setVariable ["rearmUses", _rearmUses - 1, false];
					};
					cutText ["Rearmed", "PLAIN", 0.2];
					[3] call ZO_fnc_gearHandle;
					["ace_medical_treatment_fullHealLocal", [_caller], _caller] call CBA_fnc_targetEvent;
				};
			} else {
				cutText ["You don't have any loadout saved!", "PLAIN", 0.2];
			};
		},
		/* 9 code executed on interruption */
		{
			if ((_target getVariable "rearmUses") == 0) then {
				cutText ["Rearm has no uses left!", "PLAIN", 0.2];
			};
		},
		/* 10 arguments */                      [],
		/* 11 action duration */                1,
		/* 12 priority */                       10,
		/* 13 remove on completion */           false,
		/* 14 show unconscious */               false
	] remoteExec ["ZO_fnc_holdActionAdd",[0,-2] select isDedicated,true];
};

fn_addSaveAction = {
	_object = _this;

	// Add the hold-action to the object
	[
		/* 0 object */                          _object,
		/* 1 action title */                    "SAVE loadout for rearm",
		/* 2 idle icon */                       "files\holdAction_save.paa",
		/* 2 idle icon */                       "files\holdAction_save.paa",
		/* 4 condition to show */               "(_this distance _target < 3)",
		/* 5 condition for action */            "(_this distance _target < 3)",
		/* 6 code executed on start */          {},
		/* 7 code executed per tick */          {},
		/* 8 code executed on completion */
		{
			playSound "sound1";

			[2] call ZO_fnc_gearHandle;
		},
		/* 9 code executed on interruption */   {},
		/* 10 arguments */                      [],
		/* 11 action duration */                1,
		/* 12 priority */                       9,
		/* 13 remove on completion */           false,
		/* 14 show unconscious */               false
	] remoteExec ["BIS_fnc_holdActionAdd",[0,-2] select isDedicated,true];
};

fn_createBox = {
	_position = _this;

	// Spawn ammobox
	_object = createVehicle ["B_supplyCrate_F", _position, [], 0, "CAN_COLLIDE"];
	_object setDir (round random 360);
	[_object, 4] call ace_cargo_fnc_setSize;

	// Allow zeuses to move the ammobox
	{
		_x addCuratorEditableObjects [[_object],true];
	} foreach allCurators;

	_object;
};

fn_clearCargo = {
	_object = _this;

	clearWeaponCargoGlobal _object;
	clearMagazineCargoGlobal _object;
	clearItemCargoGlobal _object;
	clearBackpackCargoGlobal _object;
};

fn_addArsenal = {
	_object = _this;

	if (missionNameSpace getVariable ["fullArsenal", false]) then {
		[_object, true] call ace_arsenal_fnc_initBox;
		["AmmoboxInit", [_object, true]] call BIS_fnc_arsenal;
	};
};

////////////////////////////////////////////////
//               FUNCTION LOOP                //
////////////////////////////////////////////////

if (isDedicated && !isServer) exitWith {};

_request = _this select 0;

switch (_request) do {
	// START BOX
	case 0: {
		_position = _this select 1;
		_object = _position call fn_createBox;
		_object setVariable ["rearmUses", -1, true];

		_object call fn_clearCargo;
		_object call fn_addAllActions;
		_object call fn_addArsenal;
	};

	// REARM BOX
	case 1: {
		_position = _this select 1;
		_object = _position call fn_createBox;
		_object setVariable ["rearmUses", 1, true];

		_object call fn_clearCargo;
		_object call fn_addRearmAction;
	};

	// START BOX ON OBJECT
	case 2: {
		_object = _this select 1;
		[_object, 4] call ace_cargo_fnc_setSize;
		_object setVariable ["rearmUses", -1, true];

		_object call fn_clearCargo;
		_object call fn_addAllActions;
		_object call fn_addArsenal;
	};

	// REARM BOX ON OBJECT
	case 3: {
		_object = _this select 1;
		[_object, 4] call ace_cargo_fnc_setSize;

		_alreadyRearmObject = !isNil {_object getVariable "rearmUses"};

		_object setVariable ["rearmUses", 1, true];
		// TODO: - Figure out if cleaning the inventory is actually desired
		//         when applied to an existing object
		//       - Update zeusopsmod and make the module use case 1 instead of
		//         this one
		_object call fn_clearCargo;


		if (!_alreadyRearmObject) then {
			_object call fn_addRearmAction;
		};
	};
};
