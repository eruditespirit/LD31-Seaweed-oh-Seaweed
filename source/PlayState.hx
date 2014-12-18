package;

import flixel.addons.effects.FlxGlitchSprite;
import flixel.addons.effects.FlxWaveSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.system.FlxAssets;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;
using StringTools;

class PlayState extends FlxState
{
	private static inline var INSTRUCTIONS = "Press a different direction!"; 

	private var _scoreText:FlxText;
	private var _highScoreText:FlxText;
	private var _waveSprite:FlxWaveSprite;
	private var _waveSprite2:FlxWaveSprite;
	private var _glitch:FlxGlitchSprite;
	private var _statusText:FlxText;
	private var _dirText:FlxText;
	private var _gameOverText:FlxText;
	private var _txtInstruct:FlxText;
	private var _randDir:Int;
	private var _highScoreSave:FlxSave;	
		
	private var _ending:Bool = false;
	private var _score:Int = 0;
	private var _highScore:Int = 0;
	private var _started:Bool = false;
	private var _inputGiven:Bool = false;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		FlxG.cameras.bgColor = 0x222222;
		
		_highScoreSave = new FlxSave();
		_highScoreSave.bind("HighScore");
		
		var _headSprite = new FlxSprite(0, 0, "assets/head.png");
		_headSprite.screenCenter();
		
		_glitch = new FlxGlitchSprite(_headSprite);
		_glitch.strength = 0;
		add(_glitch);
		
		
		var _sprite = new FlxSprite(0, 0, "assets/rightArm.png");
		_sprite.screenCenter();
		
		_waveSprite = new FlxWaveSprite(_sprite);
		_waveSprite.speed = 24;
		_waveSprite.angle = 0;
		
		var _sprite2 = new FlxSprite(0, 0, "assets/leftArm.png");
	//	_sprite2.setFacingFlip(FlxObject.LEFT, false, false);
	//	_sprite2.setFacingFlip(FlxObject.RIGHT, true, false);
	//	_sprite2.facing = FlxObject.LEFT;		
		_sprite2.screenCenter();

		_waveSprite2 = new FlxWaveSprite(_sprite2);
		_waveSprite2.speed = 24;
		_waveSprite2.angle = 0;

		_txtInstruct = new FlxText(0, 5, FlxG.width, INSTRUCTIONS);
		_txtInstruct.alignment = "center";
		add(_txtInstruct);
		
		_statusText = new FlxText(0, FlxG.height - 15, FlxG.width);
		_statusText.alignment = "center";
		add(_statusText);
			
		_dirText = new FlxText(0, FlxG.height / 2 - 25, FlxG.width);
		_dirText.setFormat(null, 24);
		_dirText.alignment = "center";
		add(_dirText);
		
		_gameOverText = new FlxText(0, FlxG.height / 2 - 40, FlxG.width);
		_gameOverText.setFormat(null, 24);
		_gameOverText.alignment = "center";
		add(_gameOverText);
		
		_scoreText = new FlxText(0, 0, 200, "Score: " + _score);
		add(_scoreText);
		
		_highScoreText = new FlxText(0, FlxG.height - 12, 200, "High Score: " + _highScore);
		onLoad(false);
		add(_highScoreText);
		
		//Timer for the main loop
		resetTimer();
		
