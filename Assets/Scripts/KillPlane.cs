﻿using UnityEngine;
using System.Collections;

public class KillPlane : MonoBehaviour {

	// Use this for initialization
	void OnTriggerEnter (Collider other) {
		//KickStarter.TurnOffAC ();
		//Destroy (other.gameObject,3f);
		UnityEngine.SceneManagement.SceneManager.LoadScene ("StartMenu");
	}
}
