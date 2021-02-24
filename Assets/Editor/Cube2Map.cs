using System;
using UnityEditor;
using UnityEngine;
using System.IO;

public class Cube2Map : EditorWindow
{
    [MenuItem("Tools/Cube2Map")]
    static void ShowWin()
    {
        GetWindow<Cube2Map>();
    }


    private GameObject cube;
    private String folder;
    
    private Camera tmpCam;

    // right, left, top, bottom, Front, Back
    readonly int[] ar_pos = new[] {1,0,0,  -1,0,0,  0,1,0,  0,-1,0,   0,0,-1, 0,0,1};
    readonly int[] ar_rot = new[] {0,-90,0, 0,90,0,  90,0,0, -90,0,0, 0,0,0, 0,180,0};

    private const string camPath = "Assets/Prefab/Capture Camera.prefab";
    
    private void OnEnable()
    {
        tmpCam = AssetDatabase.LoadAssetAtPath<Camera>(camPath);
    }

    private void OnGUI()
    {
        cube =(GameObject)EditorGUILayout.ObjectField("Cubemap", cube, typeof(GameObject), true);
        EditorGUILayout.ObjectField("Camera", tmpCam,typeof(Camera),true);
        
        EditorGUILayout.Space(8);
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Select Output"))
        {
            folder = EditorUtility.OpenFolderPanel("select output", folder, "Assets");
        }
        if (GUILayout.Button("DoIt"))
        {
            if (!string.IsNullOrEmpty(folder))
            {
               var g= LoadCam();
               for (int i = 0; i < 6; i++)
                   Behavic(g, i);
               DestroyImmediate(g);
               AssetDatabase.ImportAsset(folder);
               AssetDatabase.Refresh();
            }
            else
            {
                EditorUtility.DisplayDialog("tip", "select output folder first!", "ok");
            }
        }
        EditorGUILayout.EndHorizontal();

        if (!string.IsNullOrEmpty(folder))
        {
            GUILayout.Label("Output Dir"+folder);
        }
    }
    
    private GameObject LoadCam()
    {
        if (cube)
        {
            string p = AssetDatabase.GetAssetPath(tmpCam);
            var o = AssetDatabase.LoadAssetAtPath<GameObject>(p);
            var g = GameObject.Instantiate(o, cube.transform, true);
            g.transform.localScale = Vector3.one;
            return g;
        }
        else
        {
            EditorUtility.DisplayDialog("tip", "Not selct cube!", "ok");
        }
        return null;
    }


    private void Behavic(GameObject g, int i)
    {
        int x = 3 * i;
        Vector3 pos = new Vector3(ar_pos[x], ar_pos[x + 1], ar_pos[x + 2]);
        Quaternion rot = Quaternion.Euler(ar_rot[x], ar_rot[x + 1], ar_rot[x + 2]);
        g.transform.localPosition = pos;
        g.transform.localRotation = rot;
        var cam = g.GetComponent<Camera>();
        cam.Render();
        RT2Png(folder, "Cube" + i, cam.targetTexture);
    }

    private void RT2Png(string dir, string pngName, RenderTexture rt)
    {
        RenderTexture prev = RenderTexture.active;
        RenderTexture.active = rt;
        Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
        png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        byte[] bytes = png.EncodeToPNG();
        if (!Directory.Exists(dir))
            Directory.CreateDirectory(dir);
        FileStream file = File.Open(dir + "/" + pngName + ".png", FileMode.Create);
        BinaryWriter writer = new BinaryWriter(file);
        writer.Write(bytes);
        file.Close();
        DestroyImmediate(png);
        RenderTexture.active = prev;
    }
    
}