		super.create();
	}
	
	override public function update():Void
	{
		if (_dirText.alpha > 0)
		{
			_dirText.alpha -= 0.045;
		}
		
		
		boundValues();
		
		super.update();

		if (_scoreText.alpha < 1)
		{
			_scoreText.alpha += 0.2;
		}
		
		if (_ending)
		{
			if (FlxG.keys.anyJustReleased(["SPACE", "R"]))
			{
				FlxG.resetState();
			}
			
			return;
		}	
		checkInput();
	}
	

	private function onSave():Bool 
	{
		if (_highScoreSave.data.score == null)
		{
			_highScoreSave.data.score = _score;
		}
		else if(_highScoreSave.data.score < _score)
		{
			_highScoreSave.data.score = _score;
			_highScoreSave.flush();
			return true;
		}
		_highScoreSave.flush();
		return false;
	}
	
	private function onLoad(flicker:Bool):Void
	{
		if (_highScoreSave.data.score != null)
		{
			//Uncomment this whenever you want to reset the high score
			//_highScoreSave.data.score = 0;
			_highScore = _highScoreSave.data.score;
			updateHighScore("High Score: " + _highScore, flicker);
		}
	}
	
	private function updateHighScore(NewText:String, flicker:Bool):Void
	{
		_highScoreText.text = NewText;
		if (flicker)
		{
			_highScoreText.flicker(1);
			FlxG.sound.play("assets/HighScore.wav");
		}
	}
	
	private function updateScore(NewText:String):Void
	{
		_scoreText.text = NewText;
		_scoreText.alpha = 0;
	}
	
	private function multipleKeysPressed():Bool
	{
		
		if (FlxG.keys.anyPressed(["DOWN"]))
		{
			if (FlxG.keys.anyPressed(["UP", "LEFT", "RIGHT"]))
				return true;
		}
		if (FlxG.keys.anyPressed(["UP"]))
		{
			if (FlxG.keys.anyPressed(["DOWN", "LEFT", "RIGHT"]))
				return true;
		}
		return false;
	}
	private function boundValues():Void
	{
		_waveSprite.center = Std.int(FlxMath.bound(_waveSprite.center, 0, _waveSprite.height));
		_waveSprite.strength = Std.int(FlxMath.bound(_waveSprite.strength, 0, 500));
		_waveSprite.speed = FlxMath.bound(_waveSprite.speed, 0, 80);
	}
	
	private function incrementMode():Void
	{
		switch (_waveSprite.mode)
		{
			case ALL:
				_waveSprite.mode = TOP;
			case TOP:
				_waveSprite.mode = BOTTOM;
			case BOTTOM:
				_waveSprite.mode = ALL;
		}
	}
	
	private function gameOver():Void
	{
		_ending = true;
		_txtInstruct.text = "Space to restart!";
		_gameOverText.text = "G A M E\nO V E R";
		FlxG.sound.play("assets/gameOver.wav");
		//_score -= 1;
		//updateScore("Score: " + _score);
		//FlxG.camera.shake(0.01, 0.1);
		_glitch.strength = 8;
		new FlxTimer(0.2, endGlitch);
		var flicker = onSave();
		onLoad(flicker);
	}
	
	private function endGlitch(?Timer:FlxTimer):Void
	{
		_glitch.strength = 0;
	}
	
	private function resetTimer(?Timer:FlxTimer):Void
	{
		if (_ending && Timer != null)
		{
			Timer.destroy();
			return;
		}

		new FlxTimer(.6, resetTimer);
		pickRandomDir();
		//delay before seaweed
		new FlxTimer(.3, wiggleArms);
		//giving a little leeway to the player
		new FlxTimer(.4, failIfNoInput);

		remove(_waveSprite);
		remove(_waveSprite2);
	}
	
	private function pickRandomDir():Void
	{
		_randDir = FlxRandom.intRanged(0, 2);
		switch(_randDir)
		{
			case 0:
				updateDirText("U  P");
			case 1:
				updateDirText("D O W N");
			case 2:
				updateDirText("S I D E");
		}
	}
	
	private function updateDirText(dir:String):Void 
	{
		//FlxG.camera.shake(0.01, 0.05);
		FlxG.sound.play("assets/down.wav");
		_dirText.text = dir;
		_dirText.alpha = 1;
	}
	
	private function failIfNoInput(?Timer:FlxTimer):Void
	{
		if (!_inputGiven)
		{
			gameOver();
		}
		else 
		{
			_inputGiven = false;
			if (!_ending)
			{
				_score+= 1;
				updateScore("Score: " + _score);
			}
		}
	}
	
	private function checkInput(?Timer:FlxTimer):Void 
	{
		//decided against punishing multiple keypresses
/*		if (multipleKeysPressed())
		{
			//_score = 0;
			//updateScore("Score: " + _score);
			gameOver();
		}
		else
		{*/
		switch(_randDir)
		{
			case 0:
				if (FlxG.keys.anyPressed(["UP"])) 
				{
					gameOver();
					_inputGiven = true;						
				}
				else if (FlxG.keys.anyJustPressed(["DOWN", "LEFT", "RIGHT"]))
				{
					FlxG.sound.play("assets/up.wav");
					_inputGiven = true;
				}
			case 1:
				if (FlxG.keys.anyPressed(["DOWN"])) 
				{
					gameOver();
					_inputGiven = true;
				}
				else if (FlxG.keys.anyJustPressed(["UP", "LEFT", "RIGHT"]))
				{
					FlxG.sound.play("assets/up.wav");
					_inputGiven = true;
				}
			case 2:
				if (FlxG.keys.anyPressed(["LEFT", "RIGHT"])) 
				{
					gameOver();
					_inputGiven = true;
				}
				else if (FlxG.keys.anyJustPressed(["UP", "DOWN"]))
				{
					FlxG.sound.play("assets/up.wav");
					_inputGiven = true;
				}
		}
	}
	
	private function wiggleArms(?Timer:FlxTimer):Void
	{
		switch(_randDir)
		{
			case 0:
				_waveSprite.screenCenter();
				_waveSprite2.screenCenter();
				
				_waveSprite.angle = 0;
				_waveSprite2.angle = 0;
				
				_waveSprite.x -= 70;
				_waveSprite2.x += 70;
		
				_waveSprite.y -= 60;
				_waveSprite2.y -= 60;
				
				
				add(_waveSprite);
				add(_waveSprite2);
			case 1:
				_waveSprite.screenCenter();
				_waveSprite2.screenCenter();
				
				_waveSprite.angle = 180;
				_waveSprite2.angle = 180;
				
				_waveSprite2.x -= 70;
				_waveSprite.x += 70;
		
				_waveSprite2.y += 60;
				_waveSprite.y += 60;
				
				add(_waveSprite);
				add(_waveSprite2);
			case 2:
				_waveSprite.screenCenter();
				_waveSprite2.screenCenter();
				
				_waveSprite2.angle = 270;
				_waveSprite.angle = 90;
				
				_waveSprite2.x -= 120;
				_waveSprite.x += 120;
		
				_waveSprite2.y -= 10;
				_waveSprite.y -= 10;

				add(_waveSprite);
				add(_waveSprite2);
		}
		//FlxG.sound.play("assets/up.wav");
	}
}