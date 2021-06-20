using System;
using UnityEditor;
using UnityEngine;

namespace Editor
{
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
        readonly int[] ar_pos = new[] { 1, 0, 0, -1, 0, 0, 0, 1, 0, 0, -1, 0, 0, 0, -1, 0, 0, 1 };
        readonly int[] ar_rot = new[] { 0, -90, 0, 0, 90, 0, 90, 0, 0, -90, 0, 0, 0, 0, 0, 0, 180, 0 };

        private const string camPath = "Assets/Prefab/Capture Camera.prefab";

        private void OnEnable()
        {
            tmpCam = AssetDatabase.LoadAssetAtPath<Camera>(camPath);
        }

        private void OnGUI()
        {
            cube = (GameObject)EditorGUILayout.ObjectField("Cubemap", cube, typeof(GameObject), true);
            EditorGUILayout.ObjectField("Camera", tmpCam, typeof(Camera), true);

            EditorGUILayout.Space();
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("Select Output"))
            {
                folder = EditorUtility.OpenFolderPanel("select output", folder, "Assets");
            }
            if (GUILayout.Button("Do it!"))
            {
                if (!string.IsNullOrEmpty(folder))
                {
                    var g = LoadCam();
                    for (int i = 0; i < 6; i++)
                        Behavic(g, i);
                    DestroyImmediate(g);
                    AssetDatabase.ImportAsset(folder);
                    AssetDatabase.Refresh();
                    EditorUtility.DisplayDialog("tip", "export cubemap/textures finish", "ok");
                }
                else
                {
                    EditorUtility.DisplayDialog("tip", "select output folder first!", "ok");
                }
            }
            EditorGUILayout.EndHorizontal();

            if (!string.IsNullOrEmpty(folder))
            {
                GUILayout.Label("Output Dir" + folder);
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
            PBRTool.RT2Png(folder, "Cube" + i, cam.targetTexture);
        }
    }
}