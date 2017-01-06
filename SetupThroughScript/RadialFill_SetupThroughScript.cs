using UnityEngine;
using System.Collections;

public enum FillOrigin {
    Right,
    Bottom,
    Left,
    Top
}


public class RadialFill_SetupThroughScript : MonoBehaviour {

	public float cutoffStartAngle = 5.0f; // градусы 
	public float opacityStartAngle = -350.0f; // градусы,  -2 * PI + 10 (небольшой начальный угол)
	public float deltaAngle = 5f;
    public bool fillClockwise = true;
    public FillOrigin fillOrigin = FillOrigin.Right;

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
        material.SetFloat("_FillClockwise", fillClockwise ? 1 : 0);
        material.SetFloat("_TextureRotator", cOffStart);
        material.SetFloat("_OpacityRotator", oStart);

        SetCutoffData();
	    SetOpacityData();

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


    private void SetCutoffData() {
        var cutoffRightBottomLeftTop = 1.0f;
        if (fillOrigin == FillOrigin.Bottom)
            cutoffRightBottomLeftTop = fillClockwise ? 1.75f : 1.25f;
        else if (fillOrigin == FillOrigin.Left)
            cutoffRightBottomLeftTop = 1.5f;
        else if (fillOrigin == FillOrigin.Top)
            cutoffRightBottomLeftTop = fillClockwise ? 1.25f : 1.75f;
        cutoffRightBottomLeftTop += 0.001f;

        material.SetFloat("_CutoffRightBottomLeftTop", cutoffRightBottomLeftTop);
    }


    private void SetOpacityData() {
        Vector2 oVector = new Vector2(1, -1);
        var oRightBottomLeftTop = 1.0f;
        int reverseMaskCoords = (fillOrigin == FillOrigin.Top || fillOrigin == FillOrigin.Bottom) ? 1 : 0;
        if (fillOrigin == FillOrigin.Left)
            oVector = new Vector2(-1, 1);
        else if (fillOrigin == FillOrigin.Top) {
            oVector = fillClockwise ? new Vector2(-1, -1) : new Vector2(1, 1);
            oRightBottomLeftTop = -1.0f;
        } else if (fillOrigin == FillOrigin.Bottom) {
            oVector = fillClockwise ? new Vector2(1, 1) : new Vector2(-1, -1);
            oRightBottomLeftTop = -1.0f;
        }

        material.SetInt("_ReverseMaskCoords", reverseMaskCoords);
        material.SetVector("_OpVector", oVector);
        material.SetFloat("_OpRightBottomLeftTop", oRightBottomLeftTop);
    }
}
