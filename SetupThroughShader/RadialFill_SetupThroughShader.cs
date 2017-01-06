using UnityEngine;
using System.Collections;


public class RadialFill_SetupThroughShader : MonoBehaviour {

	public float cutoffStartAngle = 5.0f; // градусы 
	public float opacityStartAngle = -350.0f; // градусы,  -2 * PI + 10 (небольшой начальный угол)
	public float deltaAngle = 5f;

	private const float MAX_ANGLE = 360.0f;
	
	private Material material;
	private float _TextureRotator; // ссылка на переменную _TextureRotator в шейдере
	private float _OpacityRotator; // ссылка на переменную _TextureRotator в шейдере

	void Start () {
		material = GetComponent<SpriteRenderer>().material;
	}
	

	void Update () {			
		if (Input.GetMouseButtonDown(0)) //if (Input.GetKeyDown("f"))		
			StartCoroutine(FillSprite());		
	}


	IEnumerator FillSprite() {		
		var cOffStart = cutoffStartAngle;
		var oStart = opacityStartAngle;

		material.SetFloat("_TextureRotator", cOffStart);
		material.SetFloat("_OpacityRotator", oStart);
		_TextureRotator = cOffStart;
		_OpacityRotator = oStart;

		while(_OpacityRotator <= MAX_ANGLE) {			
			if (_TextureRotator >= MAX_ANGLE) 
				_TextureRotator = MAX_ANGLE;
			if (_OpacityRotator >= MAX_ANGLE) 
				_OpacityRotator = MAX_ANGLE;
				                   
			material.SetFloat("_TextureRotator", _TextureRotator);
			material.SetFloat("_OpacityRotator", _OpacityRotator);

			_OpacityRotator += deltaAngle;
			_TextureRotator += deltaAngle;

			yield return null;
		}

		yield break;
	}
}
