using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum GameState
{

	Home,
	Gameplay,
	Complete,
	Fail

}

public class GameController : MonoBehaviour
{

	[SerializeField] GameState         gameState = GameState.Home;
	public static    Action<GameState> changeGameState;


	public static event Action onHome, onGameplay, onLevelComplete, onLevelFail;


	void Awake()
	{
		changeGameState += ChangeGameState;
		
	}
    private void Start()
    {
		changeGameState?.Invoke(GameState.Home);
	}
    void ChangeGameState(GameState state)
	{


		gameState = state;
		switch (gameState)
		{
			case GameState.Home:
				onHome?.Invoke();
				break;

			case GameState.Gameplay:
				onGameplay?.Invoke();
				break;

			case GameState.Complete:
				onLevelComplete?.Invoke();
				break;

			case GameState.Fail:
			{
				onLevelFail?.Invoke();
				break;
			}
		}
	}


	void OnDestroy()
	{
		onLevelComplete = null;
		changeGameState = null;
		onLevelFail     = null;
		onGameplay      = null;
		onHome          = null;
	}

}