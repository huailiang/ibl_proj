using UnityEngine;
using UnityEditor;

public class GenIrradiance : EditorWindow
{
    [MenuItem("Tools/Irradiance")]
    static void OpenIrradiance()
    {
        GetWindow<GenIrradiance>();
    }
    
    private Material skybox;
    private float rotate;
    private static readonly int Rotate = Shader.PropertyToID("_Rotation");

    private void OnEnable()
    {
        skybox = RenderSettings.skybox;
    }

    private void OnGUI()
    {
        GUILayout.BeginVertical();
        GUILayout.Label("SkyBox");
        var tex = AssetPreview.GetAssetPreview(skybox);
        EditorGUILayout.ObjectField("skybox", skybox, typeof(Material), false);
        GUILayout.BeginArea(new Rect(20, 60, 256, 256), "env");
        GUI.DrawTexture(new Rect(0, 0, 200, 200), tex);
        GUILayout.EndArea();
        rotate = GUILayout.HorizontalSlider(rotate, 0, 360);
        skybox.SetFloat(Rotate, rotate);
        GUILayout.Space(260);
        GUILayout.EndVertical();
    }
    
}
